#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: ctx22g00.4gl                                              #
# Analista Resp..: Carlos Zyon                                               #
# PSI/OSF........: 185.035 / 36870                                           #
# Objetivo.......: Enviar email's parametrizados.                            #
#............................................................................#
# Desenvolvimento: Meta, Bruno Gama                                          #
# Liberacao......: 28/06/2004                                                #
#............................................................................#
#                        * * *  ALTERACOES  * * *                            #
# -------------------------------------------------------------------------- #
#............................................................................#
database porto

define m_prep_sql   smallint

#=============================================================================
 function ctx22g00_prepare()
#=============================================================================

  define l_sql        char(300)

     let l_sql = " select relpamtxt "
                ,"   from igbmparam "
                ,"  where relsgl = ? "
     prepare p_ctx22g00_001 from l_sql
     declare c_ctx22g00_001 cursor for p_ctx22g00_001
  let m_prep_sql = true

 end function

#=============================================================================
 function ctx22g00_envia_email(lr_param)
#=============================================================================
 define lr_param    record
    modulo          like igbmparam.relsgl
   ,assunto         char(300)
   ,anexo           char(300)
 end record
 define l_retorno   smallint
 define l_comando   char(2000)
 define l_email     like igbmparam.relpamtxt
 define l_destino   char(1500)

 ### PSI-2013-23333/EV - INICIO
 #---> Variaves para:
 #     remover (comentar) forma de envio de e-mails anterior e inserir
 #     novo componente para envio de e-mails.
 #---> feito por Rodolfo Massini (F0113761) em dez/2013

 define lr_mail record
        rem char(50),
        des char(10000),
        ccp char(10000),
        cco char(10000),
        ass char(500),
        msg char(32000),
        idr char(20),
        tip char(4)
 end record

 define l_mensagem_erro  char(20)
       ,l_ret_figrc009   integer

 initialize lr_mail
           ,l_mensagem_erro
           ,l_ret_figrc009
 to null

 ### PSI-2013-23333/EV - FIM

 let l_destino = null
 let l_comando = null
 let l_email = null
  let l_retorno = 0

 if m_prep_sql <> true or
    m_prep_sql is null then
    call ctx22g00_prepare()
 end if

 open c_ctx22g00_001 using lr_param.modulo
 foreach c_ctx22g00_001 into l_email
    if l_destino is null then
       let l_destino = l_email
    else
       let l_destino = l_destino clipped,',',l_email
    end if
 end foreach

 if l_destino is not null then

    ### PSI-2013-23333/EV - INICIO
    #---> remover (comentar) forma de envio de e-mails anterior e inserir
    #     novo componente para envio de e-mails.
    #---> feito por Rodolfo Massini (F0113761) em dez/2013

    #let l_comando = ' echo "',lr_param.modulo clipped, '" | send_email.sh ',
    #                ' -a    ',l_destino clipped,
    #                ' -s   "',lr_param.assunto clipped, '" ',
    #                ' -f    ',lr_param.anexo clipped
    #run l_comando returning l_retorno

    let lr_mail.des = l_destino clipped
    let lr_mail.ass = lr_param.assunto clipped
    let lr_mail.msg = lr_param.modulo clipped
    let lr_mail.tip = "text"
    let lr_mail.idr = "P0603000"
    let lr_mail.rem = 'portosocorro@portoseguro.com.br'

    if ((lr_param.anexo is not null) and (lr_param.anexo <> " ")) then
       call figrc009_attach_file(lr_param.anexo)
    end if

    call figrc009_mail_send1(lr_mail.*)
         returning l_ret_figrc009, l_mensagem_erro

    let l_retorno = l_ret_figrc009

    ### PSI-2013-23333/EV - FIM

 else
    let l_retorno = 99
 end if

 return l_retorno

 end function

### PSI-2013-23333/EV - INICIO
#---> funcao nova para envio de e-mails atraves da funcao FIGRC009, esta funcao
#     e semelhante a funcao "ctx22g00_envia_email" alterando apenas os
#     parametros
#---> feito por Rodolfo Massini (F0113761) em dez/2013

#=============================================================================
 function ctx22g00_envia_email_overload(lr_param, l_anexo)
