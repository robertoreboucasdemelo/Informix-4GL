#############################################################################
# Nome do Modulo: CTX14G00                                         Raji     #
#                                                                           #
# Mostra funcoes/Limpa String                                      Set/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Selecionar e fazer um insert na      #
#                            OSF26077  tabela datrligmens.                  #
# 01/04/2004  Amaury         CT 169223 Logica para contemplar dois acessos  #
#                            simultaneos tentando inserir registros na tabela#
#                            dammtrx. Correcao do Chamado: 4025999          #
#---------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32        #
#---------------------------------------------------------------------------#
# 08/03/2010 Adriano Santos   CT10029839 Retirar emails com padrao antigo   #
#---------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo   PSI 000762 Tratamento para Help Desk Casa o   #
#---------------------------------------------------------------------------#
# 28/02/2012 Johnny Alves                Inclusao de tratamento na funcao   #
#            Biztalking                  ctx14g00_retira_caracteres para    #
#                                        retirar ".",";" ou "!"             #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals  '/homedsa/projetos/geral/globals/glct.4gl'

# PSI 175552 - Inicio

define m_prep_sql   smallint

define m_acento array[100] of record
   letra char(01)
end record

define m_array integer
      ,m_array1 integer   #Johnny,Biz

#------------------------------------------------
 function ctx14g00_prepare()
#------------------------------------------------

    define l_sql        char(500)

    let l_sql = 'select dammtrx.c24trxnum, dammtrx.c24msgtrxstt,',
                '       dammtrx.c24msgtit, dammtrx.atdsrvnum, dammtrx.lignum',
                '  from dammtrx ',
                ' where dammtrx.c24trxnum    = ? ',
                '   and dammtrx.c24msgtrxstt = 9'
    prepare p_ctx14g00_001   from l_sql
    declare c_ctx14g00_001   cursor for p_ctx14g00_001

    let l_sql = 'insert into datrligmens (lignum ',
                '                        ,mstnum)',
                'values (?,?)'
    prepare p_ctx14g00_002   from l_sql


    let l_sql = "select cpodes"        ,
                "  from datkdominio "  ,
                " where cponom = ? "
    prepare p_ctx14g00_005 from l_sql
    declare c_ctx14g00_005 cursor with hold for p_ctx14g00_005
    let l_sql = "select count(*) "        ,
                "  from datkdominio "  ,
                " where cponom like 'caractere%' "
    prepare p_ctx14g00_006   from l_sql
    declare c_ctx14g00_006   cursor for p_ctx14g00_006

    let l_sql = "select cpodes"        ,
                "  from datkdominio "  ,
                " where cponom like 'caracter%' "
    prepare p_ctx14g00_007 from l_sql
    declare c_ctx14g00_007 cursor with hold for p_ctx14g00_007

    let m_prep_sql = true

 end function

# PSI 175552 - Fim

#-----------------------------------------------------------
 function ctx14g00(p_ctx14g00)
#-----------------------------------------------------------
   define p_ctx14g00  record
      titulo          char(25),
      popup           char(6000)
   end record

   define a_ctx14g00  array[200] of record
      fundes          char (30)
   end record

   define strpos      smallint
   define strini      smallint
   define scr_aux     smallint
   define arr_aux     smallint
   define fun_des     char (20)


        define  w_pf1   integer

        let     strpos  =  null
        let     strini  =  null
        let     scr_aux  =  null
        let     arr_aux  =  null
        let     fun_des  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctx14g00[w_pf1].*  to  null
        end     for

   open window ctx14g00 at 09,54 with form "ctx14g00"
               attribute(form line 1, border)

   let int_flag = false
   initialize a_ctx14g00   to null

   let arr_aux = 1
   let strini = 1
   let p_ctx14g00.popup = p_ctx14g00.popup clipped
   for strpos = 1 to length(p_ctx14g00.popup)
       if p_ctx14g00.popup[strpos, strpos] = "|" then
          let a_ctx14g00[arr_aux].fundes = p_ctx14g00.popup[strini,strpos-1]
          let strini = strpos + 1
          let arr_aux = arr_aux + 1
       end if
   end for
   let a_ctx14g00[arr_aux].fundes = p_ctx14g00.popup[strini,strpos-1]

   message "(F8)Seleciona"
   call set_count(arr_aux)

   display by name p_ctx14g00.titulo
   display array a_ctx14g00 to s_ctx14g00.*
      on key (interrupt,control-c)
         initialize a_ctx14g00   to null
         let arr_aux = 0
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         exit display
   end display
   close window  ctx14g00
   let int_flag = false

   if arr_aux = 0 then
      let fun_des = ""
   else
      let fun_des = a_ctx14g00[arr_aux].fundes
   end if
   return arr_aux,
          fun_des

 end function  ###  ctx14g00

