#############################################################################
# Menu de Modulo: ctc20m07b                                        Jorge    #
#                                                                           #
# Controle de vigencia de penalidade bonificacao                  Nov/2013  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                                                                           #
#############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define am_ctc20m07b   array[30] of record
    vlrrefdat       like dpampstprm.vlrrefdat,
    vlrpgtdat       like dpampstprm.vlrrefdat,
    prtbnfgrpcod    like dpaksrvgrp.prtbnfgrpcod,
    prtbnfgrpdes    like dpaksrvgrp.prtbnfgrpdes,
    pstprmvlr       like dpampstprm.pstprmvlr
end record



define m_qtd_arr     integer


#---------------------------------------------------------------
 function ctc20m07b(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig,
    prtbnfprccod     like dpamprsbnsple.prtbnfprccod,
    prtbnfprcdes     like dpakprtbnfprc.prtbnfprcdes
 end record

 define ws           record
    pstapuobstxt     char(130),
    pstprmvlr        like dpampstprm.pstprmvlr,
    nomgrr           like dpaksocor.nomgrr,
    maides           like dpaksocor.maides,
    confirma         char(1) ,
    operacao         char(1)
 end record

 define arr_aux         integer
 define scr_aux         integer
 define l_msg           char(500)
 define l_mensagem      char(100)
 define l_erro          smallint
 define l_cabec         char(40)

 define l_assunto      char(300),
        l_retorno      integer,
        l_dataref      date,
        l_datastr      char(10),
        l_datapgt      date,
        l_vlrmxmprmsrv decimal(5,2)

 let l_assunto = ""
 let l_retorno = 0
 let l_datapgt = null
 let l_vlrmxmprmsrv = 0


 initialize am_ctc20m07b  to null
 initialize ws.*        to null
 let int_flag  =  false
 let arr_aux   =  1

 ### Determina data base premiacao
 ### Exibe apenas 3 últimos meses de cada Grupo de Serviço
 let l_dataref = today
 let l_datastr = "01", l_datastr[3,10]
 let l_dataref  = l_datastr


 open window w_ctc20m07b at 06,02 with form "ctc20m07b"
      attribute(form line first, comment line last - 2, border)

 display "               INFORMACOES DE PREMIACAO DO PRESTADOR" to cabec

 ## verifica informacoes prestador
 declare c_ctc20m07b005  cursor for
   select nomgrr, maides
     from dpaksocor
     where pstcoddig = param.pstcoddig

  open c_ctc20m07b005

  fetch c_ctc20m07b005 into ws.nomgrr , ws.maides

  close c_ctc20m07b005

  display param.pstcoddig to pstcoddig
  display ws.nomgrr to rspnom


 message "                                              "
 call ctc20m07b_carrega_array(param.pstcoddig, param.prtbnfprccod)

 if not ctc20m07b_verifica_acesso_premio() then
    display array am_ctc20m07b to s_ctc20m07b.*

       on key (interrupt,control-c)
          initialize am_ctc20m07b  to null
          exit display

    end display
 end if

 while true

    call ctc20m07b_carrega_array(param.pstcoddig, param.prtbnfprccod)

    if not ctc20m07b_verifica_acesso_premio() then
       exit while
    end if

    let int_flag = false


    input array am_ctc20m07b  without defaults from  s_ctc20m07b.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          initialize ws.pstapuobstxt to null

          if am_ctc20m07b[arr_aux].vlrrefdat is not null then

             let ws.pstprmvlr = am_ctc20m07b[arr_aux].pstprmvlr

             declare c_ctc20m07b003  cursor for
                select pstapuobstxt
                  from dpampstprm
                  where pstcoddig = param.pstcoddig
                    and prtbnfgrpcod =  am_ctc20m07b[arr_aux].prtbnfgrpcod
                    and vlrrefdat =  am_ctc20m07b[arr_aux].vlrrefdat

             open c_ctc20m07b003

             fetch c_ctc20m07b003 into ws.pstapuobstxt

             close c_ctc20m07b003

             let ws.pstapuobstxt = "MOTIVO: ", ws.pstapuobstxt clipped

          end if

          display am_ctc20m07b[arr_aux].*   to  s_ctc20m07b[scr_aux].*

          display ws.pstapuobstxt to pstapuobstxt

       before field pstprmvlr
          display am_ctc20m07b[arr_aux].pstprmvlr   to
                  s_ctc20m07b[scr_aux].pstprmvlr   attribute (reverse)


       after field pstprmvlr
          display am_ctc20m07b[arr_aux].pstprmvlr   to
                  s_ctc20m07b[scr_aux].pstprmvlr

          if ws.pstprmvlr <>  am_ctc20m07b[arr_aux].pstprmvlr then

             ## se premio for menor que mes atual sistema nao permite mudanca de premio
             if am_ctc20m07b[arr_aux].vlrrefdat < l_dataref then
                error "Nao e possivel alterar premiacao deste periodo"
                next field pstprmvlr
             end if

             ## se valor informado maior que o valor teto cadastrado sistema nao permite alteracao
             declare c_ctc20m07b007  cursor for
                 select grlinf
                  from datkgeral
                  where grlchv = 'PSOVLRMXMPRMSRV'

             open c_ctc20m07b007

             fetch c_ctc20m07b007 into l_vlrmxmprmsrv

             close c_ctc20m07b007

             if am_ctc20m07b[arr_aux].pstprmvlr >  l_vlrmxmprmsrv then
                 error "Valor do Premio informado maior que o valor maximo de premio por servico"
                 next field pstprmvlr
             end if

             let  ws.confirma  =  "N"
             call cts08g01("A","S", "","CONFIRMA A ALTERACAO","DO PREMIO ?","")
                  returning ws.confirma

             if ws.confirma  =  "N"   then
                let am_ctc20m07b[arr_aux].pstprmvlr = ws.pstprmvlr
                display am_ctc20m07b[arr_aux].* to s_ctc20m07b[scr_aux].*
                exit input
             end if


            let l_cabec = "CADASTRO MOTIVO ALTERACAO PREMIO"

            call ctc20m07c_motivo(l_cabec)

               returning ws.pstapuobstxt

            if ws.pstapuobstxt is null then
               error " Por favor informar motivo de alteracao do premio"
               next field  pstprmvlr
            end if

            begin work
               whenever error continue
               update dpampstprm set  (pstprmvlr,
                                       pstapuobstxt)
                                 =    (am_ctc20m07b[arr_aux].pstprmvlr,
                                       ws.pstapuobstxt)
                where pstcoddig = param.pstcoddig
                  and prtbnfgrpcod = am_ctc20m07b[arr_aux].prtbnfgrpcod
                  and vlrrefdat = am_ctc20m07b[arr_aux].vlrrefdat
               whenever error stop

               if sqlca.sqlcode = 0 then
                  commit work
                  let l_msg = "Valor Premio ",
                        am_ctc20m07b[arr_aux].prtbnfgrpdes clipped,
	                " de ", am_ctc20m07b[arr_aux].vlrrefdat,
	                " Alterada de: " , ws.pstprmvlr,
	                " para: ", am_ctc20m07b[arr_aux].pstprmvlr,
	                " Motivo: ", ws.pstapuobstxt clipped

                  call ctc00m02_grava_hist(param.pstcoddig,
                                           l_msg,"A")

                  ##verificando data que alteracao do premio passa a valer
                  if am_ctc20m07b[arr_aux].vlrpgtdat >= today then
                     ##se premio alterado for o que pagamento começa no próximo mês mantém data
                     let l_datapgt = am_ctc20m07b[arr_aux].vlrpgtdat
                  else
                     let l_datapgt = today
                  end if

                  call ctc20m07b_envia_email_pst(l_datapgt, ##data da alteracao do valor
                                                 param.prtbnfprcdes,
                                                 am_ctc20m07b[m_qtd_arr].prtbnfgrpdes,
                                                 ws.pstprmvlr,
                                                 am_ctc20m07b[arr_aux].pstprmvlr,
                                                 ws.pstapuobstxt,
                                                 ws.maides, 
                                                 param.pstcoddig)
               else
                  rollback work
                  error "Nao foi possivel fazer alteracao Premio. Erro: ", sqlca.sqlcode
               end if

            exit input

          end if

      on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false

 close window w_ctc20m07b

end function   ###-- ctc20m07b

#---------------------------------------------------------------
 function ctc20m07b_carrega_array(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig,
    prtbnfprccod     like dpamprsbnsple.prtbnfprccod
 end record


 define ws              record
    prtbnfgrpcod        like dpakbnfgrppar.prtbnfgrpcod,
    prtbnfgrpdes        like dpaksrvgrp.prtbnfgrpdes
 end record

 define l_dataref       date,
        l_datapgt       date,
        l_datastr       char(10),
        l_sql           char(500),
        l_condicao      char(50)


 initialize am_ctc20m07b  to null
 initialize ws  to null
 let m_qtd_arr   =  1

 ### Determina data pesquisa de premiacao
 ### Exibe apenas 3 últimos meses de cada Grupo de Serviço
 let l_dataref = today
 let l_datastr = l_dataref
 let l_datastr = "01", l_datastr[3,10]
 let l_dataref  = l_datastr

 let l_dataref =  l_dataref - 2 units month

 if param.prtbnfprccod = 1 then
    ##AUTO
    let l_condicao = " and dpakbnfgrppar.atdsrvorg not in (9,13)"
 else
    ##RE
    let l_condicao = " and dpakbnfgrppar.atdsrvorg  in (9,13)"
 end if

 let l_sql =  " select distinct dpaksrvgrp.prtbnfgrpcod,",
              "                 dpaksrvgrp.prtbnfgrpdes ",
              "   from dpakbnfgrppar, dpaksrvgrp",
              "    where dpakbnfgrppar.prtbnfgrpcod = dpaksrvgrp.prtbnfgrpcod",
              l_condicao clipped,
              " order by dpaksrvgrp.prtbnfgrpcod"

 prepare p_ctc20m07b001  from l_sql
 declare c_ctc20m07b001  cursor with hold for p_ctc20m07b001

 let l_sql =  "select vlrrefdat,",
              "       pstprmvlr",
              " from dpampstprm",
              "  where pstcoddig = ? ",
              "    and prtbnfgrpcod = ?",
              "    and vlrrefdat >=  ?",
              " order by vlrrefdat "

 prepare p_ctc20m07b002  from l_sql
 declare c_ctc20m07b002  cursor with hold for p_ctc20m07b002


 open c_ctc20m07b001

 foreach c_ctc20m07b001 into ws.prtbnfgrpcod,
                             ws.prtbnfgrpdes

    open c_ctc20m07b002 using  param.pstcoddig,
                               ws.prtbnfgrpcod,
                               l_dataref

    foreach c_ctc20m07b002 into l_dataref,
                             am_ctc20m07b[m_qtd_arr].pstprmvlr



       let l_datapgt = l_dataref + 1 units month


       let am_ctc20m07b[m_qtd_arr].vlrrefdat = l_dataref
       let am_ctc20m07b[m_qtd_arr].vlrpgtdat = l_datapgt
       let am_ctc20m07b[m_qtd_arr].prtbnfgrpdes = ws.prtbnfgrpdes
       let am_ctc20m07b[m_qtd_arr].prtbnfgrpcod = ws.prtbnfgrpcod

       let m_qtd_arr = m_qtd_arr + 1

    end foreach
 end foreach


 call set_count(m_qtd_arr -1)

end function


#------------------------------------------#
 function ctc20m07b_verifica_acesso_premio()
#------------------------------------------#
  define l_status smallint
  define l_sql    char(300)

  let l_sql      = " select 1    ",
                   " from iddkdominio              ",
                   " where cponom = 'PSOALTPRMBNF' ",
                   "   and cpodes = ? "

  prepare p_ctc20m07b004 from l_sql
  declare c_ctc20m07b004 cursor for p_ctc20m07b004

  whenever error continue
  open c_ctc20m07b004 using g_issk.funmat
  fetch c_ctc20m07b004 into l_status
  whenever error stop

  if  sqlca.sqlcode = 0 then
      close c_ctc20m07b004
      return true
  end if

  return false
 end function


 #---------------------------------------------------------------
 function ctc20m07b_envia_email_pst(param)
 #---------------------------------------------------------------

 define param        record
    atldat           date,
    prtbnfprcdes     like dpakprtbnfprc.prtbnfprcdes,
    prtbnfgrpdes     like dpaksrvgrp.prtbnfgrpdes,
    pstprmvlr_ant    like dpampstprm.pstprmvlr,
    pstprmvlr        like dpampstprm.pstprmvlr,
    pstapuobstxt     like dpampstprm.pstapuobstxt,
    maides           like dpaksocor.maides, 
    pstcoddig        like dpaksocor.pstcoddig
 end record

 define lr_mail record
    rem char(50),
    des char(250),
    ccp char(250),
    cco char(250),
    ass char(150),
    msg char(32000),
    idr char(20),
    tip char(4)
 end record

  define l_chave         char(15),
         l_email         char(50),
         l_destinatarios char(500),
         l_assunto       char(100),
         l_msg           char(500),
         l_comando       char(1000),
         l_retorno       smallint,
         l_cod_erro      integer,
         l_msg_erro      char(30)

 let l_chave = "PSOPRMBNFEMAIL"
 let l_email = null
 let l_destinatarios = null
 let l_msg = null

 ## verifica destinatarios na area de negocio
 declare c_ctc20m07b006  cursor for
         select cpodes
           from iddkdominio
          where cponom = l_chave
          order by cpocod

 foreach c_ctc20m07b006 into l_email

         if l_destinatarios is null then
            let l_destinatarios = l_email
         else
            let l_destinatarios = l_destinatarios clipped, ",", l_email
         end if
 end foreach

 if l_destinatarios is null then
    let l_destinatarios = "jorge.modena@portoseguro.com.br"
 end if


 let l_assunto = "Comunicacao Alteracao Valor Premiacao - Prestador ", param.pstcoddig


  let l_msg =       "<html>",
                    "<body>",
                    "<font size =2 face = Verdana>",
                      "Prezado Prestador",
                      "<br><br>",
                      "Para os servi&ccedil;os atendidos a partir de ",
                       param.atldat using "dd/mm/yyyy",
                       " sua bonifica&ccedil;&atilde;o adicional por desempenho de " ,
                       param.prtbnfprcdes clipped,
                       " para servi&ccedil;os ",
                       param.prtbnfgrpdes clipped,
                       " ser&aacute; de R&#36; ",
                       param.pstprmvlr using "<<<,<<&.&&",
                       " , ao inv&eacute;s de R&#36; ",
                       param.pstprmvlr_ant using "<<<,<<&.&&",
                       " , devido ",
                       param.pstapuobstxt clipped,".",
                      "<br><br>",
                      "Atenciosamente,",
                      "<br>",
                      "<b>PORTO SOCORRO </b>",
                    "</font>",
                      "<br><br>",
                    "</body>",
                    "</html>"


 let lr_mail.des = l_destinatarios
 let lr_mail.rem = "porto.socorro@portoseguro.com.br"
 let lr_mail.ccp = ""
 let lr_mail.cco = ""
 let lr_mail.ass = l_assunto
 let lr_mail.idr = "F0110420"
 let lr_mail.tip = "html"
 let lr_mail.msg = l_msg

 call figrc009_mail_send1(lr_mail.*)
         returning l_cod_erro, l_msg_erro


 if l_cod_erro <> 0 then
       error "Nao foi possivel enviar email para Prestador. Erro: ", l_msg_erro , " funcao ctc20m07b_envia_email_pst"
 end if


end function