#=============================================================================

 define lr_param record
         rem     char(50)
        ,des     char(10000)
        ,ccp     char(10000)
        ,cco     char(10000)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
 end record

 define l_anexo         char(300)
       ,l_retorno       smallint
       ,l_ret_figrc009  integer
       ,l_mensagem_erro char(20)

 initialize l_mensagem_erro
           ,l_ret_figrc009
 to null

 let l_retorno = 0

 if lr_param.des is not null then
 
    if ((lr_param.msg is null) or (lr_param.msg = " ")) then
       if ((lr_param.ass is not null) or (lr_param.ass <> " ")) then
          let lr_param.msg = lr_param.ass
       else
          let lr_param.msg = "." 
       end if
    end if
    
    if ((lr_param.rem is null) or (lr_param.rem = " ")) then
       let lr_param.rem = 'porto.socorro@portoseguro.com.br'
    end if
    
    if ((lr_param.idr is null) or (lr_param.idr = " ")) then
       let lr_param.idr = "P0603000" 
    end if    

    if ((l_anexo is not null) and (l_anexo <> "")) then
       call figrc009_attach_file(l_anexo)
    end if

    call figrc009_mail_send1(lr_param.*)
         returning l_ret_figrc009, l_mensagem_erro

    let l_retorno = l_ret_figrc009

 else

    let l_retorno = 99

 end if

 return l_retorno

 end function

 ### PSI-2013-23333/EV - FIM

### RODOLFO MASSINI - INICIO
#---> funcao nova para envio de e-mails atraves da funcao FIGRC009, esta funcao
#     e semelhante a funcao "ctx22g00_envia_email" alterando apenas os
#     parametros e permitindo multiplos anexos
#---> feito por Rodolfo Massini (F0113761) em maio/2014

#=============================================================================
 function ctx22g00_envia_email_anexos(lr_param, lr_anexo)
#=============================================================================

 define lr_param record
         rem     char(50)
        ,des     char(10000)
        ,ccp     char(10000)
        ,cco     char(10000)
        ,ass     char(500)
        ,msg     char(32000)
        ,idr     char(20)
        ,tip     char(4)
 end record
 
 define lr_anexo record
       anexo1    char (300)
      ,anexo2    char (300)
      ,anexo3    char (300)
 end record
 
 define l_retorno       smallint
       ,l_ret_figrc009  integer
       ,l_mensagem_erro char(20)

 initialize l_mensagem_erro
           ,l_ret_figrc009
 to null

 let l_retorno = 0

 if lr_param.des is not null then
 
    if ((lr_param.msg is null) or (lr_param.msg = " ")) then
       if ((lr_param.ass is not null) or (lr_param.ass <> " ")) then
          let lr_param.msg = lr_param.ass
       else
          let lr_param.msg = "." 
       end if
    end if
    
    if ((lr_param.rem is null) or (lr_param.rem = " ")) then
       let lr_param.rem = 'porto.socorro@portoseguro.com.br'
    end if
    
    if ((lr_param.idr is null) or (lr_param.idr = " ")) then
       let lr_param.idr = "P0603000" 
    end if    
    
    # Inicio - Inserindo anexos
    if ((lr_anexo.anexo1 is not null) and (lr_anexo.anexo1 <> " ")) then
           call figrc009_attach_file(lr_anexo.anexo1)
    end if
    
    if ((lr_anexo.anexo2 is not null) and (lr_anexo.anexo2 <> " ")) then
           call figrc009_attach_file(lr_anexo.anexo2)
    end if
    
    if ((lr_anexo.anexo3 is not null) and (lr_anexo.anexo3 <> " ")) then
           call figrc009_attach_file(lr_anexo.anexo3)
    end if
    # Fim - Inserindo anexos
    
    call figrc009_mail_send1(lr_param.*)
         returning l_ret_figrc009, l_mensagem_erro

    let l_retorno = l_ret_figrc009

 else

    let l_retorno = 99

 end if

 return l_retorno

 end function

 ### RODOLFO MASSINI - FIM

#=============================================================================
 function ctx22g00_envia_email_html(lr_param)
