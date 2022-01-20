#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctx01g12.4gl                                              #
#                  Envia email para gerencia Porto Socorro para apolice com  #
#                  muitos serviços                                           #
# Analista Resp. : Robert Lima                                               #
# PSI            :                                                           #
#............................................................................#
# Liberacao      : 06/01/2011                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica    Alteracao                                     #
# ----------  ---------------  -----------------------------------------     #
# 26/05/2014  Rodolfo Massini  Alteracao na forma de envio de                #
#                              e-mail (SENDMAIL para FIGRC009)               # 
##############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prep_ctx01g12 smallint

#---------------------------#
function ctx01g12_prepare()
#---------------------------#
   define l_sql    char(500)
   let l_sql =  "select succod, ",
                      " ramcod, ",
                      " aplnumdig, ",
                      " itmnumdig ",
                " from datrservapol ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "
   prepare p_ctx01g12_001 from l_sql
   declare c_ctx01g12_001 cursor for p_ctx01g12_001

   let l_sql =  "select count(*), ",
                      " sum(b.atdcstvlr) ",
                 " from datrservapol a, ",
                      " datmservico b ",
                " where a.atdsrvnum = b.atdsrvnum ",
                  " and a.atdsrvano = b.atdsrvano ",
                  " and a.succod    = ? ",
                  " and a.ramcod    = ? ",
                  " and a.aplnumdig = ? ",
                  " and a.itmnumdig = ? ",
                  " and b.pgtdat is not null "
   prepare p_ctx01g12_002 from l_sql
   declare c_ctx01g12_002 cursor for p_ctx01g12_002

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod ",
                 " from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
   prepare p_ctx01g12_003 from l_sql
   declare c_ctx01g12_003 cursor for p_ctx01g12_003

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " qth.lclltt, ",
                      " qth.lcllgt, ",
                      " qti.lclltt, ",
                      " qti.lcllgt ",
                 " from datmservico srv,  ",
                      " datmlcl qth, ",
                      " datmlcl qti ",
                " where srv.atdsrvnum = ? ",
                  " and srv.atdsrvano = ? ",
                  " and qth.atdsrvnum = srv.atdsrvnum ",
                  " and qth.atdsrvano = srv.atdsrvano ",
                  " and qth.c24endtip = 1 ",
                  " and qth.c24lclpdrcod >= 1 ",
                  " and qti.atdsrvnum = srv.atdsrvnum ",
                  " and qti.atdsrvano = srv.atdsrvano ",
                  " and qti.c24endtip = 2 ",
                  " and qti.c24lclpdrcod >= 1 "
   prepare p_ctx01g12_004 from l_sql
   declare c_ctx01g12_004 cursor for p_ctx01g12_004

   let l_sql =  "select cpodes ",
                 " from datkdominio ",
                " where cponom = ? ",
                  " and cpocod = ? "
   prepare p_ctx01g12_005 from l_sql
   declare c_ctx01g12_005 cursor for p_ctx01g12_005

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " asitipcod ",
                 " from datmservico ",
                " where atdsrvnum = ? ",
                  " and atdsrvano = ? "
   prepare p_ctx01g12_006 from l_sql
   declare c_ctx01g12_006 cursor for p_ctx01g12_006

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " socntzcod ",
                 " from datmservico srv, ",
                      " datmsrvre re",
                " where srv.atdsrvnum = ? ",
                  " and srv.atdsrvano = ? ",
                  " and srv.atdsrvnum = re.atdsrvnum ",
                  " and srv.atdsrvano = re.atdsrvano "
   prepare p_ctx01g12_007 from l_sql
   declare c_ctx01g12_007 cursor for p_ctx01g12_007

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " srvpbm.c24pbmcod, ",
                      " pbm.c24pbmdes ",
                 " from datmservico srv, ",
                      " datrsrvpbm srvpbm, ",
                      " datkpbm pbm ",
                " where srv.atdsrvnum = ? ",
                  " and srv.atdsrvano = ? ",
                  " and srv.atdsrvnum = srvpbm.atdsrvnum ",
                  " and srv.atdsrvano = srvpbm.atdsrvano ",
                  " and srvpbm.c24pbmseq = 1 ",
                  " and pbm.c24pbmcod = srvpbm.c24pbmcod "
   prepare p_ctx01g12_008 from l_sql
   declare c_ctx01g12_008 cursor for p_ctx01g12_008

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " srvacp.empcod, ",
                      " srvacp.funmat, ",
                      " srvacp.dstqtd, ", 
                      " lcl.cidnom, ",
                      " lcl.ufdcod ",                     
                 " from datmservico srv, ",
                      " datmsrvacp srvacp, ",
                      " datmlcl lcl ",
                " where srv.atdsrvnum = ? ",
                  " and srv.atdsrvano = ? ",
                  " and srv.atdsrvnum = srvacp.atdsrvnum ",
                  " and srv.atdsrvano = srvacp.atdsrvano ",
                  " and srv.atdsrvseq = srvacp.atdsrvseq ",
                  " and srv.atdsrvnum = lcl.atdsrvnum ",
                  " and srv.atdsrvano = lcl.atdsrvano ",
                  " and lcl.c24endtip = 1"
   prepare p_ctx01g12_009 from l_sql
   declare c_ctx01g12_009 cursor for p_ctx01g12_009

  let l_sql = "select cpodes from datkdominio ",
              " where cponom = ? "
  prepare p_ctx01g12_010 from l_sql
  declare c_ctx01g12_010 cursor with hold for p_ctx01g12_010

   let l_sql =  "select cpocod ",
                 " from datkdominio ",
                " where cponom = ? ",
                  " and cpodes = ? "
   prepare p_ctx01g12_011 from l_sql
   declare c_ctx01g12_011 cursor for p_ctx01g12_011

   let l_sql =  "select atdsrvorg, ",
                      " ciaempcod, ",
                      " lcl.ufdcod, ",                     
                      " lcl.cidnom ",
                 " from datmservico srv, ",
                      " datmlcl lcl ",
                " where srv.atdsrvnum = ? ",
                  " and srv.atdsrvano = ? ",
                  " and srv.atdsrvnum = lcl.atdsrvnum ",
                  " and srv.atdsrvano = lcl.atdsrvano ",
                  " and lcl.c24endtip = 1"
   prepare p_ctx01g12_012 from l_sql
   declare c_ctx01g12_012 cursor for p_ctx01g12_012
   
   let m_prep_ctx01g12 = true
