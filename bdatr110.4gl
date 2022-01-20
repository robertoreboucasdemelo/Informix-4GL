#---------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                               #
#...............................................................#
# Sistema       : CT24HS                                        #
# Modulo        : bdatr110.4gl                                  #
#                 Relatorio de produtividade diaria ct24hs      #
# Analista Resp.: Cristina Coelho                               #
# PSI           : 153397                                        #
#               :                                               #
#                                                               #
#...............................................................#
# Desenvolvimento: Fabrica de Software, Fernando Tupinamba      #
# Liberacao      : 04/06/2002                                   #
#---------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual e   #
#                                         incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

globals
   define g_ismqconn smallint
end globals
  define m_time_begin  datetime hour to fraction
  define m_time_end    datetime hour to fraction
  define m_elapsed     interval hour to fraction

  define m_bdatr110 record
     cademp         like dacmlig.cademp,
     cadmat         like dacmlig.cadmat,
     funnom         like isskfunc.funnom,
     prpnumpcp      decimal(8,0),
     fcapacnum      like dacrligpac.fcapacnum,
     corligano      smallint,
     corlignum      decimal(10,0),
     corsus         char(06),
     cvnnum         smallint
  end record

  define m_lidos     smallint
  define m_hostname  char(20)
  define m_sql       char(1000)
  define m_count_ger smallint
  define l_data      date
  define ws_dirfisnom char(50)
  define ws_pipe     char(50)
  define l_retorno   smallint
  define l_msg       char (500)
#------------------------------------------------------------------------------
main
#------------------------------------------------------------------------------

  let l_retorno = 0
  let l_msg = null
  call fun_dba_abre_banco("CT24HS")
  set isolation to dirty read
  set lock mode to wait 10

  #--------------------------------------------------------------------
  # Define data parametro
  #--------------------------------------------------------------------
  let l_data = arg_val(1)

  if l_data is null       or
     l_data =  "  "       then
     if time >= "17:00"  and
        time <= "23:59"  then
        let l_data = today
     else
        let l_data = today - 1
     end if
  else
     if l_data > today       or
        length(l_data) < 10  then
        let l_msg = "  *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
        #exit program
        call bdatr110_envia_email_erro("AVISO DE ERRO BATCH - bdatr110 ",l_msg)
        let l_retorno = 1
     end if
  end if

  if l_retorno = 0 then
     #---------------------------------------------------------------
     # Define diretorios para relatorios e arquivos
     #---------------------------------------------------------------
     call f_path("DAT", "ARQUIVO")
          returning ws_dirfisnom

      call bdatr110_abre_banco()
      call bdatr110_prepare()
      call bdatr110()
      display ""
      display "****************************************"
      display "*                                      *"
      display "* Inicio  Processo: ", m_time_begin
      display "* Termino Processo: ", m_time_end
      display "* Tempo  Processo: ", m_elapsed
      display "' Registros Lidos : ", m_lidos
      display "*                                      *"
      display "****************************************"

      display  ""
      display  "---> Termino de Processo <---"
    #------------------------------------------------------------------------------
  end if
end main
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
function bdatr110_abre_banco()
#------------------------------------------------------------------------------

    display  "---> Inicio de Processo <---"
    display  ""

    #---[ Abertura do DB ]---#
    select  sitename
      into m_hostname
      from dual