#=============================================================================
 define lr_param    record
    modulo          like igbmparam.relsgl
   ,assunto         char(300)
   ,html            char(32000)
 end record
 define lr_mail record
    rem char(50),
    des char(10000),
    ccp char(10000),
    cco char(10000),
    ass char(150),
    msg char(32000),
    idr char(20),
    tip char(4)
 end record
 define l_retorno   smallint,
        l_comando   char(1000),
        l_email     like igbmparam.relpamtxt,
        l_destino   char(800),
        l_cod_erro  integer,
        l_msg_erro  char(20)

 let l_destino = null
 let l_comando = null
 let l_email = null
 let l_retorno = 0

 initialize lr_mail.* to null

 if m_prep_sql <> true or
    m_prep_sql is null then
    call ctx22g00_prepare()
 end if

 open c_ctx22g00_001 using lr_param.modulo
 foreach c_ctx22g00_001 into l_email
    if l_destino is null then
       let l_destino = l_email
    else
       let l_destino = l_destino clipped,',',l_email
    end if
 end foreach

 if l_destino is not null then

    let lr_mail.des = l_destino
    let lr_mail.rem = "porto.socorro@portoseguro.com.br"
    let lr_mail.ccp = ""
    let lr_mail.cco = ""
    let lr_mail.ass = lr_param.assunto
    let lr_mail.idr = "P0603000"
    let lr_mail.tip = "html"
    let lr_mail.msg = lr_param.html
    call figrc009_mail_send1(lr_mail.*)
         returning l_cod_erro, l_msg_erro

 else
    let l_retorno = 99
 end if

 return l_retorno

 end function
#=============================================================================
function ctx22g00_mail_anexo_corpo(lr_param)
#=============================================================================
  define lr_param record
         modulo    like igbmparam.relsgl
        ,assunto   char(300)
        ,anexo     char(300)
  end record
  define l_retorno   smallint
  define l_comando   char(1000)
  define l_email     like igbmparam.relpamtxt
  define l_destino   char(800)
  #let l_destino = null
  #let l_comando = null
  #let l_email = null
  #let l_retorno = 0
  #if m_prep_sql <> true or
  #   m_prep_sql is null then
  #   call ctx22g00_prepare()
  #end if
  #whenever error continue
  #open c_ctx22g00_001 using lr_param.modulo
  #foreach c_ctx22g00_001 into l_email
  #   if l_destino is null then
  #      let l_destino = l_email
  #   else
  #      let l_destino = l_destino clipped,',',l_email
  #   end if
  #end foreach
  #whenever error stop
  #if l_destino is not null then
  #   let l_comando = ' echo "', lr_param.modulo clipped, '" | send_email.sh ',
  #                   ' -a    ', l_destino clipped,
  #                   ' -s   "', lr_param.assunto clipped, '" ',
  #                   ' -fb   ', lr_param.anexo clipped
  #   run l_comando returning l_retorno
  #else
  #   let l_retorno = 99
  #end if
  
  call ctx22g00_envia_email(lr_param.modulo, lr_param.assunto, lr_param.anexo)
  returning l_retorno
  return l_retorno
end function


#=============================================================================
function ctx22g00_mail_corpo(lr_param)
#=============================================================================
  define lr_param record
         modulo    like igbmparam.relsgl
        ,assunto   char(300)
        ,texto     char(300)
  end record
  define l_retorno   smallint
  define l_comando   char(1000)
  define l_email     like igbmparam.relpamtxt
  define l_destino   char(800)

   define lr_mail record
        rem char(50),
        des char(10000),
        ccp char(10000),
        cco char(10000),
        ass char(500),
        msg char(32000),
        idr char(20),
        tip char(4)
   end record
   define l_mensagem_erro  char(20)
       ,l_ret_figrc009   integer

   initialize lr_mail
             ,l_mensagem_erro
             ,l_ret_figrc009  to null


  let l_destino = null
  let l_comando = null
  let l_email = null
  let l_retorno = 0
  if m_prep_sql <> true or
     m_prep_sql is null then
     call ctx22g00_prepare()
  end if
  whenever error continue
  open c_ctx22g00_001 using lr_param.modulo
  foreach c_ctx22g00_001 into l_email
     if l_destino is null then
        let l_destino = l_email
     else
        let l_destino = l_destino clipped,',',l_email
     end if
  end foreach
  whenever error stop
  let lr_mail.rem = 'porto.socorro@portoseguro.com.br'
  let lr_mail.des = l_destino clipped
  let lr_mail.ass = lr_param.assunto clipped
  let lr_mail.msg = lr_param.modulo clipped, ' ', lr_param.texto clipped
  let lr_mail.tip = "text"
  let lr_mail.idr = "P0603000"


  if l_destino is not null then
    #let l_comando = ' echo "', lr_param.modulo clipped,
    #                lr_param.texto clipped,
    #                '" | send_email.sh ',
    #                ' -a    ', l_destino clipped,
    #                ' -s   "', lr_param.assunto clipped, '" '
    #run l_comando returning l_retorno

    call figrc009_mail_send1(lr_mail.*)
         returning l_ret_figrc009, l_mensagem_erro   


    let l_retorno = l_ret_figrc009


  else
     let l_retorno = 99
  end if
  return l_retorno
end function

