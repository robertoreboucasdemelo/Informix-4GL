################################################################################
# Nome do Modulo: BDATA132.4gl                               Danilo - F0111099 #
#                                                                              #
# RelatÛrio semanal de registros de atendimento Central24hr           Jun/2010 #
#------------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            AlteraÁ„o da utilizaÁ„o do sendmail    #
################################################################################

database porto
define m_rel  smallint
globals
   define g_ismqconn smallint
end globals

#-------------------------------------Main--------------------------------------
main
   call fun_dba_abre_banco("CT24HS")
   call bdata132()
end main

#----------------------------Prepara comandos SQL-------------------------------
function bdata132_prepare()

  define l_sql char(1000)

  #--Seleciona os dados do registro de atendimento conforme periodo
  let l_sql =  " Select atdincdat    "
              ,"       ,atdinchor    "
              ,"       ,atdfnldat    "
              ,"       ,atdfnlhor    "
              ,"       ,atdusrtip    "
              ,"       ,atdfunempcod "
              ,"       ,atdfunmat    "
              ,"       ,atdsrvnum    "
              ,"       ,atdsrvano    "
              ,"       ,oprctrctttip "
              ,"       ,oprctrclitip "
              ,"       ,pstcoddig    "
              ,"       ,srrcoddig    "
              ,"       ,lcvcod       "
              ,"       ,cliusrtip    "
              ,"       ,clifunempcod "
              ,"       ,clifunmat    "
              ,"       ,c24astcod    "
              ,"       ,rcuccsmtvcod "
              ,"   from dpamatdreg   "
              ,"  where atdincdat>=? "
              ,"    and atdfnldat<=? "
  prepare pbdata132001 from l_sql
  declare cbdata132001 cursor for pbdata132001

  #--Seleciona a empresa do serviÁo
  let l_sql = "select empsgl "
             ,"from   gabkemp "
             ,"where  empcod = (select ciaempcod "
                              ,"from   datmservico "
                              ,"where  atdsrvnum = ? "
                              ,"and   atdsrvano =  ?) "
  prepare pbdata132002 from l_sql
  declare cbdata132002 cursor for pbdata132002

  #--Seleciona o tipo de contato / cliente
  let l_sql = "select cpodes "
             ,"from   datkdominio "
             ,"where  cponom = ? "
             ,"and    cpocod = ? "
  prepare pbdata132003 from l_sql
  declare cbdata132003 cursor for pbdata132003

  #--Seleciona dados do prestador / clinicas veterinarias
  let l_sql = "select nomgrr "
             ,"from   dpaksocor "
             ,"where  pstcoddig = ? "
  prepare pbdata132004 from l_sql
  declare cbdata132004 cursor for pbdata132004


  #--Seleciona dados do socorrista
  let l_sql = "select srrnom "
             ,"from   datksrr "
             ,"where  srrcoddig = ? "
  prepare pbdata132005 from l_sql
  declare cbdata132005 cursor for pbdata132005

  #--Seleciona dados da locadora
  let l_sql = "select lcvnom "
             ,"from   datklocadora "
             ,"where  lcvcod = ? "
  prepare pbdata132006 from l_sql
  declare cbdata132006 cursor for pbdata132006

  #--Seleciona dados do atendente da central24h
  let l_sql = "select funnom "
             ,"from   isskfunc "
             ,"where  usrtip = ? "
             ,"and    empcod = ? "
             ,"and    funmat = ? "
  prepare pbdata132007 from l_sql
  declare cbdata132007 cursor for pbdata132007

  #--Seleciona dados do assunto
  let l_sql =  "select c24astdes "
              ,"from   datkassunto "
              ,"where  c24astagp = 'CO' "
              ,"and    c24astcod = ? "
  prepare pbdata132008 from l_sql
  declare cbdata132008 cursor for pbdata132008

  #--Seleciona dados do subassunto
  let l_sql =  "select  rcuccsmtvdes "
              ,"from    datkrcuccsmtv "
              ,"where   c24astcod    = ? "
              ,"and     rcuccsmtvcod = ? "
  prepare pbdata132009 from l_sql
  declare cbdata132009 cursor for pbdata132009

  #--buscar no banco emails de envio do relatorio
  let l_sql =   "select relpamtxt "
               ,"from   igbmparam "
               ,"where  relsgl = 'BDATA132'"
  prepare pbdata132010 from l_sql
  declare cbdata132010 cursor for pbdata132010

  #--Seleciona nome do atendente
  let l_sql =   "select funnom "
               ,"from   isskfunc "
               ,"where  usrtip = ? "
               ,"and    empcod = ? "
               ,"and    funmat = ? "
  prepare pbdata132011 from l_sql
  declare cbdata132011 cursor for pbdata132011