#------------------------------------------------------------------------------
end function # bdatr110_abre_banco()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
function bdatr110_prepare()
#------------------------------------------------------------------------------

    #---[ Inicializa Variaveis ]---#
    let m_sql           =  null

    #---[ Prepare's ]---#
    let m_sql = " select unique cademp, cadmat ",
                "   from dacmlig ",
                "  where ligdat = ? ",
                "  order by cadmat "
    prepare pbdatr110004 from m_sql
    declare cbdatr110001 cursor for pbdatr110004

    let m_sql = " select funnom ",
                "   from isskfunc ",
                "  where funmat = ? ",
                "    and dptsgl = 'ct24hs' ",
                "    and empcod = ? "
    prepare pbdatr110005 from m_sql
    declare cbdatr110002 cursor for pbdatr110005

    let m_sql = " select prpnumpcp, count(*) ",
                "   from dacmlig, dacmligass, dacrligorc ",
                "  where dacmlig.corlignum = dacmligass.corlignum ",
                "    and dacmlig.corligano = dacmligass.corligano ",
                "    and dacrligorc.corlignum = dacmlig.corlignum ",
                "    and dacrligorc.corligano = dacmlig.corligano ",
                "    and dacrligorc.corligitmseq = dacmligass.corligitmseq ",
                "    and dacmligass.corasscod in (1,2,3,4,34,36,314,315,316, ",     # Os codigos 314 a 336
                                                " 317,318,319,320,321,322,323, ",   # estao associados ao
                                                " 324,325,326,327,328,329,330, ",   # codigo 4
                                                " 331,332,333,334,335,336) ",
                "    and dacmlig.ligdat = ? ",
                "    and dacmlig.cademp = ? ",
                "    and dacmlig.cadmat = ? ",
                "  group  by prpnumpcp "
    prepare pbdatr110006 from m_sql
    declare cbdatr110003 cursor for pbdatr110006

    let m_sql = " select a.corligano, b.corlignum, c.prpnumpcp, count(*) ",
                "   from dacmlig a, dacmligass b, dacrligsmprnv c ",
                "  where a.corlignum = b.corlignum ",
                "    and a.corligano = b.corligano ",
                "    and c.corlignum = a.corlignum ",
                "    and c.corligano = a.corligano ",
                "    and c.corligitmseq = b.corligitmseq ",
                "    and b.corasscod = 9 ",
                "    and c.prporgpcp = 16 ",
                "    and a.ligdat = ? ",
                "    and a.cademp = ? ",
                "    and a.cadmat = ? ",
                "  group  by a.corligano, b.corlignum, c.prpnumpcp "
    prepare pbdatr110007 from m_sql
    declare cbdatr110004 cursor for pbdatr110007

    let m_sql = " select corsus ",
                "   from dacrligsus ",
                "  where corligano = ? ",
                "    and corlignum = ? "
    prepare pbdatr110008 from m_sql
    declare cbdatr110005 cursor for pbdatr110008

    let m_sql = " select cvnnum ",
                "   from gcaksusep ",
                "  where corsus = ? "
    prepare pbdatr110009 from m_sql
    declare cbdatr110006 cursor for pbdatr110009

    let m_sql = " select prpnumpcp, count(*) ",
                "   from dacmlig, dacmligass, dacrligsmprnv ",
                "  where dacmlig.corlignum = dacmligass.corlignum ",
                "    and dacmlig.corligano = dacmligass.corligano ",
                "    and dacrligsmprnv.corlignum = dacmlig.corlignum ",
                "    and dacrligsmprnv.corligano = dacmlig.corligano ",
                "    and dacrligsmprnv.corligitmseq = dacmligass.corligitmseq ",
                "    and dacmligass.corasscod in (6,7,37,73) ",
                "    and dacrligsmprnv.prporgpcp = 12 ",
                "    and dacmlig.ligdat = ? ",
                "    and dacmlig.cademp = ? ",
                "    and dacmlig.cadmat = ? ",
                "  group  by prpnumpcp "
    prepare pbdatr110010 from m_sql
    declare cbdatr110007 cursor for pbdatr110010

    let m_sql = " select prpnumdig, count(*) ",
                "   from dacmlig, dacmligass, dacrligrmeorc ",
                "  where dacmlig.corlignum = dacmligass.corlignum ",
                "    and dacmlig.corligano = dacmligass.corligano ",
                "    and dacrligrmeorc.corlignum = dacmlig.corlignum ",
                "    and dacrligrmeorc.corligano = dacmlig.corligano ",
                "    and dacrligrmeorc.corligitmseq = dacmligass.corligitmseq ",
                "    and dacmligass.corasscod in (43,52,53,54,55) ",
                "    and dacrligrmeorc.prporg = 0 ",
                "    and dacmlig.ligdat = ? ",
                "    and dacmlig.cademp = ? ",
                "    and dacmlig.cadmat = ? ",
                "  group  by prpnumdig "
    prepare pbdatr110011 from m_sql
    declare cbdatr110008 cursor for pbdatr110011

    let m_sql = " select prpnumdig, count(*) ",
                "   from dacmlig, dacmligass, dacrligrmeorc ",
                "  where dacmlig.corlignum = dacmligass.corlignum ",
                "    and dacmlig.corligano = dacmligass.corligano ",
                "    and dacrligrmeorc.corlignum = dacmlig.corlignum ",
                "    and dacrligrmeorc.corligano = dacmlig.corligano ",
                "    and dacrligrmeorc.corligitmseq = dacmligass.corligitmseq ",
                "    and dacmligass.corasscod in (45,47) ",
                "    and dacrligrmeorc.prporg = 69 ",
                "    and dacmlig.ligdat = ? ",
                "    and dacmlig.cademp = ? ",
                "    and dacmlig.cadmat = ? ",
                "  group  by prpnumdig "
    prepare pbdatr110012 from m_sql
    declare cbdatr110009 cursor for pbdatr110012

    let m_sql = " select fcapacnum, count(*) ",
                "   from dacmlig, dacmligass, dacrligpac ",
                "  where dacmlig.corlignum = dacmligass.corlignum ",
                "    and dacmlig.corligano = dacmligass.corligano ",
                "    and dacrligpac.corlignum = dacmlig.corlignum ",
                "    and dacrligpac.corligano = dacmlig.corligano ",
                "    and dacrligpac.corligitmseq = dacmligass.corligitmseq ",
                "    and dacmligass.corasscod = 41 ",
                "    and dacmlig.ligdat = ? ",
                "    and dacmlig.cademp = ? ",
                "    and dacmlig.cadmat = ? ",
                "  group by fcapacnum "
    prepare pbdatr110013 from m_sql
    declare cbdatr110010 cursor for pbdatr110013