#-----------------------------------------------------------------------------
 function ctx14g00_limpa(param)
#-----------------------------------------------------------------------------
   define param record
      texto     char(1000),
      sugeira   char(100)
   end record
   define
      conttxt   smallint,
      contsug   smallint

   define ws record
      textoout  char(1000),
      ch        char(1),
      chsug     char(1)
   end record

        let     conttxt  =  null
        let     contsug  =  null

        initialize  ws.*  to  null

   let param.texto   = param.texto clipped
   let param.sugeira = param.sugeira clipped

   for conttxt = 1 to length(param.texto)
       let ws.ch = param.texto [conttxt, conttxt]
       for contsug = 1 to length(param.sugeira)
           let ws.chsug = param.sugeira [contsug, contsug]
           if ws.ch = ws.chsug then
              let ws.ch = " "
              exit for
           end if
       end for
       if conttxt = 1 then
          let ws.textoout = ws.ch
       else
          let ws.textoout = ws.textoout[1, conttxt -1], ws.ch
       end if
   end for
   return ws.textoout
 end function

#-----------------------------------------------------------------------------
 function ctx14g00_msg(param)
#-----------------------------------------------------------------------------
  define param record
     c24msgcod     like dammtrx.c24msgcod,
     lignum        like datmligacao.lignum,
     atdsrvnum     like datmservico.atdsrvnum,
     atdsrvano     like datmservico.atdsrvano,
     c24msgtit     like dammtrx.c24msgtit
  end record
  define ws record
     c24trxnum     like dammtrx.c24trxnum,
     c24msgtit     like dammtrx.c24msgtit
  end record



        initialize  ws.*  to  null

  let ws.c24msgtit = ctx14g00_limpa(param.c24msgtit, " '")

 # Gera numero da transmissao
  select max(c24trxnum)
       into ws.c24trxnum
       from dammtrx
  if  ws.c24trxnum is null then
      let ws.c24trxnum = 0
  end if

  #----> CT 169223 - INICIO
  while true

     let ws.c24trxnum = ws.c24trxnum + 1

     whenever error continue
     insert into dammtrx (c24trxnum,
                          c24msgcod,
                          lignum,
                          atdsrvnum,
                          atdsrvano,
                          c24msgtrxdat,
                          c24msgtrxhor,
                          c24msgtrxstt,
                          c24msgtit)
                values   (ws.c24trxnum,
                          param.c24msgcod,
                          param.lignum,
                          param.atdsrvnum,
                          param.atdsrvano,
                          today,
                          current hour to second,
                          5,             # STATUS EM PROCESSO
                          param.c24msgtit )
     whenever error stop
     if sqlca.sqlcode = 0 then
        exit while
     else
        if sqlca.sqlcode = -268 then
           continue while
        else
           error "Erro ",sqlca.sqlcode using "<<<<<&"
                ," no insert da tabela dammtrx."
                ," ISAM = ",sqlca.sqlerrd[2]  using "<<<<<<&"
           exit program(1)
        end if
     end if
  end while
  #----> CT 169223 - FIM

   return ws.c24trxnum

 end function #ctx14g00_msg

#-----------------------------------------------------------------------------
 function ctx14g00_msgdst(param)
#-----------------------------------------------------------------------------
     define param record
        c24trxnum     like dammtrx.c24trxnum,
        c24msgendcod  like dammtrxdst.c24msgendcod,
        c24msgenddes  like dammtrxdst.c24msgenddes,
        c24msgendtip  like dammtrxdst.c24msgendtip
     end record
     define ws    record
        c24trxdstseq  like dammtrxdst.c24trxdstseq
     end record

     # Gera numero da sequencia do destino na trasmissao


        initialize  ws.*  to  null

     select max(c24trxdstseq)
            into ws.c24trxdstseq
       from dammtrxdst
      where c24trxnum = param.c24trxnum
     if  ws.c24trxdstseq is null then
         let ws.c24trxdstseq = 0
     end if

     #----> CT 169223 - INICIO
     while true

        let ws.c24trxdstseq = ws.c24trxdstseq + 1

        whenever error continue
        insert into dammtrxdst
                    (c24trxnum,
                     c24trxdstseq,
                     c24msgendcod,
                     c24msgenddes,
                     c24msgendtip)
             values (param.c24trxnum,
                     ws.c24trxdstseq,
                     param.c24msgendcod,
                     param.c24msgenddes,
                     param.c24msgendtip)      # 1=email, 2=pager
        whenever error stop
        if sqlca.sqlcode = 0 then
           exit while
        else
           if sqlca.sqlcode = -268 then
              continue while
           else
              error "Erro ",sqlca.sqlcode using "<<<<<&"
                   ," no insert da tabela dammtrxdst."
                   ," ISAM = ",sqlca.sqlerrd[2]  using "<<<<<<&"
              exit program(1)
           end if
        end if
     end while
     #----> CT 169223 - FIM

 end function #ctx14g00_msgdst