end function


#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_pago(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_valor  decimal(8,2)
   define l_qtd    integer
   define l_srvvlr decimal(8,2)
   define l_srvqtd integer
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_ret    smallint
   define l_succod like datrservapol.succod
   define l_ramcod like datrservapol.ramcod
   define l_aplnumdig like datrservapol.aplnumdig
   define l_itmnumdig like datrservapol.itmnumdig
   
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

   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_succod to null
   initialize l_ramcod to null
   initialize l_aplnumdig to null
   initialize l_itmnumdig to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null
   let l_valor  = 0
   let l_qtd    = 0
   let l_srvvlr = 0
   let l_srvqtd = 0

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   call cta00m06_alerta_despesas()
   returning l_valor , l_qtd

   whenever error continue
   open c_ctx01g12_001 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_001 into l_succod,
                             l_ramcod,
                             l_aplnumdig,
                             l_itmnumdig
      if sqlca.sqlcode = 0 then
         open c_ctx01g12_002 using l_succod,
                                   l_ramcod,
                                   l_aplnumdig,
                                   l_itmnumdig
         fetch c_ctx01g12_002 into l_srvqtd,
                                   l_srvvlr
         close c_ctx01g12_002
      end if
   close c_ctx01g12_001
   whenever error stop


   # Valor ou Quantidade acima do parametrizado
   if l_srvvlr >= l_valor or l_srvqtd >= l_qtd then

      # Busca nome do funcionario que realizou a abertura do servico
      call cty08g00_nome_func(g_issk.empcod
    	                   ,g_issk.funmat,"F")
                    returning cty08g00_func.resultado ,
                              cty08g00_func.mens,
                              cty08g00_func.funnom
      if cty08g00_func.resultado <> 1 then
         error cty08g00_func.mens
      end if

      # Busca dados complementares do servico
      open c_ctx01g12_003 using lr_param.atdsrvnum,
                                lr_param.atdsrvano
      fetch c_ctx01g12_003 into l_atdsrvorg,
                                l_ciaempcod
      close c_ctx01g12_003
         
      let l_email.msg =  "Prezado(s), \n \n ",
                         "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                         " acessou em ", " < ", l_data ,"-",l_hora, " > o documento < " ,
                         l_succod    using "<<<&"   ,"/",
                         l_ramcod    using "<<<<&"  ,"/",
                         l_aplnumdig using "<<<<<<<<&" , "-",
                         l_itmnumdig using "<<<&",
                         " > da empresa ", l_ciaempcod using "<<<&", ", que tem R$ " , l_srvvlr using "<<<<<#.##",
                         " de despesa com serviços e com ", l_srvqtd using "&&" clipped, " serviços pagos, e abriu o serviço ",
                         l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&", ".",
                         " \n \n Os parâmetros para alerta são: Item de apólice com despesa superior ou igual a ", l_valor using "<<<<<<#.##",
                         " ou quantidade de serviços pagos superior ou igual a ",l_qtd using "<<<<&","."
      let l_email.subject = "Apólice com alta despesa com serviços abriu um novo serviço."

      call ctx01g12_lista_email_alerta('pgto')
      returning l_email.para

      if l_email.para is not null then
         let l_email.de  = "ct24hs.email@portoseguro.com.br"
         
         ### RODOLFO MASSINI - INICIO 
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013
         
         #let l_cmd = ' echo "', l_email.msg clipped,
         #            '" | send_email.sh ',
         #            ' -r ' ,l_email.de clipped,
         #            ' -a ' ,l_email.para clipped,
         #            ' -s "',l_email.subject clipped, '" '
         #run l_cmd returning l_ret
  
         let lr_mail.ass = l_email.subject clipped 
         let lr_mail.msg = l_email.msg clipped    
         let lr_mail.rem = l_email.de clipped 
         let lr_mail.des = l_email.para clipped
         let lr_mail.tip = "text"
  
         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,l_anexo)
         returning l_retorno  
         
         let l_ret = l_retorno                                      
                                                 
         ### RODOLFO MASSINI - FIM 

         if l_ret <> 0 then
            error "Erro ao enviar alerta de despesas ! " sleep 2
         end if
      end if

   end if

