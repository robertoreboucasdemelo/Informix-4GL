#############################################################################
# Nome do Modulo: ctx28g00                                         Sergio   #
#                                                                  Burini   #
# Validações para Monitoramento de Rotinas Criticas.               NOV/2007 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 18/11/2010  PSI 260142   Fabio Costa  Funcao verifica listener locadora   #
#---------------------------------------------------------------------------#

database porto

     define m_prepare char(01)

#-------------------------#
 function ctx28g00_prepare()
#-------------------------#

     define l_sql char(500)
     
     let l_sql = "update dpamcrtpcs ",              
                   " set atlhor = ? ",  
                 " where pcsnom = ? ",
                   " and hossrv = ? "

     prepare pr_ctx28g00_01 from l_sql
     
     let l_sql = "select prcstt ",
                  " from dpamcrtpcs ",
                 " where pcsnom = ? ",
                   " and hossrv = ? "      
                   
     prepare pr_ctx28g00_02 from l_sql
     declare cq_ctx28g00_02 cursor for pr_ctx28g00_02
     
     let l_sql = "select atlhor, ",
                       " atlmaxtmp ",
                  " from dpamcrtpcs ",
                 " where pcsnom = ? ",
                   " and prcstt = 'A' "

     prepare pr_ctx28g00_03 from l_sql
     declare cq_ctx28g00_03 cursor for pr_ctx28g00_03 
     
     let l_sql = "update dpamcrtpcs ",              
                   " set prcstt = 'I' ",  
                 " where pcsnom = ? "   

     prepare pr_ctx28g00_04 from l_sql
     
     let l_sql = "update dpamcrtpcs ",              
                   " set prcstt = 'A' ",  
                 " where pcsnom = ? ",
                   " and hossrv = ? "                    

     prepare pr_ctx28g00_05 from l_sql    
     
     let l_sql = "select maicod ",             
                  " from dpamcrtpcs ",      
                 " where pcsnom = ? ",    
                   " and hossrv = ? ",
                   " and prcstt = 'A' "
                   
     prepare pr_ctx28g00_06 from l_sql
     declare cq_ctx28g00_06 cursor for pr_ctx28g00_06
     
     let l_sql = " select atlhor, errdes, maicod, apcctr",
                 " from dpamcrtpcs ",
                 " where pcsnom = ? ",
                 "   and hossrv = ? ",
                 "   and prcstt = 'A' "
     prepare pr_ctx28g00_07 from l_sql
     declare cq_ctx28g00_07 cursor for pr_ctx28g00_07
     
     let l_sql = ' select grlinf ',
                 ' from datkgeral ',
                 ' where grlchv[1,3]  = ? ',
                 '   and grlchv[4,15] = ? '
     prepare pr_ctx28g00_08 from l_sql
     declare cq_ctx28g00_08 cursor for pr_ctx28g00_08
     
     let l_sql = "update dpamcrtpcs ",
                   " set apcctr = ? ",
                 " where pcsnom = ? ",
                   " and hossrv = ? "
     prepare pr_ctx28g00_09 from l_sql
     
     let l_sql = "select 1 ",
                  " from datkgeral ",
                 " where grlchv = ?"
     prepare pr_ctx28g00_10 from l_sql
     declare cq_ctx28g00_10 cursor for pr_ctx28g00_10    
     
 end function   
                  
#---------------------------------------------------#
# VERIFICA SE O PROCESSO È O ATIVO.                 #
# ENTRADA : Nome do Processo                        #
#           Nome do Host                            #
#---------------------------------------------------#
 function ctx28g00(lr_param)