#------------------------------------------------------------------------------
end function # bdatr110_prepare()
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
function bdatr110()
#------------------------------------------------------------------------------

  define l_count         smallint,
         l_count1        smallint,
         l_count2        smallint,
         l_count3        smallint,
         l_count4        smallint,
         l_count5        smallint,
         l_count_tot     smallint,
         l_status        smallint,
         l_run           char(500)

  define l_assunto     char(100),
         l_erro_envio  smallint

  #---[ Inicializa Variaveis ]---#
  let m_time_begin    =  current
  let l_count         =  0
  let l_count1        =  0
  let l_count2        =  0
  let l_count3        =  0
  let l_count4        =  0
  let l_count5        =  0
  let l_count_tot     =  0
  let m_count_ger     =  0
  let m_lidos         =  0

  initialize m_bdatr110.* to null

  display "Gerando Arquivo ... Aguarde!"

  let ws_pipe = ws_dirfisnom clipped, "/bdatr110.xls"

  start report bdatr110_report to ws_pipe

  open cbdatr110001 using l_data
  foreach cbdatr110001 into m_bdatr110.cademp,
                            m_bdatr110.cadmat

     let m_lidos = m_lidos + 1

     open cbdatr110002 using m_bdatr110.cadmat,
                             m_bdatr110.cademp
     fetch cbdatr110002 into m_bdatr110.funnom
     let l_status = sqlca.sqlcode
     close cbdatr110002

     if l_status < 0 then
        display "--------------------------------------------------"
        display "Erro de Acesso na Tabela ISSKFUNC"
        display "Status:",l_status
        display "--------------------------------------------------"
        exit program(1)
     end if
     call bdatr110_trata_funnom(m_bdatr110.funnom)
              returning m_bdatr110.funnom

     open cbdatr110003 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110003 into m_bdatr110.prpnumpcp

        let l_count = l_count + 1

     end foreach

     if l_count > 0 then
        let l_count_tot = l_count_tot + l_count
        let m_count_ger = m_count_ger + l_count
     end if

     open cbdatr110004 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110004 into m_bdatr110.corligano,
                               m_bdatr110.corlignum,
                               m_bdatr110.prpnumpcp

        open cbdatr110005 using m_bdatr110.corligano,
                                m_bdatr110.corlignum
        fetch cbdatr110005 into m_bdatr110.corsus
        let l_status = sqlca.sqlcode
        close cbdatr110005

        if l_status < 0 then
           display "--------------------------------------------------"
           display "Erro de Acesso na Tabela DACRLIGSUS"
           display "Status:",l_status
           display "--------------------------------------------------"
           exit program(1)
        end if

        open cbdatr110006 using m_bdatr110.corsus
        fetch cbdatr110006 into m_bdatr110.cvnnum
        let l_status = sqlca.sqlcode
        close cbdatr110006

        if l_status < 0 then
           display "--------------------------------------------------"
           display "Erro de Acesso na Tabela GCAKSUSEP"
           display "Status:",l_status
           display "--------------------------------------------------"
           exit program(1)
        end if

        if m_bdatr110.cvnnum = 0 then
           continue foreach
        else
           let l_count1 = l_count1 + 1
        end if

     end foreach

     close cbdatr110004

     if l_count1 > 0 then
        let l_count_tot = l_count_tot + l_count1
        let m_count_ger = m_count_ger + l_count1
     end if

     open cbdatr110007 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110007 into m_bdatr110.prpnumpcp

        let l_count2 = l_count2 + 1

     end foreach

     close cbdatr110007

     if l_count2 > 0 then
        let l_count_tot = l_count_tot + l_count2
        let m_count_ger = m_count_ger + l_count2
     end if

     open cbdatr110008 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110008 into m_bdatr110.prpnumpcp

        let l_count3 = l_count3 + 1

     end foreach

     close cbdatr110008

     if l_count3 > 0 then
        let l_count_tot = l_count_tot + l_count3
        let m_count_ger = m_count_ger + l_count3
     end if

     open cbdatr110009 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110009 into m_bdatr110.prpnumpcp

        let l_count4 = l_count4 + 1

     end foreach

     close cbdatr110009

     if l_count4 > 0 then
        let l_count_tot = l_count_tot + l_count4
        let m_count_ger = m_count_ger + l_count4
     end if

     open cbdatr110010 using l_data,
                             m_bdatr110.cademp,
                             m_bdatr110.cadmat
     foreach cbdatr110010 into m_bdatr110.fcapacnum

        let l_count5 = l_count5 + 1

     end foreach

     close cbdatr110010

     if l_count5 > 0 then
        let l_count_tot = l_count_tot + l_count5
        let m_count_ger = m_count_ger + l_count5
     end if

     if l_count_tot > 0 then
        output to report bdatr110_report (m_bdatr110.funnom,
                                          l_count,
                                          l_count1,
                                          l_count2,
                                          l_count3,
                                          l_count4,
                                          l_count5,
                                          l_count_tot)
     end if

     #---[ Inicializa Variaveis ]---#
     let l_count       =  0
     let l_count1      =  0
     let l_count2      =  0
     let l_count3      =  0
     let l_count4      =  0
     let l_count5      =  0
     let l_count_tot   =  0

  end foreach

  if m_lidos = 0 then
     display " Nao foi encontrado nenhum registro !!!"
     exit program(0)
  end if

  finish report bdatr110_report
  display " Arquivo Gerado !!! "

  let l_assunto    = null
  let l_erro_envio = null

  let l_assunto    = "PRODUTIVIDADE DIARIA POR ATENDENTE"
  let l_erro_envio = ctx22g00_envia_email("BDATR110",
                                          l_assunto,
                                          ws_pipe)
  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", ws_pipe
     else
        display "Nao existe email cadastrado para o modulo - BDATR110"
     end if
  end if

  let m_time_end = current
  let m_elapsed  = m_time_end - m_time_begin
