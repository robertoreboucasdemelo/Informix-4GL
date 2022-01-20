#############################################################################
# PROJETO    : FABRICA DE SOFTWARE                                 Raji     #
# PROGRAMA   : bdata094                                            Set/2001 #
# FINALIDADE : ENVIO DE MENSAGENS  (PAGER/E_MAIL)                           #
# AUTOR      : JUNIOR                                                       #
# DATA       : JULHO/2001                                                   #
# HISTORICO  :                                                              #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance             #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws record
        arqtxt    char(15),
        numlin    smallint,
        hora      datetime hour to second
 end record
 globals
   define g_ismqconn smallint
end globals

 define r_dammtrx record like dammtrx.*
 define r_dammtrxtxt record like dammtrxtxt.*
 define r_dammtrxdst record like dammtrxdst.*
 define ws_email     char(800)
 define name_file    char(80)
 define ustcod    like htlrust.ustcod
 define mstastdes like htlmmst.mstastdes
 define msgblc    char (360)
 define ws_errcod integer
 define ws_sqlcod integer
 define ws_mstnum integer
 define w_run     char(500)
 define w_usuario char(300)
 define w_titulo  char(300)
 define f_cmd     char(1500)
 define v_texto   char(360)
 define v_texto1  char(361)

#--------------------------------------------------------------

main

#ambnovo Saymon
call fun_dba_abre_banco('CT24HS')
if  not figrc012_sitename("bdata094","","") then
    exit program(1)
end if
#ambnovo Saymon

call pre_bdata094()
call bdata094()

end main

#--------------------------------------------------------------
function pre_bdata094()
#--------------------------------------------------------------

 let f_cmd = "select  dammtrxtxt.c24trxtxt, dammtrxtxt.c24trxlinnum "
            ,"  from dammtrxtxt "
            ," where dammtrxtxt.c24trxnum  = ? order by 2 "

 prepare s_dammtrxtxt from f_cmd
 declare c_dammtrxtxt cursor for s_dammtrxtxt


 let f_cmd = "select c24msgendtip, c24msgendcod, c24trxdstseq "
            ,"  from dammtrxdst "
            ," where c24trxnum  = ? "

 prepare s_dammtrxdst from f_cmd
 declare c_dammtrxdst cursor for s_dammtrxdst

end function


