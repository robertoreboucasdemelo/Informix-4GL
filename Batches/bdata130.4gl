#==============================================================================#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : bdata130                                                     #
# Analista Resp : Alberto Rodrigues                                            #
# OSF           : Limpeza da tabela de Ligacoes em Abandono (datkabn),         #
#                 mantendo o historico na tabela de Espelho (datkabnesp).      #
# .............................................................................#
# Desenvolvimento : Nilo Costa                                                 #
# Liberacao       : 28/04/2008                                                 #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#..............................................................................#
database porto


globals  "/homedsa/projetos/geral/globals/glct.4gl"

   define m_arq   char(200),
          m_dir   char(100),
          m_hora  datetime hour to minute

globals
   define g_ismqconn smallint
end globals

  define l_retorno smallint

main

  call fun_dba_abre_banco("CT24HS")

  set lock mode to wait 10
  set isolation to dirty read

  let l_retorno = 0
   call bdata130_prepare()
     returning l_retorno

  begin work

  if l_retorno = 0 then
    call bdata130_processa()

    drop table bdata130_tmp
  end if

end main

#-------------------------#
function bdata130_prepare()
#-------------------------#

  define l_sql      char(1000)
  define l_msg      char(500)
  define l_retorno1 smallint

  let l_sql = " select abnide "
                   ," ,abntel "
                   ," ,condat "
                   ," ,filinidat "
                   ," ,inidat "
                   ," ,pades "
                   ," ,filtmp "
                   ," ,ligdur "
                   ," ,abnfil "
                   ," ,abnsit "
                   ," ,abncont "
                   ," ,conthor "
                   ," ,lignum "
                   ," ,empcod "
                   ," ,usrtip "
                   ," ,funmat "
                   ," ,abninihor "
                   ," ,abnfilinihor "
               ," from datkabn "
              ," where inidat <= ? "

  prepare pbdata130001 from l_sql
  declare cbdata130001 cursor with hold for pbdata130001

  let l_sql = " select max(abnespide) "
               ," from datkabnesp "

  prepare pbdata130002 from l_sql
  declare cbdata130002 cursor for pbdata130002

  let l_sql  = ' insert into datkabnesp ( abnespide, '
                                       ,' abntel, '
                                       ,' condat, '
                                       ,' filinidat, '
                                       ,' inidat, '
                                       ,' pades, '
                                       ,' filtmp, '
                                       ,' ligdur, '
                                       ,' abnfil, '
                                       ,' abnsit, '
                                       ,' abncont, '
                                       ,' conthor, '
                                       ,' lignum, '
                                       ,' empcod, '
                                       ,' usrtip, '
                                       ,' funmat, '
                                       ,' abninihor, '
                                       ,' abnfilinihor, '
                                       ,' abnide ) '
    ,' values(?,?,today,?,?,?,?,?,?,6,"N",current,null,1,"F",999999,?,?,?) '

  prepare pbdata130003 from l_sql

  whenever error continue

  create temp table bdata130_tmp
        (abnide     dec(15,0),
         data       date) with no log

  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " na criacao da tabela temporaria."
     #exit program(1)
     call bdata130_envia_email_erro("AVISO DE ERRO BATCH - bdata130",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  whenever error continue
  create index idx_tmp on bdata130_tmp(data)
  whenever error stop

  let l_sql = " insert into bdata130_tmp(abnide, data) ",
              " values(?,?) "

  prepare pbdata130004 from l_sql

  let l_sql = " select abnide "
               ," from bdata130_tmp "

  prepare pbdata130005 from l_sql
  declare cbdata130005 cursor with hold for pbdata130005

  let l_sql = "delete from datkabn  "
             ," where abnide = ? "

  prepare pbdata130006 from l_sql
return l_retorno1

end function

#--------------------------#
function bdata130_processa()
#--------------------------#

  define lr_espelho   record
         abnide       like datkabn.abnide
        ,abntel       like datkabn.abntel
        ,condat       like datkabn.condat
        ,filinidat    like datkabn.filinidat
        ,inidat       like datkabn.inidat
        ,pades        like datkabn.pades
        ,filtmp       like datkabn.filtmp
        ,ligdur       like datkabn.ligdur
        ,abnfil       like datkabn.abnfil
        ,abnsit       like datkabn.abnsit
        ,abncont      like datkabn.abncont
        ,conthor      like datkabn.conthor
        ,lignum       like datkabn.lignum
        ,empcod       like datkabn.empcod
        ,usrtip       like datkabn.usrtip
        ,funmat       like datkabn.funmat
        ,abninihor    like datkabn.abninihor
        ,abnfilinihor like datkabn.abnfilinihor
  end record

  define lr_aux       record
         abnespide    like datkabnesp.abnespide
  end record

  define l_data_i            date                     # -> DATA INICIAL
  define l_lidos             integer
  define l_lidos_total       integer
  define l_hora              datetime hour to minute

  #---------------------------
  # DEFINE DATAS PARA EXTRACAO
  #---------------------------
  let l_data_i    = arg_val(1) # DATA INICIAL

  let l_lidos          = 0
  let l_lidos_total    = 0
  let lr_aux.abnespide = null
  let l_hora           = null

  if l_data_i is null then
     let l_data_i = today - 1
  end if

  let l_hora = current
  display 'Inicio do Processamento: ', l_hora

  #------------------------------
  # RECUPERA SEQUENCIA DO ESPELHO
  #------------------------------
  open cbdata130002
  fetch cbdata130002 into lr_aux.abnespide

  #-------------------
  # INICIO DA EXTRACAO
  #-------------------
  open cbdata130001 using l_data_i

  foreach cbdata130001 into lr_espelho.abnide
                           ,lr_espelho.abntel
                           ,lr_espelho.condat
                           ,lr_espelho.filinidat
                           ,lr_espelho.inidat
                           ,lr_espelho.pades
                           ,lr_espelho.filtmp
                           ,lr_espelho.ligdur
                           ,lr_espelho.abnfil
                           ,lr_espelho.abnsit
                           ,lr_espelho.abncont
                           ,lr_espelho.conthor
                           ,lr_espelho.lignum
                           ,lr_espelho.empcod
                           ,lr_espelho.usrtip
                           ,lr_espelho.funmat
                           ,lr_espelho.abninihor
                           ,lr_espelho.abnfilinihor

     let l_lidos       = l_lidos + 1
     let l_lidos_total = l_lidos_total + 1

     if lr_aux.abnespide is null or
        lr_aux.abnespide = 0     then
        let lr_aux.abnespide = 1
     else
        let lr_aux.abnespide = lr_aux.abnespide + 1
     end if

     #---------------
     # Insere Espelho
     #---------------
     execute pbdata130003 using lr_aux.abnespide
                               ,lr_espelho.abntel
                               ,lr_espelho.filinidat
                               ,lr_espelho.inidat
                               ,lr_espelho.pades
                               ,lr_espelho.filtmp
                               ,lr_espelho.ligdur
                               ,lr_espelho.abnfil
                               ,lr_espelho.abninihor
                               ,lr_espelho.abnfilinihor
                               ,lr_espelho.abnide

     if sqlca.sqlcode <> 0 then
        display '#------------------------'
        display ' Registro nao inserido. Erro : ' ,sqlca.sqlcode clipped
        display ' lr_espelho.abntel      : ' ,lr_espelho.abntel
        display ' lr_espelho.filinidat   : ' ,lr_espelho.filinidat
        display ' lr_espelho.inidat      : ' ,lr_espelho.inidat
        display ' lr_espelho.pades       : ' ,lr_espelho.pades
        display ' lr_espelho.filtmp      : ' ,lr_espelho.filtmp
        display ' lr_espelho.ligdur      : ' ,lr_espelho.ligdur
        display ' lr_espelho.abnfil      : ' ,lr_espelho.abnfil
        display ' lr_espelho.abninihor   : ' ,lr_espelho.abninihor
        display ' lr_espelho.abnfilinihor: ' ,lr_espelho.abnfilinihor
        display ' lr_espelho.abnide      : ' ,lr_espelho.abnide
        display ' l_lidos_total          : ' ,l_lidos_total
        display '#------------------------'
        continue foreach
        let lr_aux.abnespide = lr_aux.abnespide - 1
     end if

     #-------------------------
     # Insere Tabela Temporaria
     #-------------------------
     execute pbdata130004 using lr_espelho.abnide
                               ,l_data_i

     if sqlca.sqlcode <> 0 then
        display 'Tabela temporaria nao inserida. Erro ',sqlca.sqlcode clipped
        display 'lr_espelho.abnide: ' ,lr_espelho.abnide
     end if

     if l_lidos >= 500 then
        display "LIDOS ATE O MOMENTO: ", l_lidos_total using "<<<<&"
        commit work
        begin work
        let l_lidos = 0
     end if

  end foreach

  close cbdata130001

  display 'TOTAL DE REGISTROS LIDOS: ' ,l_lidos_total

  if l_lidos < 500 then
     commit work
     begin work
  end if

  let lr_espelho.abnide = null
  let l_lidos           = 0
  let l_lidos_total     = 0

  #-------------------------
  # Acessa Tabela Temporaria
  #-------------------------
  open cbdata130005
  foreach cbdata130005 into lr_espelho.abnide

     let l_lidos       = l_lidos + 1
     let l_lidos_total = l_lidos_total + 1

     #-------------------------------------
     # Limpa Tabela de Ligacoes em Abandono
     #-------------------------------------
     execute pbdata130006 using lr_espelho.abnide

     if sqlca.sqlcode <> 0 then
        display '#------------------------------------------------'
        display ' Erro na Limpeza da tab. Abandono.' ,sqlca.sqlcode
        display ' lr_espelho.abnide: ' ,lr_espelho.abnide
        display '#------------------------------------------------'
     end if

     if l_lidos >= 500 then
        display "DELETADOS ATE O MOMENTO: ", l_lidos_total using "<<<<&"
        commit work
        begin work
        let l_lidos = 0
     end if

  end foreach

  display 'TOTAL DE REGISTROS DELETADOS: ' ,l_lidos_total

  if l_lidos < 500 then
     commit work
  end if

  let l_hora = current
  display ''
  display 'Fim do Processamento: ', l_hora

end function
#------------------------------------------------#
function bdata130_envia_email_erro(lr_parametro)
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
     let lr_mail.idr = "bdata130"
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