end function


#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_dist(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_qthltt like datmlcl.lclltt
   define l_qthlgt like datmlcl.lcllgt
   define l_qtiltt like datmlcl.lclltt
   define l_qtilgt like datmlcl.lcllgt
   define l_dstmax integer
   define l_dstqti dec(8,4)
   define l_ret    smallint
   define l_succod like datrservapol.succod
   define l_ramcod like datrservapol.ramcod
   define l_aplnumdig like datrservapol.aplnumdig
   define l_itmnumdig like datrservapol.itmnumdig
   define l_cponom like datkdominio.cponom

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
  
   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_succod to null
   initialize l_ramcod to null
   initialize l_aplnumdig to null
   initialize l_itmnumdig to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_qthltt to null
   initialize l_qthlgt to null
   initialize l_qtiltt to null
   initialize l_qtilgt to null
   initialize l_dstmax to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_004 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_004 into l_atdsrvorg,
                             l_ciaempcod,
                             l_qthltt,
                             l_qthlgt,
                             l_qtiltt,
                             l_qtilgt

      if sqlca.sqlcode = 0 then
         let l_cponom = 'aleorgdstqti'
         open c_ctx01g12_005 using l_cponom,
                                   l_atdsrvorg
         fetch c_ctx01g12_005 into l_dstmax
         if sqlca.sqlcode <> 0 then
            return
         end if
         close c_ctx01g12_005
      else
         return
      end if
   close c_ctx01g12_004
   whenever error stop

   # Calcula distancia em KM entre o QTH e QTI
   let l_dstqti = cts18g00(l_qthltt,
                           l_qthlgt,
                           l_qtiltt,
                           l_qtilgt)
                           
   # Distancia ente QTH e QTI acima do parametrizado
   if l_dstqti >= l_dstmax then

      # Busca nome do funcionario que realizou a abertura do servico
      call cty08g00_nome_func(g_issk.empcod
    	                   ,g_issk.funmat,"F")
                    returning cty08g00_func.resultado ,
                              cty08g00_func.mens,
                              cty08g00_func.funnom
      if cty08g00_func.resultado <> 1 then
         error cty08g00_func.mens
      end if

      let l_email.msg =  "Prezado(s), \n \n ",
                         "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                         " abriu o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                         " da empresa ", l_ciaempcod using "<<<&", ", com distancia entre ocorrecia e destido de " , l_dstqti using "<<<<<#", " KM",
                         " \n \n O parâmetro para alerta é: Serviço aberto com distancia linear entre origem e destino superior ou igual a ", l_dstmax using "<<<<<<#", " KM."
      let l_email.subject = "Serviço com distancia entre ocorrecia e destido acima do parametrizado."

      call ctx01g12_lista_email_alerta('qtidi')
      returning l_email.para

      if l_email.para is not null then
         let l_email.de  = "ct24hs.email@portoseguro.com.br"
                 
         ### RODOLFO MASSINI - INICIO 
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013

         #let l_cmd = ' echo "', l_email.msg clipped,
         #            '" | send_email.sh ',
         #            ' -r ' ,l_email.de clipped,
         #            ' -a ' ,l_email.para clipped,
         #            ' -s "',l_email.subject clipped, '" '
         #run l_cmd returning l_ret
           
         let lr_mail.ass = l_email.subject clipped 
         let lr_mail.msg = l_email.msg clipped    
         let lr_mail.rem = l_email.de clipped  
         let lr_mail.des = l_email.para clipped
         let lr_mail.tip = "text"
 
         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,l_anexo)
         returning l_retorno                                        
         
         let l_ret = l_retorno
                                                
         ### RODOLFO MASSINI - FIM 
         
         if l_ret <> 0 then
            error "Erro ao enviar alerta de distancia QTI ! " sleep 2
         end if
      end if

   end if