#-----------------------------------------------------------------------------
 function ctx14g00_msgtxt(param)
#-----------------------------------------------------------------------------
     define param record
        c24trxnum     like dammtrx.c24trxnum,
        c24trxtxt     like dammtrxtxt.c24trxtxt
     end record
     define ws    record
        c24trxlinnum  like dammtrxtxt.c24trxlinnum
     end record

     # Gera numero da linha do texto


        initialize  ws.*  to  null

     select max(c24trxlinnum)
            into ws.c24trxlinnum
       from dammtrxtxt
      where c24trxnum = param.c24trxnum
     if  ws.c24trxlinnum is null then
         let ws.c24trxlinnum = 0
     end if

     #----> CT 169223 - INICIO
     while true

        let ws.c24trxlinnum = ws.c24trxlinnum + 1

        whenever error continue
        insert into dammtrxtxt
                    (c24trxnum,
                     c24trxlinnum,
                     c24trxtxt)
             values (param.c24trxnum,
                     ws.c24trxlinnum,
                     param.c24trxtxt)
        whenever error stop
        if sqlca.sqlcode = 0 then
           exit while
        else
           if sqlca.sqlcode = -268 then
              continue while
           else
              error "Erro ",sqlca.sqlcode using "<<<<<&"
                   ," no insert da tabela dammtrxtxt."
                   ," ISAM = ",sqlca.sqlerrd[2]  using "<<<<<<&"
              exit program(1)
           end if
        end if
     end while
     #----> CT 169223 - FIM

 end function #ctx14g00_msgtxt
#-----------------------------------------------------------------------------
 function ctx14g00_msgok(param)
#-----------------------------------------------------------------------------
     define param record
        c24trxnum     like dammtrx.c24trxnum
     end record


     update dammtrx
            set c24msgtrxstt = 1   # STATUS DE ENVIO
     where c24trxnum = param.c24trxnum
 end function #ctx14g00_msgok

#-----------------------------------------------------------------------------
 function ctx14g00_envia(param)
#-----------------------------------------------------------------------------
  define param record
         c24trxnum like dammtrx.c24trxnum,
         ext       char(04)
  end record
  define ctx14g00_msg record
         sistema   char(10) ,
         de        char(50) ,
         para      char(300),
         cc        char(300),
         bcc       char(300),
         subject   char(100),
         msg       char(32000),
         arquivo   char(300)
  end record
  define ws record
        arqtxt    char(20),
        numlin    smallint,
        msglog    char(300),
        hora      datetime hour to second,
        data      char(10)
  end record

  define cmd          char(32000)
  define ret          integer
  define r_dammtrx    record like dammtrx.*
  define r_dammtrxtxt record like dammtrxtxt.*
  define r_dammtrxdst record like dammtrxdst.*
  define ws_email     char(800)
  define name_file    char(80)
  define ustcod       like htlrust.ustcod
  define mstastdes    like htlmmst.mstastdes
  define msgblc       char (360)
  define ws_errcod    integer
  define ws_sqlcod    integer
  define ws_mstnum    integer
  define w_run        char(500)
  define w_usuario    char(500)
  define w_usuariocc  char(500)
  define w_titulo     char(300)
  define f_cmd        char(1500)
  define v_texto      char(360)
  define v_texto1     char(361)
  define l_msg_log    char(2000)
  define l_tamanho    integer

# PSI 175552 - Inicio

  define l_erro       smallint
  define titulo1      char(3)

  define  l_mail             record
      de                 char(500)   # De
     ,para               char(10000)  # Para
     ,cc                 char(10000)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
  if m_prep_sql is null or m_prep_sql = false then
     call ctx14g00_prepare()
  end if