end function

#---------------------------------FunÁ„o Principal------------------------------
function bdata132()

  #------------------------Define as variaveis locais---------------------------
  define    dados_bdata132      record
            atdincdat           like dpamatdreg.atdincdat,    #Data inicio
            atdinchor           like dpamatdreg.atdinchor,    #Hora Inicio
            atdfnldat           like dpamatdreg.atdfnldat,    #Data Fim
            atdfnlhor           like dpamatdreg.atdfnlhor,    #Hora Fim
            atdusrtip           like dpamatdreg.atdusrtip,    #Tp do antendete
            atdfunempcod        like dpamatdreg.atdfunempcod, #Empresa do atendente
            atdfunmat           like dpamatdreg.atdfunmat,    #Matricula do Atendente
            atdsrvnum           like dpamatdreg.atdsrvnum ,   #Numero do servico
            atdsrvano           like dpamatdreg.atdsrvano ,   #ano do servico
            oprctrctttip        like dpamatdreg.oprctrctttip, #Tipo do contato
            oprctrclitip        like dpamatdreg.oprctrclitip, #tipo do cliente
            pstcoddig           like dpamatdreg.pstcoddig ,   #CÛdigo prestador
            srrcoddig           like dpamatdreg.srrcoddig,    #Codigo Socorrista
            lcvcod              like dpamatdreg.lcvcod,       #CÛdigo locadora
            cliusrtip           like dpamatdreg.cliusrtip ,   #Tp func central24h
            clifunempcod        like dpamatdreg.clifunempcod, #Emp. func. Central24h
            clifunmat           like dpamatdreg. clifunmat,   #Mat. Func. Central24h
            c24astcod           like dpamatdreg.c24astcod ,   #CÛdigo Assunto
            rcuccsmtvcod        like dpamatdreg.rcuccsmtvcod  #CÛdigo subassunto
  end record

  define    relatorio_bdata132      record
            atdincdat           like dpamatdreg.atdincdat,    #Data inicio
            atdinchor           like dpamatdreg.atdinchor,    #Hora Inicio
            atdfnldat           like dpamatdreg.atdfnldat,    #Data Fim
            atdfnlhor           like dpamatdreg.atdfnlhor,    #Hora Fim
            matricula           char(10),                     #Tp do antendete
            nomeatendente       char(50),                     #Nome atendente
            empresa             char(20),                     #Empresa do atendente
            atdsrvnum           like dpamatdreg.atdsrvnum,    #Numero do servico
            atdsrvano           like dpamatdreg.atdsrvano,    #ano do servico
            oprctrctttip        char(30),                     #Tipo do contato
            oprctrclitip        char(30),                     #tipo do cliente
            cdidentificacao     char(10),                     #CÛdigo ident.
            dsidentificacao     char(30),                     #Desc ident.
            c24astcod           like dpamatdreg.c24astcod ,   #CÛdigo Assunto
            dsassunto           char(30),                     #Desc Assunto
            rcuccsmtvcod        like dpamatdreg.rcuccsmtvcod, #CÛdigo subassunto
            dssubassunto        char(30)                      #Desc SubAssunto
  end record

  define lr_mens        record
         para           char(1000)
        ,cc             char(400)
        ,anexo          char(400)
        ,assunto        char(100)
        ,msg            char(400)
  end record

  define param_atdincdat        like dpamatdreg.atdincdat     #Data inicio
  define param_atdfnldat        like dpamatdreg.atdfnldat     #Data Fim
  define dirfisnom              char(150)                     #Diretorio
  define ws_aux                 char(50)                      #variavel auxiliar
  define emails                 array[20] of char(70)
  define l_cont                 smallint
  define l_tam_matricula        integer
  define l_matricula            char(10)

  #-----------------------Inicializa variaveis----------------------------------
  initialize  dados_bdata132.*
             ,relatorio_bdata132.* to null

  let param_atdincdat = today - 7
  let param_atdfnldat = today - 1
  let m_rel = false

  #--------------Define diretorios para relatorios e arquivos-------------------
  call f_path("DAT", "RELATO")
  returning dirfisnom

  let dirfisnom = dirfisnom clipped, "/relsemregatend.xls"

  #-------------------------inicializa Prepare----------------------------------
  call bdata132_prepare()

  #----------------------Inicia criaÁ„o do relatorio----------------------------
  start report  rep_bdata132  to  dirfisnom
    open cbdata132001 using param_atdincdat
                           ,param_atdfnldat

    display "Criando relatÛrio..."
    foreach cbdata132001 into  dados_bdata132.*

      Initialize relatorio_bdata132.* to null

      let relatorio_bdata132.atdincdat =  dados_bdata132.atdincdat
      let relatorio_bdata132.atdinchor =  dados_bdata132.atdinchor
      let relatorio_bdata132.atdfnldat     =  dados_bdata132.atdfnldat
      let relatorio_bdata132.atdfnlhor     =  dados_bdata132.atdfnlhor

      let l_matricula = dados_bdata132.atdfunmat
      let l_tam_matricula = length(l_matricula)

      if l_tam_matricula <=5 then
        let ws_aux = dados_bdata132.atdusrtip
                    ,dados_bdata132.atdfunempcod using "&&"
                    ,dados_bdata132.atdfunmat using "&&&&&"
      else
        let ws_aux = dados_bdata132.atdusrtip
                    ,"0"
                    ,dados_bdata132.atdfunmat using "&&&&&&"
      end if

      let relatorio_bdata132.matricula   =  ws_aux

      open cbdata132011 using dados_bdata132.atdusrtip
                             ,dados_bdata132.atdfunempcod
                             ,dados_bdata132.atdfunmat
      fetch cbdata132011 into  relatorio_bdata132.nomeatendente

      open cbdata132002 using dados_bdata132.atdsrvnum
                             ,dados_bdata132.atdsrvano
      fetch cbdata132002 into  relatorio_bdata132.empresa

      if relatorio_bdata132.empresa = "PORTOSEG S/A" then
       let relatorio_bdata132.empresa = "CARTAO"
      end if

      if relatorio_bdata132.empresa = "PORTO SERVI«OS" then
       let relatorio_bdata132.empresa = "PPS"
      end if

      let relatorio_bdata132.atdsrvnum = dados_bdata132.atdsrvnum
      let relatorio_bdata132.atdsrvano = dados_bdata132.atdsrvano

      let ws_aux = "psocor_TpContato"
      open cbdata132003 using  ws_aux
                              ,dados_bdata132.oprctrctttip
      fetch cbdata132003 into relatorio_bdata132.oprctrctttip


      let ws_aux = "psocor_TpCliente"
      open cbdata132003 using  ws_aux
                              ,dados_bdata132.oprctrclitip
      fetch cbdata132003 into relatorio_bdata132.oprctrclitip

      case dados_bdata132.oprctrclitip
       when 1
          let relatorio_bdata132.cdidentificacao = dados_bdata132.pstcoddig
          open  cbdata132004 using dados_bdata132.pstcoddig
          fetch cbdata132004 into  relatorio_bdata132.dsidentificacao
        when 3
          let relatorio_bdata132.cdidentificacao = dados_bdata132.pstcoddig
          open  cbdata132004 using dados_bdata132.pstcoddig
          fetch cbdata132004 into  relatorio_bdata132.dsidentificacao
        when 4

          let l_matricula = dados_bdata132.clifunmat
          let l_tam_matricula = length(l_matricula)

          if l_tam_matricula<= 5 then
            let ws_aux = dados_bdata132.cliusrtip
                        ,dados_bdata132.clifunempcod using "&&"
                        ,dados_bdata132.clifunmat using "&&&&&"
           else
            let ws_aux = dados_bdata132.cliusrtip
                        ,"0"
                        ,dados_bdata132.clifunmat using "&&&&&&"
          end if

          let relatorio_bdata132.cdidentificacao = ws_aux

          open cbdata132007 using dados_bdata132.cliusrtip
                                 ,dados_bdata132.clifunempcod
                                 ,dados_bdata132.clifunmat
          fetch cbdata132007 into relatorio_bdata132.dsidentificacao
        when 5

          if length(dados_bdata132.cliusrtip)<= 5 then
            let ws_aux = dados_bdata132.cliusrtip
                        ,dados_bdata132.clifunempcod using "&&"
                        ,dados_bdata132.clifunmat using "&&&&&"
           else
            let ws_aux = dados_bdata132.cliusrtip
                        ,"0"
                        ,dados_bdata132.clifunmat using "&&&&&&"
          end if

          let relatorio_bdata132.cdidentificacao = ws_aux

          open cbdata132007 using dados_bdata132.cliusrtip
                                 ,dados_bdata132.clifunempcod
                                 ,dados_bdata132.clifunmat
          fetch cbdata132007 into relatorio_bdata132.dsidentificacao
        when 6
          let relatorio_bdata132.cdidentificacao = dados_bdata132.lcvcod
          open  cbdata132006 using dados_bdata132.lcvcod
          fetch cbdata132006 into  relatorio_bdata132.dsidentificacao
        when 8
          let relatorio_bdata132.cdidentificacao = dados_bdata132.pstcoddig
          open  cbdata132004 using dados_bdata132.pstcoddig
          fetch cbdata132004 into  relatorio_bdata132.dsidentificacao
        when 12
          let relatorio_bdata132.cdidentificacao = dados_bdata132.srrcoddig
          open  cbdata132005 using dados_bdata132.srrcoddig
          fetch cbdata132005 into  relatorio_bdata132.dsidentificacao
        when 17

          if length(dados_bdata132.cliusrtip)<= 5 then
            let ws_aux = dados_bdata132.cliusrtip
                        ,dados_bdata132.clifunempcod using "&&"
                        ,dados_bdata132.clifunmat using "&&&&&"
           else
            let ws_aux = dados_bdata132.cliusrtip
                        ,"0"
                        ,dados_bdata132.clifunmat using "&&&&&&"
          end if

          let relatorio_bdata132.cdidentificacao = ws_aux

          open cbdata132007 using dados_bdata132.cliusrtip
                                 ,dados_bdata132.clifunempcod
                                 ,dados_bdata132.clifunmat
          fetch cbdata132007 into relatorio_bdata132.dsidentificacao
        otherwise
          initialize relatorio_bdata132.cdidentificacao
                    ,relatorio_bdata132.dsidentificacao to null
      end case

      let relatorio_bdata132.c24astcod = dados_bdata132.c24astcod
      open  cbdata132008 using dados_bdata132.c24astcod
      fetch cbdata132008 into  relatorio_bdata132.dsassunto


      let relatorio_bdata132.rcuccsmtvcod = dados_bdata132.rcuccsmtvcod
      open  cbdata132009 using dados_bdata132.c24astcod
                              ,dados_bdata132.rcuccsmtvcod
      fetch cbdata132009 into  relatorio_bdata132.dssubassunto

      let m_rel = true
      output to report rep_bdata132(relatorio_bdata132.*)

    end foreach
  finish report  rep_bdata132

  #--------------------------prepara envio de e-mail----------------------------
  display "Criando e-mail..."
  let l_cont = 1

  open cbdata132010
  foreach cbdata132010 into emails[l_cont]
    if l_cont = 1 then
      let lr_mens.para = emails[l_cont] clipped
    else
      let lr_mens.para =lr_mens.para clipped
                        ,","
                        ,emails[l_cont] clipped
    end if
    let l_cont = l_cont+1
  end foreach

  let lr_mens.anexo = dirfisnom

  let lr_mens.assunto = "Relatorio semanal de registro de Atendimento - "
                       ,param_atdincdat
                       ," a "
                       ,param_atdfnldat
                       ,"."

  let lr_mens.msg =  "<html><body><font face = Times New Roman>Prezado(s), <br><br>"
                    ,"Segue anexo relat&oacute;rio semanal de registro "
                    ,"de atendimento da central de opera&ccedil;&otilde;es. <br><br>"
                    ,"Refer&ecirc;ncia: " , param_atdincdat, " a " , param_atdfnldat, ". <br><br>"
                    ,"Atenciosamente, <br><br>"
                    ,"Corpora&ccedil;&atilde;o Porto Seguro - http://www.portoseguro.com.br"
                    ," <br> "
                    ," <br></font></body></html> "



  call send_email(lr_mens.*)