end function

#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_assistencia(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_asitipcod like datmservico.asitipcod
   define l_qthlgt like datmlcl.lcllgt
   define l_qtiltt like datmlcl.lclltt
   define l_qtilgt like datmlcl.lcllgt
   define l_dstmax integer
   define l_dstqti dec(8,4)
   define l_ret    smallint
   define l_succod like datrservapol.succod
   define l_ramcod like datrservapol.ramcod
   define l_aplnumdig like datrservapol.aplnumdig
   define l_itmnumdig like datrservapol.itmnumdig
   define l_cponom like datkdominio.cponom
   define l_cpodes like datkdominio.cpodes
   
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
  

   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_succod to null
   initialize l_ramcod to null
   initialize l_aplnumdig to null
   initialize l_itmnumdig to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_asitipcod to null
   initialize l_cpodes to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_006 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_006 into l_atdsrvorg,
                             l_ciaempcod,
                             l_asitipcod
                             
      if sqlca.sqlcode = 0 then
         # Verificar se a assistencia esta configurada
         let l_cponom = 'alesrvasi'
         open c_ctx01g12_005 using l_cponom,
                                   l_asitipcod
         fetch c_ctx01g12_005 into l_cpodes
         if sqlca.sqlcode <> 0 then
            return
         end if
         close c_ctx01g12_005
      else
         return
      end if
      close c_ctx01g12_006
   whenever error stop

   # Busca nome do funcionario que realizou a abertura do servico
   call cty08g00_nome_func(g_issk.empcod
 	                   ,g_issk.funmat,"F")
                 returning cty08g00_func.resultado ,
                           cty08g00_func.mens,
                           cty08g00_func.funnom
   if cty08g00_func.resultado <> 1 then
      error cty08g00_func.mens
   end if
      
   let l_email.msg =  "Prezado(s), \n \n ",
                      "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                      " abriu o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                      " da empresa ", l_ciaempcod using "<<<&", ", com a assistencia " , l_asitipcod using "<<<<#", "."
   let l_email.subject = "Serviço aberto com assistencia parametrizada para alerta."

   call ctx01g12_lista_email_alerta('asi')
   returning l_email.para

   if l_email.para is not null then
      let l_email.de  = "ct24hs.email@portoseguro.com.br"
      
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013

      #let l_cmd = ' echo "', l_email.msg clipped,
      #            '" | send_email.sh ',
      #            ' -r ' ,l_email.de clipped,
      #            ' -a ' ,l_email.para clipped,
      #            ' -s "',l_email.subject clipped, '" '
      #run l_cmd returning l_ret
        
      let lr_mail.ass = l_email.subject clipped
      let lr_mail.msg = l_email.msg clipped     
      let lr_mail.rem = l_email.de clipped  
      let lr_mail.des = l_email.para clipped
      let lr_mail.tip = "text"
 
      call ctx22g00_envia_email_overload(lr_mail.*
                                        ,l_anexo)
      returning l_retorno                                        
                    
      let l_ret = l_retorno
                                  
      ### RODOLFO MASSINI - FIM       
           
      if l_ret <> 0 then
         error "Erro ao enviar alerta de assistencia ! " sleep 2
      end if
   end if