# PSI 175552 - Final

        let     l_msg_log   =  null
        let     cmd         =  null
        let     ret         =  null
        let     ws_email    =  null
        let     name_file   =  null
        let     ustcod      =  null
        let     mstastdes   =  null
        let     msgblc      =  null
        let     ws_errcod   =  null
        let     ws_sqlcod   =  null
        let     ws_mstnum   =  null
        let     w_run       =  null
        let     w_usuario   =  null
        let     w_usuariocc =  null
        let     w_titulo    =  null
        let     f_cmd       =  null
        let     v_texto     =  null
        let     v_texto1    =  null
        let     l_tamanho   =  0

        initialize  ctx14g00_msg.*  to  null

        initialize  ws.*  to  null

        initialize  r_dammtrx.*  to  null

        initialize  r_dammtrxtxt.*  to  null

        initialize  r_dammtrxdst.*  to  null

  let f_cmd = "select  dammtrxtxt.c24trxtxt, dammtrxtxt.c24trxlinnum "
             ,"  from dammtrxtxt "
             ," where dammtrxtxt.c24trxnum  = ? order by 2 "
  prepare p_ctx14g00_003 from f_cmd
  declare c_ctx14g00_002 cursor for p_ctx14g00_003

  let f_cmd = "select c24msgendtip, c24msgendcod, c24trxdstseq "
             ,"  from dammtrxdst "
             ," where c24trxnum  = ? "
  prepare p_ctx14g00_004 from f_cmd
  declare c_ctx14g00_003 cursor for p_ctx14g00_004
 #---------------------------------------------------------------------------

## PSI 175552 - Inicio

  let l_erro = false
  let titulo1 = null

  begin work

## PSI 175552 - Final

  open c_ctx14g00_001 using param.c24trxnum            ## PSI 175552
  foreach c_ctx14g00_001 into r_dammtrx.c24trxnum   ,  ## PSI 175552
                          r_dammtrx.c24msgtrxstt ,
                          r_dammtrx.c24msgtit    ,
                          r_dammtrx.atdsrvnum    ,
                          r_dammtrx.lignum          ## PSI 175552

     open    c_ctx14g00_003 using r_dammtrx.c24trxnum
     foreach c_ctx14g00_003 into r_dammtrxdst.c24msgendtip,
                                 r_dammtrxdst.c24msgendcod,
                                 r_dammtrxdst.c24trxdstseq

        if r_dammtrxdst.c24msgendtip = 2 then ### (pager)
           let v_texto  = null
           let v_texto1 = null
           open  c_ctx14g00_002 using  r_dammtrx.c24trxnum
           foreach c_ctx14g00_002 into r_dammtrxtxt.c24trxtxt,
                                     r_dammtrxtxt.c24trxlinnum
              let v_texto1 = v_texto clipped
              let v_texto1 = v_texto1 clipped,' ',r_dammtrxtxt.c24trxtxt

              if length(v_texto1) > 360 then
                 let ustcod    = r_dammtrxdst.c24msgendcod
                 let mstastdes = r_dammtrx.c24msgtit
                 let msgblc    = v_texto
                 #display " Enviando mensagem para , ", ustcod
                 call fptla025_usuario(ustcod,
                                       mstastdes,
                                       msgblc,
                                       "5048",
                                       "1",
                                       false,            ###  Nao controla trans
                                       "O",              ###  Online
                                       "M",              ###  Mailtrim
                                       "",               ###  Data Transmissao
                                       "",               ###  Hora Transmissao
                                       g_issk.maqsgl)    ###  Maq aplicacao
                             returning ws_errcod,
                                       ws_sqlcod,
                                       ws_mstnum

                 if r_dammtrx.c24msgtit = "S67-HELP DESK" or
                    r_dammtrx.c24msgtit = "S68-HELP DESK" then
                    call errorlog("INICIANDO ANALISE ENVIO DE BIP")
                    let l_msg_log = "ustcod: ",    ustcod, "|",
                                    "mstastdes: ", mstastdes clipped, "|",
                                    "msgblc: ",    msgblc clipped,
                                    "g_issk.maqsgl: ", g_issk.maqsgl clipped
                    call errorlog(l_msg_log)

                    let l_msg_log = null
                    let l_msg_log = "ERROS - ws_errcod: ", ws_errcod, "|",
                                            "ws_sqlcod: ",  ws_sqlcod, "|",
                                            "ws_mstnum: ",  ws_mstnum
                    call errorlog(l_msg_log)
                    call errorlog("ENCERRANDO ANALISE ENVIO DE BIP")

                 end if

                 if ws_errcod = 0 then
                    whenever error continue
                    execute p_ctx14g00_002  using r_dammtrx.lignum,
                                                  ws_mstnum
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                       display 'Erro INSERT lignum ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                       let l_erro = true
                       exit foreach
                    end if
                    display ws_mstnum
                 else
                    display ws_errcod, ws_sqlcod, ws_mstnum
                 end if
# PSI 175552 - Final

                 let v_texto  = null
                 let v_texto1 = null
                 let v_texto = v_texto clipped,' ',r_dammtrxtxt.c24trxtxt
              else
                 let v_texto = v_texto clipped,' ',r_dammtrxtxt.c24trxtxt
              end if
           end foreach