#------------------------------------------------------------------------------
end function # bdatr110()
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
function bdatr110_trata_funnom(param)
#------------------------------------------------------------------------------
   define param record
      funnom like isskfunc.funnom
   end record
   define w_l smallint
   define w_funnom like isskfunc.funnom

   let w_l = 1
   while true
     if param.funnom[w_l] = "-" then
        exit while
     end if
     let w_funnom[w_l] = param.funnom[w_l]
     let w_l = w_l + 1
     if w_l > 20 then
        exit while
     end if
   end while

   return w_funnom
end function
#------------------------------------------------------------------------------
report bdatr110_report(param)
#------------------------------------------------------------------------------

  define param record
     funnom    like isskfunc.funnom,
     count     smallint,
     count1    smallint,
     count2    smallint,
     count3    smallint,
     count4    smallint,
     count5    smallint,
     count_tot smallint
  end record

  output
    left   margin 0
    top    margin 0
    bottom margin 3
    page length   63
    order by param.funnom

  format

    first page header

          print "                                PORTO SEGURO CIA DE SEGUROS GERAIS",
                column 90,"Pag.",
                 pageno  using "#####"
          print column 090, "Data: ",l_data
          print column 006, "       RELATORIO DE PRODUTIVIDADE DIARIA POR ATENDENTE       ",
                column 090, "Hora: ",time
          print column 002,'============================================================================================================================'

          print "AGENTE",             ascii(09), # ---> ASCII(09) = TAB
                "ORCAMENTO AUTO",     ascii(09),
                "PROPOSTAS CONVENIO", ascii(09),
                "RS-AUTO",            ascii(09),
                "ORCAMENTOS-RE",      ascii(09),
                "RS-RE",              ascii(09),
                "PAC",                ascii(09),
                "TOTAL",              ascii(09)

    on every row
        print column 001,
              param.funnom    clipped,       ascii(09), # ---> ASCII(09) = TAB
              param.count     using "<<<<&", ascii(09),
              param.count1    using "<<<<&", ascii(09),
              param.count2    using "<<<<&", ascii(09),
              param.count3    using "<<<<&", ascii(09),
              param.count4    using "<<<<&", ascii(09),
              param.count5    using "<<<<&", ascii(09),
              param.count_tot using "<<<<&", ascii(09)

    on last row
          print "TOTAL DE ATENDIMENTO REGISTRADO NO DIA = ",m_count_ger
          skip 02 lines
          print column 002,'============================================================================================================================'

#------------------------------------------------------------------------------
end report # bdatr110_report(param)
#------------------------------------------------------------------------------
#------------------------------------------------#
function bdatr110_envia_email_erro(lr_parametro)
#------------------------------------------------#
  define lr_parametro record
         assunto      char(150),
         msg          char(400)
  end record
  define lr_mail record
          rem     char(50),
          des     char(250),
          ccp     char(250),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
  define l_cod_erro      integer,
         l_msg_erro      char(20)
 initialize lr_mail.* to null
     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = lr_parametro.assunto
     let lr_mail.idr = "bdatr110"
     let lr_mail.tip = "text"
     let lr_mail.msg = lr_parametro.msg
        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro, l_msg_erro
  if l_cod_erro = 0  then
    display l_msg_erro
  else
    display l_msg_erro
  end if
end function