end function

#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_natureza(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_socntzcod like datmsrvre.socntzcod
   define l_ret    smallint
   define l_cponom like datkdominio.cponom
   define l_cpodes like datkdominio.cpodes
  
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
  
   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_socntzcod to null
   initialize l_cpodes to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_007 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_007 into l_atdsrvorg,
                             l_ciaempcod,
                             l_socntzcod
                             
      if sqlca.sqlcode = 0 then
         # Verificar se a assistencia esta configurada
         let l_cponom = 'alesrvntz'
         open c_ctx01g12_005 using l_cponom,
                                   l_socntzcod
         fetch c_ctx01g12_005 into l_cpodes
         if sqlca.sqlcode <> 0 then
            return
         end if
         close c_ctx01g12_005
      else
         return
      end if
   close c_ctx01g12_007
   whenever error stop

   # Busca nome do funcionario que realizou a abertura do servico
   call cty08g00_nome_func(g_issk.empcod
 	                   ,g_issk.funmat,"F")
                 returning cty08g00_func.resultado ,
                           cty08g00_func.mens,
                           cty08g00_func.funnom
   if cty08g00_func.resultado <> 1 then
      error cty08g00_func.mens
   end if
      
   let l_email.msg =  "Prezado(s), \n \n ",
                      "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                      " abriu o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                      " da empresa ", l_ciaempcod using "<<<&", ", com a natureza " , l_socntzcod using "<<<<#", "."
   let l_email.subject = "Serviço aberto com natureza parametrizada para alerta."

   call ctx01g12_lista_email_alerta('nat')
   returning l_email.para

   if l_email.para is not null then
      let l_email.de  = "ct24hs.email@portoseguro.com.br"
     
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013

      #let l_cmd = ' echo "', l_email.msg clipped,
      #            '" | send_email.sh ',
      #            ' -r ' ,l_email.de clipped,
      #            ' -a ' ,l_email.para clipped,
      #            ' -s "',l_email.subject clipped, '" '
      #run l_cmd returning l_ret
        
      let lr_mail.ass = l_email.subject clipped
      let lr_mail.msg = l_email.msg clipped    
      let lr_mail.rem = l_email.de clipped
      let lr_mail.des = l_email.para clipped
      let lr_mail.tip = "text"
  
      call ctx22g00_envia_email_overload(lr_mail.*
                                        ,l_anexo)
      returning l_retorno   
      
      let l_ret = l_retorno                                     
                                                
      ### RODOLFO MASSINI - FIM       
     
      if l_ret <> 0 then
         error "Erro ao enviar alerta de natureza ! " sleep 2
      end if
   end if

end function