#---------------------------------------------------#

     define lr_param record
                         pcsnom like dpamcrtpcs.pcsnom,
                         hossrv like dpamcrtpcs.hossrv,
                         tmpexp datetime year to second
                     end record
     
     define l_cur       like dpamcrtpcs.atlhor,
            l_prcstt    like dpamcrtpcs.prcstt,
            l_atlhor    like dpamcrtpcs.atlhor,  
            l_atlmaxtmp like dpamcrtpcs.atlmaxtmp,
            l_comando   char(1000)

     initialize l_atlhor,   
                l_atlmaxtmp,
                l_prcstt,  
                l_cur to null
                    
     if  m_prepare is null then
         let m_prepare = "S"
         call ctx28g00_prepare()    
     end if
     
     #VERIFICA SE É O STATUS ATIVO
     open cq_ctx28g00_02 using lr_param.pcsnom,       
                               lr_param.hossrv 
     
     fetch cq_ctx28g00_02 into l_prcstt     

     if  (lr_param.tmpexp + 1 units minute) <= current then
     
         let lr_param.tmpexp = current
         
         let l_cur = current
         
         execute pr_ctx28g00_01 using l_cur,
                                      lr_param.pcsnom,
                                      lr_param.hossrv

         #SO FAZ CONSISTENCIA SE TIVER O QUE ALTERAR.
         if  sqlca.sqlerrd[3] > 0 then

             #SE FOR O INATIVO VERIFICA SE O ATIVO EXPIROU
             if  l_prcstt = "I" then

                 let l_comando = "echo {",lr_param.pcsnom clipped ," - ", 
                                 lr_param.hossrv,"} ESTOU INATIVO >> /ldbs/msrc.log"
                 run l_comando

                 open cq_ctx28g00_03 using lr_param.pcsnom
                 fetch cq_ctx28g00_03 into l_atlhor,  
                                           l_atlmaxtmp
                                           
                 let l_atlhor = (l_atlhor + (l_atlmaxtmp units second))

                 # CASO TENHA EXPIRADO O INATIVO TOMA POSSE DO PROCESSO.
                 if  l_atlhor < current then

                     let l_comando = "echo {",lr_param.pcsnom clipped ," - ",           
                                     lr_param.hossrv,"} TOMEI POSSE >> /ldbs/msrc.log"
                                     
                     run l_comando                                           
                     
                     execute pr_ctx28g00_04 using lr_param.pcsnom
                     
                     execute pr_ctx28g00_05 using lr_param.pcsnom,
                                                  lr_param.hossrv 
                     
                                                  
                     call cts28g00_envia_email(lr_param.pcsnom, lr_param.hossrv)
                                                                      
                 end if
             else
                 if  l_prcstt = 'A' then
                     let l_comando = "echo {",lr_param.pcsnom clipped ," - ",           
                                     lr_param.hossrv,"} ESTOU ATIVO >> /ldbs/msrc.log"
                                     
                     run l_comando
                 else
                     let l_comando = "echo {",lr_param.pcsnom clipped ," - ",             
                                     lr_param.hossrv,"} VERIFIQUE O CADASTRO DO PROCESSO >> /ldbs/msrc.log"    
                                                                                          
                     run l_comando                                                        
                 end if                                             
             end if       
         end if
     end if
     
     return lr_param.tmpexp, l_prcstt

 end function
 
#----------------------------------------#
 function  cts28g00_envia_email(lr_param)
#----------------------------------------#

     define lr_param record
                         pcsnom like dpamcrtpcs.pcsnom,
                         hossrv like dpamcrtpcs.hossrv
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

     define l_cod_erro integer,
            l_msg_erro char(20),
            l_data     date,
            l_hora     datetime hour to second                    
       
     let l_data = today
     let l_hora = current

     open cq_ctx28g00_06 using lr_param.pcsnom, 
                               lr_param.hossrv
     fetch cq_ctx28g00_06 into lr_mail.des
     
     let lr_mail.rem = "porto.socorro@portoseguro.com.br"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "Interrupção de Processo Batch em ", l_data, " as ", l_hora
     let lr_mail.idr = "F0104577"
     let lr_mail.tip = "html"     

     let lr_mail.msg = "<<html>",
                           "<body>",
                               "<table border=0 cellspacing=0 cellpadding=2 width=100% bgcolor=darkblue align=center>",
                                  "<tr>",
                                     "<td><font size=3 face=Verdana color=white><center><b>INTERRUPCAO DE PROCESSO BATCH</b></center></font></td>",
                                  "<tr>",
                               "</table>",
                               "<br><font size=2 face=Verdana color=black>A <b>",upshift(lr_param.hossrv) clipped,
                               "</b> assumiu o processo <b>", upshift(lr_param.pcsnom) clipped,
                               "</b>. Verifique no <b><a href='http://nt258/msmc'>Sistema Monitor de Rotinas Criticas</a></b>",
                               " se ha algum procedimento a ser tomado. ",
                               "<br><br><b>Monitor de Sistema De Missao Critica</b><br>",
                           "</body>",
                       "</html>"                       

     call figrc009_mail_send1(lr_mail.*)
          returning l_cod_erro, l_msg_erro
     
     if  l_cod_erro <> 0 then
         display "Erro no envio do email: ",
                 l_cod_erro using "<<<<<<&", " - ",
                 l_msg_erro clipped
     end if

 end function
 
#----------------------------------------------------------------
function ctx28g00_stt_listener_locadora(l_lcvcod)
#----------------------------------------------------------------

  define l_lcvcod like datklocadora.lcvcod
        ,l_grlchv like datkgeral.grlchv 

  define l_list record
         stt     like datkgeral.grlinf ,
         errmsg  char(80)
  end record

  initialize l_list.* to null
  
  if  m_prepare is null then
      let m_prepare = "S"
      call ctx28g00_prepare()
  end if
  
  let l_grlchv = "INDINILOC",l_lcvcod using '<<<<<'
  let l_list.stt = 0
  
  whenever error continue
  open cq_ctx28g00_10 using l_grlchv
  fetch cq_ctx28g00_10 
  whenever error stop
  
  if sqlca.sqlcode = 100 then
      let l_list.stt = 1 
      let l_list.errmsg = 'Integração com a locadora disponivel' 
  else
    if sqlca.sqlcode = 0 then
      let l_list.errmsg = 'Integração com a locadora indisponivel' 
    else
      let l_list.errmsg = 
      'Erro ao consultar status da integracao locadora. Codigo ',sqlca.sqlcode
    end if
  end if

  return l_list.*