## PSI 175552 - Inicio
           if l_erro then
              exit foreach
           end if
## PSI 175552 - Final

           if length(v_texto) > 0 then
              let ustcod    = r_dammtrxdst.c24msgendcod
              let mstastdes = r_dammtrx.c24msgtit
              let msgblc    = v_texto
              #display " Enviando mensagem para , ", ustcod
              call fptla025_usuario(ustcod,
                                    mstastdes,
                                    msgblc,
                                    "5048",
                                    "1",
                                    false,          ###  Nao controla transacoes
                                    "O",            ###  Online
                                    "M",            ###  Mailtrim
                                    "",             ###  Data Transmissao
                                    "",             ###  Hora Transmissao
                                    g_issk.maqsgl)  ###  Maq aplicacao
                          returning ws_errcod,
                                    ws_sqlcod,
                                    ws_mstnum

              if r_dammtrx.c24msgtit = "S67-HELP DESK" or
                 r_dammtrx.c24msgtit = "S68-HELP DESK" then
                 call errorlog("INICIANDO ANALISE ENVIO DE BIP")
                 let l_msg_log = "ustcod: ",    ustcod, "|",
                                 "mstastdes: ", mstastdes clipped, "|",
                                 "msgblc: ",    msgblc clipped,
                                 "g_issk.maqsgl: ", g_issk.maqsgl clipped
                 call errorlog(l_msg_log)

                 let l_msg_log = null
                 let l_msg_log = "ERROS - ws_errcod: ", ws_errcod, "|",
                                         "ws_sqlcod: ", ws_sqlcod, "|",
                                         "ws_mstnum: ", ws_mstnum
                 call errorlog(l_msg_log)
                 call errorlog("ENCERRANDO ANALISE ENVIO DE BIP")

              end if

# PSI 175552 - Inicio
                 if ws_errcod = 0 then
                    whenever error continue
                    execute p_ctx14g00_002  using r_dammtrx.lignum,
                                               ws_mstnum
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
                       display 'Erro INSERT lignum ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                       let l_erro = true
                       exit foreach
                    end if

                    display ws_mstnum
                 else
                    display ws_errcod, ws_sqlcod, ws_mstnum
                 end if