#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_problema(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_c24pbmcod like datrsrvpbm.c24pbmcod
   define l_c24pbmdes like datkpbm.c24pbmdes
   define l_ret    smallint
   define l_cponom like datkdominio.cponom
   define l_cpodes like datkdominio.cpodes

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

   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_c24pbmcod to null
   initialize l_c24pbmdes to null
   initialize l_cpodes to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_008 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_008 into l_atdsrvorg,
                             l_ciaempcod,
                             l_c24pbmcod,
                             l_c24pbmdes
                             
      if sqlca.sqlcode = 0 then
         # Verificar se a assistencia esta configurada
         let l_cponom = 'alesrvpbm'
         open c_ctx01g12_005 using l_cponom,
                                   l_c24pbmcod
         fetch c_ctx01g12_005 into l_cpodes
         if sqlca.sqlcode <> 0 then
            return
         end if
         close c_ctx01g12_005
      else
         return
      end if
   close c_ctx01g12_008
   whenever error stop

   # Busca nome do funcionario que realizou a abertura do servico
   call cty08g00_nome_func(g_issk.empcod
 	                   ,g_issk.funmat,"F")
                 returning cty08g00_func.resultado ,
                           cty08g00_func.mens,
                           cty08g00_func.funnom
   if cty08g00_func.resultado <> 1 then
      error cty08g00_func.mens
   end if
      
   let l_email.msg =  "Prezado(s), \n \n ",
                      "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                      " abriu o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                      " da empresa ", l_ciaempcod using "<<<&", ", com o problema " , l_c24pbmcod using "<<<<#", " - ", l_c24pbmdes clipped, "."
   let l_email.subject = "Serviço aberto com problema parametrizada para alerta."

   call ctx01g12_lista_email_alerta('pbm')
   returning l_email.para

   if l_email.para is not null then
      let l_email.de  = "ct24hs.email@portoseguro.com.br"
      
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013

      #let l_cmd = ' echo "', l_email.msg clipped,
      #            '" | send_email.sh ',
      #            ' -r ' ,l_email.de clipped,
      #            ' -a ' ,l_email.para clipped,
      #            ' -s "',l_email.subject clipped, '" '
      #run l_cmd returning l_ret
        
      let lr_mail.ass = l_email.subject clipped 
      let lr_mail.msg = l_email.msg clipped    
      let lr_mail.rem = l_email.de clipped  
      let lr_mail.des = l_email.para clipped
      let lr_mail.tip = "text"

      call ctx22g00_envia_email_overload(lr_mail.*
                                        ,l_anexo)
      returning l_retorno                                        
      
      let l_ret = l_retorno
                                        
      ### RODOLFO MASSINI - FIM 

      if l_ret <> 0 then
         error "Erro ao enviar alerta de natureza ! " sleep 2
      end if
   end if

end function