end function

#-------------------------------Envia e-mail------------------------------------
function send_email(lr_mens)
  #----------------------------Define variaveis---------------------------------
  define lr_mens        record
         para           char(1000)
        ,cc             char(400)
        ,anexo          char(400)
        ,assunto        char(100)
        ,msg            char(400)
  end record

  define  l_mail             record
          de                 char(500)   # De
         ,para               char(5000)  # Para
         ,cc                 char(500)   # cc
         ,cco                char(500)   # cco
         ,assunto            char(500)   # Assunto do e-mail
         ,mensagem           char(32766) # Nome do Anexo
         ,id_remetente       char(20)
         ,tipo               char(4)     #
  end  record
  define  l_erro     char(1000)
         ,l_ret     smallint
         ,l_assunto char(200)

  #--------------------Inicia Variaveis-----------------------------------------
  let l_ret = null

  #PSI-2013-23297 - Inicio
  let l_mail.de = "ct24hs.email"
  let l_mail.para = lr_mens.para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = lr_mens.assunto
  let l_mail.mensagem = lr_mens.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"

  if m_rel = true then
     call figrc009_attach_file(lr_mens.anexo)
  else
     let l_mail.mensagem ="Nao existem registros a serem processados."
  end if

  call figrc009_mail_send1 (l_mail.*)
     returning l_ret,l_erro
  #PSI-2013-23297 - Fim

  #------------------------Confirma envio de e-mail-----------------------------
  if l_ret = 0  then
    let l_assunto = '### ATEN«„O ### - Email enviado com sucesso! ',
                     current
  else
    let l_assunto = '### ATEN«„O ### - Email nao enviado!', current
  end if

  display l_assunto