# PSI 175552 - Final

              let v_texto  = null
              let v_texto1 = null
           end if
        else         ### (e_mail)
           initialize ctx14g00_msg to null
           initialize cmd          to null
           if r_dammtrx.c24msgtit = "LAUDO_VIDROS" then
              let w_titulo = r_dammtrx.c24msgtit clipped,"_",
                             r_dammtrx.atdsrvnum using "&&&&&&&"
           else
              let w_titulo = r_dammtrx.c24msgtit clipped
           end if

           call ctx14g00_recupera_caracteres()
           call ctx14g00_recupera_caracteres1()    #Johnny,Biz

           open  c_ctx14g00_002 using  r_dammtrx.c24trxnum
           foreach c_ctx14g00_002 into r_dammtrxtxt.c24trxtxt,
                                       r_dammtrxtxt.c24trxlinnum

              #let r_dammtrxtxt.c24trxtxt  = ctx14g00_retira_caracteres(r_dammtrxtxt.c24trxtxt )

              let r_dammtrxtxt.c24trxtxt = ctx14g00_retira_caracteres1(r_dammtrxtxt.c24trxtxt) #Johnny,Biz


              if r_dammtrxtxt.c24trxtxt is null or
                 r_dammtrxtxt.c24trxtxt = " " then
                 continue foreach
              else
                let ctx14g00_msg.msg = ctx14g00_msg.msg clipped, '<br>',
                                       r_dammtrxtxt.c24trxtxt
              end if


           end foreach

           let w_usuario = r_dammtrxdst.c24msgendcod
           ---[este campo e de 50 posicoes, apos reorg eliminar estas linhas]---
           if  r_dammtrxdst.c24msgendcod[1,17] = "rodrigues_silmara" then
               #let w_usuario = "rodrigues_silmara/spaulo_ct24hs_teleatendimento@u55"
           end if
           if param.ext is not null then
              initialize ws.arqtxt to null
              let ws.arqtxt = r_dammtrx.c24trxnum using "&&&&&&&&",param.ext

              let cmd = "cp ",ws.arqtxt," /home1/arqmail/ct24hs"
              run cmd
              if g_issk.funmat = 601566 then
                 display "** copiei arquivo = ", ws.arqtxt
              end if
              let ctx14g00_msg.sistema = "ct24hs"
              let ctx14g00_msg.de    = "ct24hs.email@portoseguro.com.br"
              let ctx14g00_msg.para  = w_usuario
              let ctx14g00_msg.cc    = ""
              let ctx14g00_msg.subject = w_titulo
              let ctx14g00_msg.arquivo    = ws.arqtxt
              let ctx14g00_msg.msg     = "EXISTE ARQUIVO ANEXO"
              let ws.data              = today
              let ws.hora              = current hour to second

              let cmd = "chmod 777 ",ws.arqtxt
              run cmd

              #PSI-2013-23297 - Inicio

              let l_mail.de = ctx14g00_msg.de
              #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
              let l_mail.para =  ctx14g00_msg.para
              let l_mail.cc = ""
              let l_mail.cco = ""
              let l_mail.assunto = ctx14g00_msg.subject
              let l_mail.mensagem = ctx14g00_msg.msg
              let l_mail.id_remetente = ctx14g00_msg.sistema
              let l_mail.tipo = "html"

              call figrc009_attach_file(ws.arqtxt)
              call figrc009_mail_send1 (l_mail.*)
               returning l_coderro,msg_erro
              #PSI-2013-23297 - Fim

           else  # SEM ARQUIVO ANEXO.

              if w_titulo = "S67-HELP DESK" or
                 w_titulo = "S68-HELP DESK" then
                 let w_titulo = w_titulo clipped, " Maq.", g_issk.maqsgl
              end if

              let ctx14g00_msg.sistema = "ct24hs"
              let ctx14g00_msg.de    = "ct24hs.email@portoseguro.com.br"
              let ctx14g00_msg.para  = w_usuario
              let ctx14g00_msg.cc    = ""
              let ctx14g00_msg.subject = w_titulo
              let ctx14g00_msg.arquivo    = ""
              let ws.data              = today
              let ws.hora              = current hour to second

              #PSI-2013-23297 - Inicio

              let l_mail.de = ctx14g00_msg.de
              #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
              let l_mail.para =  ctx14g00_msg.para
              let l_mail.cc = ""
              let l_mail.cco = ""
              let l_mail.assunto = ctx14g00_msg.subject
              let l_mail.mensagem = ctx14g00_msg.msg
              let l_mail.id_remetente = ctx14g00_msg.sistema
              let l_mail.tipo = "html"
              call figrc009_mail_send1 (l_mail.*)
               returning l_coderro,msg_erro
              #PSI-2013-23297 - Fim
           end if
           let titulo1 = w_titulo[1,3]
           if l_coderro = 0 then
              if r_dammtrxdst.c24trxdstseq  =  1   then
                 let ws.msglog = "** O arquivo ",w_titulo clipped,
                                 param.c24trxnum," foi enviado para: "
                 let f_cmd = "echo '",ws.msglog clipped, "' >> ct24hemail.log"
                 run f_cmd
              end if
             {if (titulo1 = "P01" or titulo1 = "P04" or titulo1 = "P05" or titulo1 = "P06" or
                 titulo1 = "P07" or titulo1 = "P08" or titulo1 = "P09" or titulo1 = "P12" or
                 titulo1 = "P13" or titulo1 = "P15" or titulo1 = "P19" or titulo1 = "P39" or
                 titulo1 = "P40" or titulo1 = "P50" or titulo1 = "P53") then
		               let ctx14g00_msg.para = 'humbertobenedito.santos@portoseguro.com.br'
		               let ctx14g00_msg.cc = 'amiltonlourenco.pinto@portoseguro.com.br'
		               let ctx14g00_msg.para = ctx14g00_msg.para clipped, ',',ctx14g00_msg.cc clipped
		               let cmd="echo '", ctx14g00_msg.msg   clipped, "'| send_email.sh ",
		                      " -sys ", ctx14g00_msg.sistema clipped,
		                      " -r ",   ctx14g00_msg.de    clipped,
		                      " -a ",   ctx14g00_msg.para      clipped,
		                      " -s '",  ctx14g00_msg.subject clipped, "'" #,
		              run cmd returning ret
              end if}
           else
              let ws.msglog = "** Erro no envio arquivo ",w_titulo clipped,
                              ", cod.erro: ",ret
              let f_cmd = "echo '",ws.msglog clipped, "' >> ct24hemail.log"
              run f_cmd
		           {if (titulo1 = "P01" or titulo1 = "P04" or titulo1 = "P05" or titulo1 = "P06" or
		               titulo1 = "P07" or titulo1 = "P08" or titulo1 = "P09" or titulo1 = "P12" or
		               titulo1 = "P13" or titulo1 = "P15" or titulo1 = "P19" or titulo1 = "P39" or
		               titulo1 = "P40" or titulo1 = "P50" or titulo1 = "P53") then
				           let ctx14g00_msg.para = 'humbertobenedito.santos@portoseguro.com.br'
				           let ctx14g00_msg.cc = 'amiltonlourenco.pinto@portoseguro.com.br'
				           let ctx14g00_msg.para = ctx14g00_msg.para clipped, ',',ctx14g00_msg.cc clipped
				           let cmd="echo '", ctx14g00_msg.msg   clipped, "'| send_email.sh ",
				                  " -sys ", ctx14g00_msg.sistema clipped,
				                  " -r ",   ctx14g00_msg.de    clipped,
				                  " -a ",   ctx14g00_msg.para      clipped,
				                  " -s '",  ctx14g00_msg.subject clipped, "'" #,
				           run cmd returning ret
		           end if}
           end if
           let ws.msglog = w_usuario clipped," data: ",ws.data," as ",ws.hora
           let f_cmd     = "echo '",ws.msglog clipped, "' >> ct24hemail.log"
           run f_cmd
        end if
     end foreach