#-----------------------------------------------------------------
function ctx01g12_enviaemail_acn_dist(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_dstmax integer
   define l_dstacn dec(8,4)
   define l_empcod like datmsrvacp.empcod
   define l_funmat like datmsrvacp.funmat
   define l_cidnom like datmlcl.cidnom
   define l_ufdcod like datmlcl.ufdcod
   define l_ret    smallint
   define l_succod like datrservapol.succod
   define l_ramcod like datrservapol.ramcod
   define l_aplnumdig like datrservapol.aplnumdig
   define l_itmnumdig like datrservapol.itmnumdig
   define l_cponom like datkdominio.cponom

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
  
   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_succod to null
   initialize l_ramcod to null
   initialize l_aplnumdig to null
   initialize l_itmnumdig to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_dstmax to null
   initialize l_empcod to null
   initialize l_funmat to null
   initialize l_cidnom to null
   initialize l_ufdcod to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_009 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_009 into l_atdsrvorg,
                             l_ciaempcod,
                             l_empcod,
                             l_funmat,
                             l_dstacn,
                             l_cidnom,
                             l_ufdcod

      if sqlca.sqlcode = 0 then
         let l_cponom = 'aleorgdstacn'
         open c_ctx01g12_005 using l_cponom,
                                   l_atdsrvorg
         fetch c_ctx01g12_005 into l_dstmax
         if sqlca.sqlcode <> 0 then
            return
         end if
         close c_ctx01g12_005
      else
         return
      end if
   close c_ctx01g12_009
   whenever error stop

   # Distancia entre socorrista e servico (acionamento)
   if l_dstacn >= l_dstmax then

      # Busca nome do funcionario que realizou o acionamento do servico
      call cty08g00_nome_func(l_empcod
    	                       ,l_funmat,"F")
                    returning cty08g00_func.resultado ,
                              cty08g00_func.mens,
                              cty08g00_func.funnom
      if cty08g00_func.resultado <> 1 then
         error cty08g00_func.mens
      end if

      let l_email.msg =  "Prezado(s), \n \n ",
                         "O operador < ",  l_funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                         " acionou o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                         " da empresa ", l_ciaempcod using "<<<&", ", cidade ", l_cidnom clipped, "/", l_ufdcod ,", para um prestador localizado a " , l_dstacn using "<<<<<#.###", " KM do serviço.",
                         " \n \n O parâmetro para alerta é: Serviço concluido com distancia de acionamento superior ou igual a ", l_dstmax using "<<<<<<#.###", " KM para a origem ", l_atdsrvorg using "&&", "."
      let l_email.subject = "Serviço com distancia de acionamento acima do parametrizado."

      call ctx01g12_lista_email_alerta('acndi')
      returning l_email.para

      if l_email.para is not null then
         let l_email.de  = "ct24hs.email@portoseguro.com.br"
         
         ### RODOLFO MASSINI - INICIO 
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013

         #let l_cmd = ' echo "', l_email.msg clipped,
         #            '" | send_email.sh ',
         #            ' -r ' ,l_email.de clipped,
         #            ' -a ' ,l_email.para clipped,
         #            ' -s "',l_email.subject clipped, '" '
         #run l_cmd returning l_ret
                    
         let lr_mail.ass = l_email.subject clipped
         let lr_mail.msg = l_email.msg clipped    
         let lr_mail.rem = l_email.de clipped  
         let lr_mail.des = l_email.para clipped
         let lr_mail.tip = "text"
 
         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,l_anexo)
         returning l_retorno                                        
                
         let l_ret = l_retorno
                                         
         ### RODOLFO MASSINI - FIM          
         
         
         if l_ret <> 0 then
            error "Erro ao enviar alerta de distancia ACIONAMENTO ! "
         end if
      end if

   end if

end function