end function


#-----------------------------Montar relatorio----------------------------------
report rep_bdata132(relatorio_bdata132)

  define    relatorio_bdata132      record
            atdincdat           like dpamatdreg.atdincdat,    #Data inicio
            atdinchor           like dpamatdreg.atdinchor,    #Hora Inicio
            atdfnldat           like dpamatdreg.atdfnldat,    #Data Fim
            atdfnlhor           like dpamatdreg.atdfnlhor,    #Hora Fim
            matricula           char(10),                     #Tp do antendete
            nomeatendente       char(50),                     #Nome atendente
            empresa             char(20),                     #Empresa do atendente
            atdsrvnum           like dpamatdreg.atdsrvnum,    #Numero do servico
            atdsrvano           like dpamatdreg.atdsrvano,    #ano do servico
            oprctrctttip        char(30),                     #Tipo do contato
            oprctrclitip        char(30),                     #tipo do cliente
            cdidentificacao     char(10),                     #CÛdigo ident.
            dsidentificacao     char(30),                     #Desc ident.
            c24astcod           like dpamatdreg.c24astcod ,   #CÛdigo Assunto
            dsassunto           char(30),                     #Desc Assunto
            rcuccsmtvcod        like dpamatdreg.rcuccsmtvcod, #CÛdigo subassunto
            dssubassunto        char(30)                      #Desc SubAssunto
  end record

 output
    left   margin 000
    top    margin 000
    bottom margin 000

 format
    first page header
       print  "<html><table border=1>"
             ,"<tr>"
             ,"<th align='center' bgcolor='gray'>DATA INICIAL</th>"
             ,"<th align='center' bgcolor='gray'>HORA INICIAL</th>"
             ,"<th align='center' bgcolor='gray'>DATA FINAL</th>"
             ,"<th align='center' bgcolor='gray'>HORA FINAL</th>"
             ,"<th align='center' bgcolor='gray'>MAT. ATEND.</th>"
             ,"<th align='center' bgcolor='gray'>NOME ATEND.</th>"
             ,"<th align='center' bgcolor='gray'>EMPRESA</th>"
             ,"<th align='center' bgcolor='gray'>NUM. SERVI«O</th>"
             ,"<th align='center' bgcolor='gray'>ANO SERVI«O</th>"
             ,"<th align='center' bgcolor='gray'>TP. CONTATO</th>"
             ,"<th align='center' bgcolor='gray'>TP. CLIENTE</th>"
             ,"<th align='center' bgcolor='gray'>C”D. IDENT.</th>"
             ,"<th align='center' bgcolor='gray'>DESC.IDENT</th>"
             ,"<th align='center' bgcolor='gray'>C”D. ASSUNTO</th>"
             ,"<th align='center' bgcolor='gray'>DESC. ASSUNTO</th>"
             ,"<th align='center' bgcolor='gray'>C”D. SUBASSUNTO</th>"
             ,"<th align='center' bgcolor='gray'>DESC. SUBASSUNTO</th></tr>"
    on every row
       print   "<tr><td align='center'>",relatorio_bdata132.atdincdat, "</td>"
              ,"<td align='center'>",relatorio_bdata132.atdinchor, "</td>"
              ,"<td align='center'>",relatorio_bdata132.atdfnldat, "</td>"
              ,"<td align='center'>",relatorio_bdata132.atdfnlhor , "</td>"
              ,"<td align='center'>",relatorio_bdata132.matricula , "</td>"
              ,"<td align='center'>",relatorio_bdata132.nomeatendente, "</td>"
              ,"<td align='center'>",relatorio_bdata132.empresa, "</td>"
              ,"<td align='center'>",relatorio_bdata132.atdsrvnum , "</td>"
              ,"<td align='center'>",relatorio_bdata132.atdsrvano, "</td>"
              ,"<td align='center'>",relatorio_bdata132.oprctrctttip, "</td>"
              ,"<td align='center'>",relatorio_bdata132.oprctrclitip, "</td>"
              ,"<td align='center'>",relatorio_bdata132.cdidentificacao, "</td>"
              ,"<td align='center'>",relatorio_bdata132.dsidentificacao, "</td>"
              ,"<td align='center'>",relatorio_bdata132.c24astcod, "</td>"
              ,"<td align='center'>",relatorio_bdata132.dsassunto, "</td>"
              ,"<td align='center'>",relatorio_bdata132.rcuccsmtvcod, "</td>"
              ,"<td align='center'>",relatorio_bdata132.dssubassunto, "</td></tr>"
end report