end function


#----------------------------------------------------------------
function ctx28g00_info_listener()
#----------------------------------------------------------------

  define l_prc record
         pcsnom  like dpamcrtpcs.pcsnom,
         hossrv  char(20)  ,
         host    char(05)  ,
         cod     integer   ,
         atlhor  datetime year to second ,
         errdes  char(100) ,
         maicod  char(300) ,
         apcctr  char(20)
  end record
  
  initialize l_prc.* to null
  
  # definir sitename, apontar para aplicacao teste ou producao
  whenever error continue
  select sitename into l_prc.host from dual
  whenever error stop
  
  if l_prc.host is null
     then
     let l_prc.hossrv = 'nt321'
  else
     if l_prc.host = 'u07'
        then
        let l_prc.hossrv = 'localhost'
     else
        let l_prc.hossrv = 'nt321'
     end if
  end if
  
  let l_prc.pcsnom = 'PSListenerReservas'
  
  whenever error continue
  open cq_ctx28g00_07 using l_prc.pcsnom, l_prc.hossrv
  fetch cq_ctx28g00_07 into l_prc.atlhor, l_prc.errdes, l_prc.maicod,
                            l_prc.apcctr
  whenever error stop
  
  let l_prc.cod = sqlca.sqlcode
  
  return l_prc.cod, l_prc.atlhor, l_prc.errdes
       , l_prc.maicod, l_prc.apcctr, l_prc.pcsnom, l_prc.hossrv
  
end function

#----------------------------------------------------------------
function cts28g00_email_gen(lr_param)
#----------------------------------------------------------------

   define lr_param record
          sub char(150),
          msg char(500),
          mai char(300)
   end record

   define l_rem  char(50) ,
          l_ccp  char(250),
          l_cmd  char(1000),
          l_ret  smallint
   
   initialize l_rem, l_ccp, l_cmd, l_ret to null
   
   let l_rem = "porto.socorro@portoseguro.com.br"
   let l_ccp = "fabio.costa@portoseguro.com.br"
   
   whenever error continue
   let l_cmd = ' echo "', lr_param.msg clipped, '" | send_email.sh ',
               ' -r '   , l_rem clipped,
               ' -a '   , lr_param.mai clipped,
               ' -cc '  , l_ccp clipped,
               ' -s "'  , lr_param.sub clipped, '" '
               
   run l_cmd returning l_ret
   whenever error stop
   
   return l_ret
   
end function

#----------------------------------------------------------------
function ctx28g00_seginttoitvhor(l_numdec)
#----------------------------------------------------------------
# recebe quantidade de segundos em inteiro e devolve em intevalo 
# hour to second
  define l_numdec integer
  
  define l_dtoh record
         itvhts   interval hour to second ,
         segint   integer  ,
         minint   integer  ,
         horint   integer  ,
         itvchr   char(08)
  end record
  
  initialize l_dtoh.* to null
  
  let l_dtoh.segint = 0
  let l_dtoh.minint = 0
  let l_dtoh.horint = 0
  
  if l_numdec < 0
     then
     let l_numdec = l_numdec * (-1)
  end if
  
  if l_numdec >= 3600    # horas
     then
     let l_dtoh.horint = (l_numdec / 3600)
     let l_numdec = l_numdec - (l_dtoh.horint * 3600)
  end if
  
  if l_numdec >= 60      # minutos
     then
     let l_dtoh.minint = (l_numdec / 60)
     let l_numdec = l_numdec - (l_dtoh.minint * 60)
  end if
  
  let l_dtoh.segint = l_numdec  # segundos
  
  let l_dtoh.itvchr = l_dtoh.horint using "&&", ':',
                      l_dtoh.minint using "&&", ':',
                      l_dtoh.segint using "&&"
  
  let l_dtoh.itvhts = l_dtoh.itvchr
  
  return l_dtoh.itvhts
  
end function

#----------------------------------------------------------------
function cts28g00_formata_datetime(l_dyts)
#----------------------------------------------------------------
  define l_dyts datetime year to second
  define l_txt  char(19)
  define l_dat  date
  
  initialize l_txt, l_dat to null
  
  let l_txt = l_dyts
  let l_dat = l_dyts
  let l_txt = l_dat using "dd/mm/yyyy", " ", l_txt[12,19]
  
  return l_txt

end function