#-----------------------------------------------------------------
function ctx01g12_enviaemail_serv_local_ocorr(lr_param)
#-----------------------------------------------------------------
   define lr_param record
          atdsrvnum   like datmservico.atdsrvnum,
          atdsrvano   like datmservico.atdsrvano
   end record

   define l_email      record
        msg          char(1000)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(5000)
       ,cc           char(500)
   end record

   define cty08g00_func record
       funnom       like isskfunc.funnom,
       mens         char(40),
       resultado    smallint
   end record

   define l_data   date
   define l_hora   datetime hour to second
   define l_cmd    char(10000)
   define l_ciaempcod like datmservico.ciaempcod
   define l_atdsrvorg like datmservico.atdsrvorg
   define l_ufdcod like datmlcl.ufdcod
   define l_cidnom like datmlcl.cidnom
   define l_ret    smallint
   define l_cponom like datkdominio.cponom
   define l_cpodes like datkdominio.cpodes
   define l_cpocod like datkdominio.cpocod

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
  
   initialize l_email.* to null
   initialize cty08g00_func.* to null
   initialize l_ciaempcod to null
   initialize l_atdsrvorg to null
   initialize l_ufdcod to null
   initialize l_cidnom to null
   initialize l_cpodes to null
   initialize l_cpocod to null

   let l_data   = today
   let l_hora   = current
   let l_cmd    = null

   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if

   whenever error continue
   open c_ctx01g12_012 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   fetch c_ctx01g12_012 into l_atdsrvorg,
                             l_ciaempcod,
                             l_ufdcod,
                             l_cidnom
                             
      if sqlca.sqlcode = 0 then
         # Verificar se o local esta configurado
         let l_cponom = 'alesrvloc'
         
         # Realiza busca no dominio pela UF
         let l_cpodes = l_ufdcod
         open c_ctx01g12_011 using l_cponom,
                                   l_cpodes
         fetch c_ctx01g12_011 into l_cpocod
         if sqlca.sqlcode <> 0 then
            close c_ctx01g12_011
            
            # Realiza busca no dominio pela UF e CIDADE
            let l_cpodes = l_ufdcod clipped, "-", l_cidnom clipped
            open c_ctx01g12_011 using l_cponom,
                                      l_cpodes
            fetch c_ctx01g12_011 into l_cpocod
            if sqlca.sqlcode <> 0 then
               close c_ctx01g12_011
               return
            end if
         end if
      else
         close c_ctx01g12_012
         return
      end if
   close c_ctx01g12_012
   whenever error stop

   # Busca nome do funcionario que realizou a abertura do servico
   call cty08g00_nome_func(g_issk.empcod
 	                   ,g_issk.funmat,"F")
                 returning cty08g00_func.resultado ,
                           cty08g00_func.mens,
                           cty08g00_func.funnom
   if cty08g00_func.resultado <> 1 then
      error cty08g00_func.mens
   end if
      
   let l_email.msg =  "Prezado(s), \n \n ",
                      "O operador < ",  g_issk.funmat using "<<<<<<<<&"," - ",cty08g00_func.funnom clipped ," >",
                      " abriu o servico ", l_atdsrvorg using "&&", "/", lr_param.atdsrvnum using "&&&&&&&", "-", lr_param.atdsrvano using "&&",
                      " da empresa ", l_ciaempcod using "<<<&", ", na cidade " , l_ufdcod clipped, "-", l_cidnom clipped, "."
   let l_email.subject = "Serviço aberto com local parametrizado para alerta."

   call ctx01g12_lista_email_alerta('loc')
   returning l_email.para

   if l_email.para is not null then
      let l_email.de  = "ct24hs.email@portoseguro.com.br"
    
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
      #let l_cmd = ' echo "', l_email.msg clipped,
      #            '" | send_email.sh ',
      #            ' -r ' ,l_email.de clipped,
      #            ' -a ' ,l_email.para clipped,
      #            ' -s "',l_email.subject clipped, '" '
      #run l_cmd returning l_ret
      
      let lr_mail.ass = l_email.subject clipped
      let lr_mail.msg = l_email.msg clipped   
      let lr_mail.rem = l_email.de clipped  
      let lr_mail.des = l_email.para clipped
      let lr_mail.tip = "text"
 
      call ctx22g00_envia_email_overload(lr_mail.*
                                        ,l_anexo)
      returning l_retorno  
      
      let l_ret = l_retorno                                      
                                                
      ### RODOLFO MASSINI - FIM       
      
      if l_ret <> 0 then
         error "Erro ao enviar alerta de local ! " sleep 2
      end if
   end if

end function


#---------------------------------------------
function ctx01g12_lista_email_alerta(lr_param)
#---------------------------------------------
   define lr_param record
          tipo_alerta   char(7)
   end record
   
   define emails   array[20] of char(100)
   define l_lista  char(1000)
   define l_chave  char(20)
   define l_msglog char(100)
   define i        integer
   for i = 1 to 20
       let emails[i] = null
   end for
   let i   = 1
   let l_lista  = null
   let l_chave = 'alerta_email_', lr_param.tipo_alerta clipped
   
   if m_prep_ctx01g12 is null or m_prep_ctx01g12 <> true then
      call ctx01g12_prepare()
   end if
      
   whenever error continue
   open c_ctx01g12_010 using l_chave
   foreach c_ctx01g12_010 into emails[i]
    if i = 1 then
      let l_lista = emails[i] clipped
    else
      let l_lista = l_lista clipped
                    ,","
                    ,emails[i] clipped
    end if
    let i = i+1
  end foreach
  if sqlca.sqlcode <> 0 then
      let l_msglog = "ERRO (",sqlca.sqlcode, ") AO SELECIONAR CHAVE NA DATKDOMINIO ", l_chave
      call errorlog(l_msglog)
      error l_msglog
   end if
   close c_ctx01g12_010
   
   return l_lista

end function