## PSI 175552 - Inicio
     if l_erro then
        exit foreach
     end if
## PSI 175552 - Final
     if r_dammtrxdst.c24msgendtip = 1 then  # e-mail
        -------------------[ remove os arquivos ]------------------------
        if param.ext is not null then
           let cmd = "rm /home1/arqmail/ct24hs/",
                     r_dammtrx.c24trxnum using "&&&&&&&&",param.ext
           run cmd
        end if
     end if
     # Atualiza status para enviado
     update dammtrx
        set (c24msgtrxstt,
             c24msgtrxdat,
             c24msgtrxhor)
          = (2,
             today,
             current hour to minute)
      where c24trxnum    = r_dammtrx.c24trxnum


  end foreach
## PSI 175552 - Inicio
  if l_erro then

     call cts10g13_grava_rastreamento(r_dammtrx.lignum                      ,
                                      '1'                                   ,
                                      'ctx14g00'                            ,
                                      '1'                                   ,
                                      '1- Erro ao Gerar Numero de Mensagem' ,
                                      ' '                                   )



     rollback work
  else

     call cts10g13_grava_rastreamento(r_dammtrx.lignum                      ,
                                      '1'                                   ,
                                      'ctx14g00'                            ,
                                      '0'                                   ,
                                      '2- Mensagem Enviada Com Sucesso'     ,
                                      w_usuario                             )
     commit work
  end if
## PSI 175552 - Final
 end function

#-------------------------------------#
function ctx14g00_TiraAcentos(texto)
#-------------------------------------#
  define texto char(250)

   define l_i, l_j, l_texto, l_acento integer
   define l_caracter char(1)
   define l_especiais,l_limpa,l_textoLimpo  char(200)

   let l_especiais = "´`^~¨&*ÄÅÁÂÀÃäáâàãÉÊËÈéêëèÍÎÏÌíîïìÖÓÔÒÕöóôòõÜÚÛüúûùÇç"
   let l_limpa     = "       AAAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUuuuuCc"
   let l_texto = length (texto)
   let l_acento = length (l_especiais)
   let l_textoLimpo = texto

    for l_i = 1 to l_texto
      let l_caracter = texto[l_i]

      for l_j = 1 to l_acento
         if l_caracter = l_especiais[l_j] then
            let l_textoLimpo[l_i] = l_limpa[l_j]
         end if
      end for

   end for
   return l_textoLimpo clipped

end function



#--------------------------------------------------------------------------
 report bdata_01(w_imp)
#--------------------------------------------------------------------------
   define w_imp char(80)

   format
      on every row
         print w_imp

 end report

#----------------------------------------------#
function ctx14g00_recupera_caracteres()
#----------------------------------------------#

define lr_retorno record
  cponom like datkdominio.cponom
end record

initialize lr_retorno.* to null

for  m_array  =  1  to  100
   initialize  m_acento[m_array].* to  null
end  for


if m_prep_sql is null  or
   m_prep_sql =  false then
   call ctx14g00_prepare()
end if

let lr_retorno.cponom = "caracteres"
let m_array = 1

     open c_ctx14g00_005 using lr_retorno.cponom
     foreach c_ctx14g00_005 into m_acento[m_array].letra
       let m_array = m_array + 1

       if m_array > 100 then
          exit foreach
       end if

     end foreach

     let m_array = m_array - 1

end function

#----------------------------------------------#
function ctx14g00_retira_caracteres(lr_param)
#----------------------------------------------#

define lr_param record
   mensagem char(100)
end record

define lr_retorno record
  qtd          integer  ,
  caracter     char(01) ,
  novamensagem char(100),
  retira       smallint
end record

define arr_aux1 integer
define arr_aux2 integer

