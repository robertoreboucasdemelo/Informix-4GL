#############################################################################
# Menu de Modulo: ctc20m07a                                        Jorge    #
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

define am_ctc20m07a   array[30] of record
    bnspleviginidat   like dpamprsbnsple.bnspleviginidat,
    bnsplevigfnldat   like dpamprsbnsple.bnsplevigfnldat,
    regatldat        like dpamprsbnsple.regatldat   ,
    altfunnom        char(30)
end record

define m_qtd_arr     integer


#---------------------------------------------------------------
 function ctc20m07a(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig,
    prtbnfprccod     like dpamprsbnsple.prtbnfprccod,
    prtbnfprcdes     like dpakprtbnfprc.prtbnfprcdes
 end record

 define ws           record
    bnspleviginidat  like dpamprsbnsple.bnspleviginidat,
    bnspleviginidat2 like dpamprsbnsple.bnspleviginidat,
    bnsplevigfnldat  like dpamprsbnsple.bnsplevigfnldat,
    plemtvtxt        char(130),
    nomgrr           like dpaksocor.nomgrr          ,
    maides           like dpaksocor.maides          ,
    empcod           like dpamprsbnsple.empcod      ,
    usrmatnum        like dpamprsbnsple.usrmatnum   ,
    confirma         char(1)                        ,
    operacao         char(1)
 end record

 define arr_aux      integer
 define scr_aux      integer
 define l_arr_count  integer
 define l_msg        char(500)
 define l_mensagem   char(100)
 define l_erro       smallint
 define l_cabec      char(40)


 define l_assunto char(300)
 define l_retorno integer

 let l_assunto = ""
 let l_retorno = 0


 initialize am_ctc20m07a  to null
 initialize ws.*        to null
 let int_flag  =  false
 let arr_aux   =  1

 open window w_ctc20m07a at 06,02 with form "ctc20m07a"
      attribute(form line first, comment line last - 2, border)

 display "         INFORME SE ESTE PRESTADOR POSSUI ALGUMA PENALIDADE" to cabec

 declare c_ctc20m07a003  cursor for
   select nomgrr, maides
     from dpaksocor
     where pstcoddig = param.pstcoddig

  open c_ctc20m07a003

  fetch c_ctc20m07a003 into ws.nomgrr, ws.maides

  close c_ctc20m07a003

  display param.pstcoddig to pstcoddig
  display ws.nomgrr to rspnom

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona                          "
 else
    message " (F17)Abandona, (F2)Exclui  "
 end if

 call ctc20m07a_carrega_array(param.pstcoddig, param.prtbnfprccod)

 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array am_ctc20m07a to s_ctc20m07a.*

       on key (interrupt,control-c)
          initialize am_ctc20m07a  to null
          exit display

    end display
 end if

 #---------------------------------------------------------------
 # Nivel de acesso para consulta/atualizacao
 #---------------------------------------------------------------
 while true

    call ctc20m07a_carrega_array(param.pstcoddig, param.prtbnfprccod)

    if g_issk.acsnivcod  <  g_issk.acsnivatl   then
       exit while
    end if

    let int_flag = false


    input array am_ctc20m07a  without defaults from  s_ctc20m07a.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          let l_arr_count = arr_count()
          let ws.plemtvtxt = ""

          if arr_aux <= l_arr_count  then
             let ws.operacao  =  "a"
             let ws.bnspleviginidat    =  am_ctc20m07a[arr_aux].bnspleviginidat
             let ws.bnsplevigfnldat    =  am_ctc20m07a[arr_aux].bnsplevigfnldat
          else
             let ws.operacao = "i"
             initialize am_ctc20m07a[arr_aux]     to null
             initialize ws.bnspleviginidat        to null
             initialize ws.bnspleviginidat2       to null
             initialize ws.bnsplevigfnldat        to null
             initialize ws.plemtvtxt              to null
             initialize ws.empcod                 to null
             initialize ws.usrmatnum              to null
          end if

          if ws.bnspleviginidat is null or
             ws.bnsplevigfnldat is null then
             let ws.operacao = "i"
          else
             declare c_ctc20m07a002  cursor for
             select plemtvtxt
               from dpamprsbnsple
              where pstcoddig  =  param.pstcoddig
                and prtbnfprccod = param.prtbnfprccod
                and bnspleviginidat = am_ctc20m07a[arr_aux].bnspleviginidat

             open c_ctc20m07a002

             fetch c_ctc20m07a002 into ws.plemtvtxt

             close c_ctc20m07a002

             let ws.plemtvtxt = "MOTIVO: ", ws.plemtvtxt  clipped

          end if

          display ws.plemtvtxt to plemtvtxt

       before field bnspleviginidat
          display am_ctc20m07a[arr_aux].bnspleviginidat   to
                  s_ctc20m07a[scr_aux].bnspleviginidat   attribute (reverse)


       after field bnspleviginidat
          display am_ctc20m07a[arr_aux].bnspleviginidat   to
                  s_ctc20m07a[scr_aux].bnspleviginidat

          if (fgl_lastkey() = fgl_keyval("right")    or
              fgl_lastkey() = fgl_keyval("down")     or
              fgl_lastkey() = fgl_keyval("return"))  then

             if am_ctc20m07a[arr_aux].bnspleviginidat  is null   then
                error " Data inicial deve ser informada!"
                next field bnspleviginidat
             end if

             if ws.operacao                 <>  "i"         and
                am_ctc20m07a[arr_aux].bnspleviginidat  <>  ws.bnspleviginidat   then
                error " Data inicial nao deve ser alterada!"
                next field bnspleviginidat
             end if

             if am_ctc20m07a[arr_aux].bnspleviginidat  >  today + 30 units day   then
                error " Data inicial nao deve ser superior a 30 dias!"
                next field bnspleviginidat
             end if

             if ws.bnspleviginidat    <>  am_ctc20m07a[arr_aux].bnspleviginidat or
                ws.bnspleviginidat is null then
                if am_ctc20m07a[arr_aux].bnspleviginidat  <  today  then
                   error " Data inicial nao deve ser inferior a data atual!"
                   next field bnspleviginidat
                end if
             end if

             if ws.operacao  =   "i"  or
                ws.bnspleviginidat    <>  am_ctc20m07a[arr_aux].bnspleviginidat   then

                select 1
                  from dpamprsbnsple
                 where dpamprsbnsple.pstcoddig  =  param.pstcoddig
                   and dpamprsbnsple.prtbnfprccod = param.prtbnfprccod
                   and am_ctc20m07a[arr_aux].bnspleviginidat  between bnspleviginidat and bnsplevigfnldat

                if sqlca.sqlcode  =  0   then
                   error " Data inicial ja' compreendida em outro periodo!"
                   next field  bnspleviginidat
                end if

             end if
          else
             let ws.operacao  = " "
             let l_arr_count  = l_arr_count - 1
          end if

       before field bnsplevigfnldat
          display am_ctc20m07a[arr_aux].bnsplevigfnldat   to
                  s_ctc20m07a[scr_aux].bnsplevigfnldat   attribute (reverse)

       after field bnsplevigfnldat
          display am_ctc20m07a[arr_aux].bnsplevigfnldat   to
                  s_ctc20m07a[scr_aux].bnsplevigfnldat

          if (fgl_lastkey() = fgl_keyval("right")    or
              fgl_lastkey() = fgl_keyval("down")     or
              fgl_lastkey() = fgl_keyval("return"))  then

             if am_ctc20m07a[arr_aux].bnsplevigfnldat  is null   then
                error " Data final deve ser informada!"
                next field bnsplevigfnldat
             end if

             if ws.bnsplevigfnldat    <>  am_ctc20m07a[arr_aux].bnsplevigfnldat or
                 ws.bnsplevigfnldat is null then
                if am_ctc20m07a[arr_aux].bnsplevigfnldat  <  am_ctc20m07a[arr_aux].bnspleviginidat   then
                  error " Data final nao deve ser menor a data inicial!"
                  next field bnsplevigfnldat
                end if
             end if


             if ws.operacao  =   "i"                          or
                ws.bnsplevigfnldat    <>  am_ctc20m07a[arr_aux].bnsplevigfnldat   then

                select bnspleviginidat
                  into ws.bnspleviginidat2
                  from dpamprsbnsple
                 where dpamprsbnsple.pstcoddig  =  param.pstcoddig
                   and dpamprsbnsple.prtbnfprccod = param.prtbnfprccod
                   and am_ctc20m07a[arr_aux].bnsplevigfnldat  between bnspleviginidat and bnsplevigfnldat

                if sqlca.sqlcode  =   0                            and
                   ws.bnspleviginidat2     <>  am_ctc20m07a[arr_aux].bnspleviginidat   then
                   error " Data final ja' compreendida em outro periodo!"
                   next field  bnsplevigfnldat
                end if

                select 1
                  from dpamprsbnsple
                 where dpamprsbnsple.pstcoddig  =  param.pstcoddig
                   and dpamprsbnsple.prtbnfprccod = param.prtbnfprccod
                   and dpamprsbnsple.bnspleviginidat     >  am_ctc20m07a[arr_aux].bnspleviginidat
                   and dpamprsbnsple.bnsplevigfnldat     <  am_ctc20m07a[arr_aux].bnsplevigfnldat

                if sqlca.sqlcode  =  0   then
                   error " Data ja' compreendida em outro periodo!"
                   next field  bnsplevigfnldat
                end if

             end if

             let l_cabec = "CADASTRO MOTIVO PENALIDADE"

             #verifica se exibe tela de Motivo para cadastro ou nao
             if ws.operacao  =   "i"  then
                call ctc20m07c_motivo(l_cabec)
                   returning ws.plemtvtxt

                if ws.plemtvtxt is null then
                   error " Por favor informar motivo de penalidade"
                   next field  bnsplevigfnldat
                end if
             else
                if ws.operacao = "a" and
                   ws.bnsplevigfnldat <> am_ctc20m07a[arr_aux].bnsplevigfnldat then
                      call ctc20m07c_motivo(l_cabec)
                   returning ws.plemtvtxt

                   if ws.plemtvtxt is null then
                      error " Por favor informar motivo de penalidade"
                      next field  bnsplevigfnldat
                   end if

                end if
             end if
          else
             let ws.operacao  = " "
             let l_arr_count  = l_arr_count - 1
          end if

       after row

             case ws.operacao
               when "i"
                 begin work

                    insert into dpamprsbnsple    ( pstcoddig,
                                                   prtbnfprccod,
                                                   bnspleviginidat,
                                                   bnsplevigfnldat,
                                                   plemtvtxt,
                                                   empcod,
                                                   usrmatnum,
                                                   regatldat )
                                        values   ( param.pstcoddig,
                                                   param.prtbnfprccod,
                                                   am_ctc20m07a[arr_aux].bnspleviginidat,
                                                   am_ctc20m07a[arr_aux].bnsplevigfnldat,
                                                   ws.plemtvtxt,
                                                   g_issk.empcod,
                                                   g_issk.funmat,
                                                   today)

                 commit work

                 let am_ctc20m07a[arr_aux].regatldat = today


                 display am_ctc20m07a[arr_aux].regatldat      to
                         s_ctc20m07a[scr_aux].regatldat

                 call ctc20m07a_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
                      returning am_ctc20m07a[arr_aux].altfunnom

                 display am_ctc20m07a[arr_aux].altfunnom to s_ctc20m07a[scr_aux].altfunnom

                 let l_msg = "Penalidade ",
		             am_ctc20m07a[arr_aux].bnspleviginidat,"-",
			     am_ctc20m07a[arr_aux].bnsplevigfnldat, " Incluida. ",
			     "Motivo: ",ws.plemtvtxt clipped

                 call ctc00m02_grava_hist(param.pstcoddig,
                                          l_msg,"I")

                 call ctc20m07a_envia_email_pst(am_ctc20m07a[arr_aux].bnspleviginidat,
                                                am_ctc20m07a[arr_aux].bnsplevigfnldat,
                                                ws.plemtvtxt,
                                                ws.maides, 
                                                param.pstcoddig)



                 exit input

               when "a"

                 ##verifica se houve alteracao de algum campo
                 if ws.bnsplevigfnldat <> am_ctc20m07a[arr_aux].bnsplevigfnldat then

                    begin work
                       update dpamprsbnsple set    ( bnsplevigfnldat,
                                                     plemtvtxt,
                                                     regatldat,
                                                     empcod,
                                                     usrmatnum )
                                                =  ( am_ctc20m07a[arr_aux].bnsplevigfnldat,
                                                     ws.plemtvtxt,
                                                     today,
                                                     g_issk.empcod,
                                                     g_issk.funmat )
                        where dpamprsbnsple.pstcoddig = param.pstcoddig
                          and dpamprsbnsple.prtbnfprccod = param.prtbnfprccod
                          and dpamprsbnsple.bnspleviginidat    = am_ctc20m07a[arr_aux].bnspleviginidat

                    commit work

                    let l_msg = "Vigencia Penalidade ",
		                ws.bnspleviginidat,"-", ws.bnsplevigfnldat,
		                " Alterada para: " ,
		                am_ctc20m07a[arr_aux].bnspleviginidat,"-", am_ctc20m07a[arr_aux].bnsplevigfnldat,
		                " Motivo: ", ws.plemtvtxt clipped

                    call ctc00m02_grava_hist(param.pstcoddig,
                                             l_msg,"A")

                    call ctc20m07a_envia_email_pst(am_ctc20m07a[arr_aux].bnspleviginidat,
                                                am_ctc20m07a[arr_aux].bnsplevigfnldat,
                                                ws.plemtvtxt,
                                                ws.maides,
                                                param.pstcoddig)

                    exit input
                 end if

             end case

      on key (interrupt)
          exit input


      on key (f2)


         if am_ctc20m07a[arr_aux].bnspleviginidat  is null   then
            continue input
         else
            if am_ctc20m07a[arr_aux].bnspleviginidat <= today then
               error " Penalidade não pode ser excluida, pois penalidade já está em vigor"

            else
               let  ws.confirma  =  "N"
               call cts08g01("A","S", "","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                    returning ws.confirma

               if ws.confirma  =  "N"   then
                  display am_ctc20m07a[arr_aux].* to s_ctc20m07a[scr_aux].*
                  exit input
               end if

               begin work
                  delete
                    from dpamprsbnsple
                   where dpamprsbnsple.pstcoddig        =  param.pstcoddig
                     and dpamprsbnsple.prtbnfprccod     = param.prtbnfprccod
                     and dpamprsbnsple.bnspleviginidat  =  am_ctc20m07a[arr_aux].bnspleviginidat
               commit work

               let l_msg = "Penalidade ",
		           am_ctc20m07a[arr_aux].bnspleviginidat,"-",
		   	   am_ctc20m07a[arr_aux].bnsplevigfnldat, " Deletada. "

               call ctc00m02_grava_hist(param.pstcoddig,
                                        l_msg,"E")

               initialize am_ctc20m07a[arr_aux].* to null
               display    am_ctc20m07a[arr_aux].* to s_ctc20m07a[scr_aux].*
               exit input
            end if
         end if



    end input

    if int_flag   then
       exit while
    end if



 end while

 let int_flag = false

 close window w_ctc20m07a

end function   ###-- ctc20m07a


#---------------------------------------------------------
function ctc20m07a_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 define l_sql         char(200)

 initialize ws.*    to null

 let l_sql = " select funnom    "
            ," from isskfunc    "
            ," where empcod = ? "
            ,"   and funmat = ? "
            ,"   and usrtip = ? "
 prepare pctc20m07a006 from l_sql
 declare cctc20m07a006 cursor for pctc20m07a006

 open cctc20m07a006 using param.empcod, param.funmat, param.usrtip
 fetch cctc20m07a006 into ws.funnom
 if sqlca.sqlcode  =  notfound   then
    error "Problemas ao buscar nome do funcionario do cadastro do tipo de natureza!"
 end if

 return ws.funnom

end function   # ctc20m07a_func

#---------------------------------------------------------------
 function ctc20m07a_carrega_array(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig,
    prtbnfprccod     like dpamprsbnsple.prtbnfprccod
 end record

 define ws           record
    empcod           like dpamprsbnsple.empcod      ,
    usrmatnum        like dpamprsbnsple.usrmatnum
 end record

 initialize am_ctc20m07a  to null
 initialize ws  to null
 let m_qtd_arr   =  1

 declare c_ctc20m07a001  cursor for
   select dpamprsbnsple.bnspleviginidat,
          dpamprsbnsple.bnsplevigfnldat,
          dpamprsbnsple.empcod,
          dpamprsbnsple.usrmatnum,
          dpamprsbnsple.regatldat
     from dpamprsbnsple
    where dpamprsbnsple.pstcoddig  =  param.pstcoddig
      and dpamprsbnsple.prtbnfprccod = param.prtbnfprccod
    order by bnspleviginidat desc


 foreach c_ctc20m07a001 into am_ctc20m07a[m_qtd_arr].bnspleviginidat,
                             am_ctc20m07a[m_qtd_arr].bnsplevigfnldat,
                             ws.empcod                       ,
                             ws.usrmatnum                    ,
                             am_ctc20m07a[m_qtd_arr].regatldat


    call ctc20m07a_func (ws.empcod , ws.usrmatnum, g_issk.usrtip)
         returning am_ctc20m07a[m_qtd_arr].altfunnom

    let m_qtd_arr = m_qtd_arr + 1
    if m_qtd_arr  >  30   then
       error " Limite excedido, prestador com mais de 30 penalidades!"
       exit foreach
    end if

 end foreach

 call set_count(m_qtd_arr-1)



end function


 #---------------------------------------------------------------
 function ctc20m07a_envia_email_pst(param)
 #---------------------------------------------------------------

 define param        record
    dataini           date,
    datafim           date,
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


 let l_assunto = "Comunicado sobre a premiacao - Prestador ", param.pstcoddig       

 let l_msg = "<html>",
              "<body>",
              "<font size =2 face = Verdana>",
                "Prezado Prestador",
                "<br><br>",
                "Para os servi&ccedil;os atendidos entre ",
                param.dataini using "dd/mm/yyyy",
                " e " ,
                param.datafim using "dd/mm/yyyy",
                ", n&atilde;o ser&aacute; atribu&iacute;do nenhum  valor de Premio devido: ",
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
    error "Nao foi possivel enviar email para Prestador. Erro: ", l_retorno , " funcao ctc20m07b_envia_email_pst"
 end if

end function