#--------------------------------------------------------------
function bdata094()
#--------------------------------------------------------------
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
  define l_coderro  smallint
  define msg_erro char(500)
  define m_rel smallint
  let m_rel = false

 declare c_dammtrx cursor for
           select dammtrx.c24trxnum, dammtrx.c24msgtrxstt,
                  dammtrx.c24msgtit, dammtrx.atdsrvnum
             from dammtrx
            where dammtrx.c24msgtrxstt = 1

 open c_dammtrx
 foreach c_dammtrx  into r_dammtrx.c24trxnum    ,
                         r_dammtrx.c24msgtrxstt ,
                         r_dammtrx.c24msgtit    ,
                         r_dammtrx.atdsrvnum

    open    c_dammtrxdst using r_dammtrx.c24trxnum
    foreach c_dammtrxdst into  r_dammtrxdst.c24msgendtip,
                               r_dammtrxdst.c24msgendcod,
                               r_dammtrxdst.c24trxdstseq


       if r_dammtrxdst.c24msgendtip = 2 then ### (pager)
          let v_texto  = null
          let v_texto1 = null
          open  c_dammtrxtxt using  r_dammtrx.c24trxnum
          foreach c_dammtrxtxt into r_dammtrxtxt.c24trxtxt,
                                    r_dammtrxtxt.c24trxlinnum

             let v_texto1 = v_texto clipped
             let v_texto1 = v_texto1 clipped,' ',r_dammtrxtxt.c24trxtxt

             if length(v_texto1) > 360 then

                let ustcod    = r_dammtrxdst.c24msgendcod
                let mstastdes = r_dammtrx.c24msgtit
                let msgblc    = v_texto
                display " Enviando mensagem para , ", ustcod
                call fptla025_usuario(ustcod,
                                      mstastdes,
                                      msgblc,
                                      "5048",
                                      "1",
                                      false,   ###  Nao controla trans
                                      "O",     ###  Online
                                      "M",     ###  Mailtrim
                                      "",      ###  Data Transmissao
                                      "",      ###  Hora Transmissao
                                      "u19")  ###  Maq aplicacao
                            returning ws_errcod,
                                      ws_sqlcod,
                                      ws_mstnum
                if ws_errcod <> 0 then
                   display ws_errcod, ws_sqlcod, ws_mstnum
                else
                   display ws_mstnum
                end if

                let v_texto  = null
                let v_texto1 = null
                let v_texto = v_texto clipped,' ',r_dammtrxtxt.c24trxtxt
             else
                let v_texto = v_texto clipped,' ',r_dammtrxtxt.c24trxtxt
             end if

          end foreach

          if length(v_texto) > 0 then
             let ustcod    = r_dammtrxdst.c24msgendcod
             let mstastdes = r_dammtrx.c24msgtit
             let msgblc    = v_texto
             display " Enviando mensagem para , ", ustcod
             call fptla025_usuario(ustcod,
                                   mstastdes,
                                   msgblc,
                                   "5048",
                                   "1",
                                   false,   ###  Nao controla transacoes
                                   "O",     ###  Online
                                   "M",     ###  Mailtrim
                                   "",      ###  Data Transmissao
                                   "",      ###  Hora Transmissao
                                   "u19")  ###  Maq aplicacao
                         returning ws_errcod,
                                   ws_sqlcod,
                                   ws_mstnum
             if ws_errcod <> 0 then
                display ws_errcod, ws_sqlcod, ws_mstnum
             else
                display ws_mstnum
             end if

             let v_texto  = null
             let v_texto1 = null
          end if
       else         ### (e_mail)
          let ws.arqtxt = 'trx_', r_dammtrx.c24trxnum using "&&&&&&&&"
          let ws.numlin = 0
          open  c_dammtrxtxt using  r_dammtrx.c24trxnum
          foreach c_dammtrxtxt into r_dammtrxtxt.c24trxtxt,
                                    r_dammtrxtxt.c24trxlinnum
             if ws.numlin = 0 then
                start report bdata_01 to ws.arqtxt
             end if

             let m_rel = true
             output to report bdata_01(r_dammtrxtxt.c24trxtxt)

             let ws.numlin = ws.numlin + 1

          end foreach
          if ws.numlin > 0 then
             finish report bdata_01
          end if

          let ws.hora   = current hour to second
          let w_usuario = r_dammtrxdst.c24msgendcod

          if r_dammtrx.c24msgtit = "LAUDO_VIDROS" then
             let w_titulo  = r_dammtrx.c24msgtit clipped,"_",
                             r_dammtrx.atdsrvnum using "&&&&&&&"
             if r_dammtrxdst.c24trxdstseq  =  1   then
                display "** O arquivo ",w_titulo clipped,
                        ", sera enviado as ",ws.hora," para:"
             end if

              #PSI-2013-23297 - Inicio
              let l_mail.de = "c24hs.email@portoseguro.com.br"
              let l_mail.para =  w_usuario
              let l_mail.cc = ""
              let l_mail.cco = ""
              let l_mail.assunto = w_titulo
              let l_mail.mensagem = ""
              let l_mail.id_remetente = "CT24H"
              let l_mail.tipo = "text"
              #PSI-2013-23297 - Fim
          else
             if r_dammtrxdst.c24trxdstseq  =  1   then
                display "** O arquivo ",r_dammtrx.c24msgtit clipped,
                        ", sera enviado as ",ws.hora," para:"
             end if
             #PSI-2013-23297 - Inicio
             let l_mail.de = "c24hs.email@portoseguro.com.br"
             let l_mail.para =  w_usuario
             let l_mail.cc = ""
             let l_mail.cco = ""
             let l_mail.assunto = r_dammtrx.c24msgtit
             let l_mail.mensagem = " "
             let l_mail.id_remetente = "CT24H"
             let l_mail.tipo = "text"
             #PSI-2013-23297 - Fim
          end if
          #PSI-2013-23297 - Inicio
          display "Arquivo: ",ws.arqtxt
          if m_rel = true then
               call figrc009_attach_file(ws.arqtxt)
          else
               let l_mail.mensagem = "Nao existem registros a serem processados."
          end if

          display "Arquivo anexado com sucesso"
          call figrc009_mail_send1 (l_mail.*)
           returning l_coderro,msg_erro
          #PSI-2013-23297 - Fim

          Display "    ",w_usuario clipped

       end if
    end foreach

    let w_run = 'rm -f ', ws.arqtxt clipped
    run w_run

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
end function

report bdata_01(w_imp)

  define w_imp char(80)

  format
     on every row
        print w_imp

end report