initialize lr_retorno.* to null

let lr_retorno.retira = false
let lr_retorno.qtd  = length(lr_param.mensagem)


      if m_array > 0 then

           for arr_aux1 = 1 to lr_retorno.qtd
             let lr_retorno.caracter = lr_param.mensagem[arr_aux1]

             let  lr_retorno.retira = false

             for arr_aux2 = 1 to m_array
                if lr_retorno.caracter = m_acento[arr_aux2].letra then
                     let lr_retorno.retira = true
                     exit for
                end if
             end for

             if not lr_retorno.retira then

                if arr_aux1 = 1 then
                    if lr_param.mensagem[arr_aux1] = " " then
                        let lr_retorno.novamensagem = lr_retorno.novamensagem clipped, " ", lr_retorno.caracter
                    else
                        let lr_retorno.novamensagem = lr_retorno.novamensagem clipped, lr_retorno.caracter
                    end if
                else
                    if lr_param.mensagem[arr_aux1 - 1] = " " then
                        let lr_retorno.novamensagem = lr_retorno.novamensagem clipped, " ", lr_retorno.caracter
                    else
                        let lr_retorno.novamensagem = lr_retorno.novamensagem clipped, lr_retorno.caracter
                    end if
                end if

             end if

           end for

      end if

     return lr_retorno.novamensagem

end function

#------------------------------------------------------------------------------#
function ctx14g00_recupera_caracteres1()                   #Johnny,Biz
#------------------------------------------------------------------------------#

   define lr_retorno    record
          cponom        like datkdominio.cponom
   end record

   initialize lr_retorno.* to null

   for  m_array1  =  1  to  100
      initialize  m_acento[m_array1].* to  null
   end  for


   if m_prep_sql is null  or
      m_prep_sql =  false then
      call ctx14g00_prepare()
   end if

   let lr_retorno.cponom = "caracteres1"
   let m_array = 1

        open c_ctx14g00_005 using lr_retorno.cponom
        foreach c_ctx14g00_005 into m_acento[m_array1].letra
          let m_array1 = m_array1 + 1

          if m_array1 > 100 then
             exit foreach
          end if

        end foreach

        let m_array1 = m_array1 - 1

end function

#------------------------------------------------------------------------------#
function ctx14g00_retira_caracteres1(lr_param)             #Johnny,Biz
#------------------------------------------------------------------------------#

   define lr_param record
          mensagem char(100)
   end record

   define lr_retorno record
          caracter     char(01)
         ,novamensagem char(100)
         ,retira       smallint
   end record

   define arr_aux3     integer
   define arr_aux4     integer
   define l_sql        char(500)
   define l_qtd_caract smallint
   define l_cponom     char(11)
   define l_i          smallint
   define l_qtd        smallint
   define l_char       char(100)
   define l_a          smallint
   define l_primeiro   smallint
   define l_nv_tamanho smallint

   initialize lr_retorno.* to null

   let lr_retorno.retira = false
   let l_qtd  = length(lr_param.mensagem)

   let m_array = 1

    #---- Quantidade de caracteres especiais cadastrados ----#
    open c_ctx14g00_006
    whenever error continue
    fetch c_ctx14g00_006 into l_qtd_caract
    whenever error stop
    if sqlca.sqlcode <> 0 then
       display "Erro SELECT (c_ctx14g00_006) SQLCODE: ",sqlca.sqlcode
    end if

     #---- Carrega caracteres ----#
     open c_ctx14g00_007
     foreach c_ctx14g00_007 into m_acento[m_array].letra
        let m_array = m_array + 1
     end foreach

    for arr_aux4 = 1 to l_qtd
       for l_i = 1 to l_qtd_caract
          if lr_param.mensagem[arr_aux4] = m_acento[l_i].letra then
             let lr_param.mensagem[arr_aux4] = ""
             exit for
          else
             continue for
          end if
       end for
    end for

    for l_a = 1 to l_qtd
      if lr_param.mensagem[l_a,l_a +1] = "  " then
         if l_primeiro = 0 then
            let lr_param.mensagem = lr_param.mensagem[1,l_a] clipped
                                   ,lr_param.mensagem[l_a+1,l_qtd]
            let l_primeiro = 1
         else
            let l_nv_tamanho = length(lr_param.mensagem)
            if l_a + 1 > l_nv_tamanho then
               exit for
            end if
            let lr_param.mensagem = lr_param.mensagem[1,l_a] clipped
                                   ,lr_param.mensagem[l_a+1,l_nv_tamanho]
         end if
      end if
   end for

   let lr_retorno.novamensagem = lr_param.mensagem

   return lr_retorno.novamensagem

end function





















