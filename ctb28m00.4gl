#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CT24h                                                      #
# Modulo        : ctb28m00                                                   #
# Analista Resp.: Carlos Zyon                                                #
# PSI           : 188751                                                     #
#                 Modulo para consulta de Servicos RIS.                      #
#                                                                            #
#............................................................................#
# Desenvolvimento: Carlos, META                                              #
# Liberacao      : 22/03/2005                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

   database porto
   
   #-- Totais por prestador
   define am_ctbm00 array[1500] of record
      pstcoddig1  like dpaksocor.pstcoddig
     ,traco       char(01)
     ,nomgrr1     like dpaksocor.nomgrr
     ,totatend    integer
     ,totenvok    integer
     ,totenvfp    integer
     ,totpend     integer
   end record
 
   define mr_ctb28m00 record
      perini         date
     ,perfim         date
     ,pstcoddig      like dpaksocor.pstcoddig
     ,nomgrr         like dpaksocor.nomgrr
   end record

   define m_prep   smallint
         ,m_count  smallint


#--------------------------#
function ctb28m00_prepare()
#--------------------------#
   define l_sql char(200)

   let l_sql = ' select nomgrr '
                ,' from dpaksocor '
               ,' where pstcoddig = ? '
   prepare pctb28m00002 from l_sql
   declare cctb28m00002 cursor for pctb28m00002

   let m_prep = true

end function


#------------------#
function ctb28m00()
#------------------#
   define lr_aux record
      atdsrvnum      like datmservico.atdsrvnum
     ,atdsrvano      like datmservico.atdsrvano
     ,pstcoddig      like dpaksocor.pstcoddig
     ,ultpstcoddig   like dpaksocor.pstcoddig
     ,risldostt      like dpamris.risldostt
   end record

   #-- Totais gerais
   define lr_ctb28m00t record
      ttotatend    integer
     ,ttotenvok    integer
     ,ttotenvfp    integer
     ,ttotpend     integer
   end record
 
   define l_sql    char(500)
         ,l_erro   smallint
	    ,l_anoc   char(4)
	    ,l_ano	integer	
	        
   if m_prep is null or
      m_prep <> true then
      call ctb28m00_prepare()
   end if
   
   let l_sql  = null
   let l_erro = false

   open window w_ctb28m00 at 4,2 with form 'ctb28m00'
      attribute(form line 1)

      while true
      
         initialize am_ctbm00    to null
         initialize lr_aux       to null
         
         let mr_ctb28m00.perini    = today - 90 units day
         let mr_ctb28m00.perfim    = today
         let mr_ctb28m00.pstcoddig = null
         
         let lr_ctb28m00t.ttotatend = 0
         let lr_ctb28m00t.ttotenvok = 0
         let lr_ctb28m00t.ttotenvfp = 0
         let lr_ctb28m00t.ttotpend  = 0


         input by name mr_ctb28m00.perini
                      ,mr_ctb28m00.perfim
                      ,mr_ctb28m00.pstcoddig without defaults
            
            before field perini
               display mr_ctb28m00.perini to perini attribute (reverse)

            after field perini
               display mr_ctb28m00.perini to perini
               if mr_ctb28m00.perini is null then
                  error "Campo obrigatorio "
                  next field perini
               end if

            before field perfim
               display mr_ctb28m00.perfim to perfim attribute (reverse)

            after field perfim
               display mr_ctb28m00.perfim to perfim
               if mr_ctb28m00.perfim is null then
                  error "Campo obrigatorio "
                  next field perfim
               end if
               
               if mr_ctb28m00.perfim < mr_ctb28m00.perini then
                  error "Data final precisa ser maior que a inicial "
                  next field perini
               end if

            before field pstcoddig
               display mr_ctb28m00.pstcoddig to pstcoddig attribute (reverse)

            after field pstcoddig
               display mr_ctb28m00.pstcoddig to pstcoddig
               
               if mr_ctb28m00.pstcoddig is null or 
                  mr_ctb28m00.pstcoddig = 0     then
                  let mr_ctb28m00.pstcoddig = 0
                  let mr_ctb28m00.nomgrr    = "TODOS"
               else
                  open cctb28m00002 using mr_ctb28m00.pstcoddig
                  whenever error continue
                  fetch cctb28m00002 into mr_ctb28m00.nomgrr
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode = notfound then
                        error "Prestador nao encontrado "
                     else
                        error 'Erro SELECT cctb28m00002: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                        error 'ctb28m00() ', lr_aux.pstcoddig sleep 2
                     end if
                     next field pstcoddig
                  end if
                  close cctb28m00002
               end if
               
               display by name mr_ctb28m00.nomgrr
            
            on key (control-c,F17,interrupt)
               let int_flag = false
               let l_erro   = true
               exit input

         end input
         
         if l_erro then
            exit while
         end if
                  
         let m_count = 0
         let lr_aux.ultpstcoddig = 0
         let lr_aux.pstcoddig = mr_ctb28m00.pstcoddig
	    let l_anoc = year(mr_ctb28m00.perfim) 
	    let l_ano = l_anoc[3,4]
	    
         let l_sql = ' select dat.atdsrvnum '
                          ,' ,dat.atdsrvano '
                          ,' ,dat.atdprscod '
                          ,' ,dpa.risldostt '
                      ,' from datmservico dat '
                          ,' ,dpamris     dpa '
                     ,' where dat.atdsrvnum = dpa.atdsrvnum '
                       ,' and dat.atdsrvano = dpa.atdsrvano '
                       ,' and dat.atdsrvnum >= 1000000 '
                       ,' and dat.atdsrvano = ', l_ano using "&&", ' '
                       ,' and dat.atddat   >= "', mr_ctb28m00.perini,'" '
                       ,' and dat.atddat   <= "', mr_ctb28m00.perfim,'" '
         if lr_aux.pstcoddig <> 0 then
            let l_sql = l_sql clipped,' and dat.atdprscod = ',lr_aux.pstcoddig
         end if
         let l_sql = l_sql clipped,' order by 3, 2, 1, 4 '

         prepare pctb28m00001 from l_sql
         declare cctb28m00001 cursor for pctb28m00001

         foreach cctb28m00001 into lr_aux.atdsrvnum
                                  ,lr_aux.atdsrvano
                                  ,lr_aux.pstcoddig
                                  ,lr_aux.risldostt
                                  
            if lr_aux.pstcoddig is null then
               continue foreach
            end if

            if lr_aux.pstcoddig <> lr_aux.ultpstcoddig or
               lr_aux.ultpstcoddig = 0                 then
               let m_count = m_count + 1
               if m_count > 1500 then
                  error 'Numero de registros excedeu o limite do array' sleep 2
                  exit foreach
               end if
               let am_ctbm00[m_count].totatend   = 0
               let am_ctbm00[m_count].totpend    = 0
               let am_ctbm00[m_count].totenvok   = 0
               let am_ctbm00[m_count].totenvfp   = 0
               let am_ctbm00[m_count].pstcoddig1 = lr_aux.pstcoddig
               let am_ctbm00[m_count].traco      = '-'
               let lr_aux.ultpstcoddig = lr_aux.pstcoddig
               open cctb28m00002 using lr_aux.pstcoddig
               whenever error continue
               fetch cctb28m00002 into am_ctbm00[m_count].nomgrr1
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode = notfound then
                     let am_ctbm00[m_count].nomgrr1 = "NAO CADASTRADO"
                  else
                     error 'Erro SELECT cctb28m00002: ' , sqlca.sqlcode, " | ",sqlca.sqlerrd[2] sleep 2
                     error 'ctb28m00() ', lr_aux.pstcoddig sleep 2
                     let l_erro = true
                     exit foreach
                  end if
               end if
               close cctb28m00002
            end if

            #-- Acumula totais por prestador
            let am_ctbm00[m_count].totatend = am_ctbm00[m_count].totatend + 1

            #-- Acumula totais gerais
            let lr_ctb28m00t.ttotatend = lr_ctb28m00t.ttotatend + 1
            case lr_aux.risldostt
               when 0 #-- Nao preenchido = Pendente
                  let am_ctbm00[m_count].totpend = am_ctbm00[m_count].totpend + 1
                  let lr_ctb28m00t.ttotpend      = lr_ctb28m00t.ttotpend + 1
               when 1 #-- Enviado dentro do prazo = OK
                  let am_ctbm00[m_count].totenvok = am_ctbm00[m_count].totenvok + 1
                  let lr_ctb28m00t.ttotenvok      = lr_ctb28m00t.ttotenvok + 1
               when 2 #-- Enviado fora do prazo
                  let am_ctbm00[m_count].totenvfp = am_ctbm00[m_count].totenvfp + 1
                  let lr_ctb28m00t.ttotenvfp      = lr_ctb28m00t.ttotenvfp + 1
            end case
         end foreach
         close cctb28m00001
         
         if l_erro then
            exit while                
         end if
         
         display by name lr_ctb28m00t.*
         
         if m_count > 0 then
            call ctb28m00_display()
         else
            error 'Nenhum registro encontrado' sleep 2
         end if
         
      end while

   close window w_ctb28m00
   let int_flag = false

end function

#--------------------------#
function ctb28m00_display()
#--------------------------#
   define l_linha smallint

   call set_count(m_count)
   
   display "(F7) Env.Email" at 19,57
   
   display array am_ctbm00 to s_ctb28m00.*

      on key (F8)
         let l_linha = arr_curr()
         if am_ctbm00[l_linha].totpend > 0 then
            call ctb28m01(mr_ctb28m00.perini
                         ,mr_ctb28m00.perfim
                         ,am_ctbm00[l_linha].pstcoddig1)
         else
            error 'Nao existem pendencias para detalhar' sleep 2
         end if

      on key (f7)
         call ctb28m00_envia_email()

      on key(control-c,f17,interrupt)
         let int_flag = false
         exit display

   end display
   
   display "              " at 19,57
   
   clear form

end function

#-------------------------------#
 function ctb28m00_envia_email()
#-------------------------------#

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
 
 define lr_retorno record
     cod_erro integer,
     msg_erro char(250)
 end record
 
 define l_ind smallint,
        l_bgcolor char(20)
 
 initialize lr_mail.* to null
 
 let lr_mail.rem = "sergio.burini@correioporto"    
 let lr_mail.des = "sergio.burini@correioporto"    
 let lr_mail.ccp = ""
 let lr_mail.cco = ""
 let lr_mail.ass = "Relatorio de Servico RIS: ", mr_ctb28m00.perini, " a ", mr_ctb28m00.perfim
 let lr_mail.idr = "F0104577"
 let lr_mail.tip = "html" 
 
 let lr_mail.msg = "<html>",
                      "<body>",
                         "<font face='verdana' size='1'>",
                         "<center><b>RELATORIO DE SERVICOS RIS</b><br><br></center>",
                         "<table border='0' width='100%' style='font-family: Verdana; font-size: 11px; text-align: center'>",
                            "<tr bgcolor='#0000A0'>",
                               "<td><b><font color= white>PRESTADOR</td>",
                               "<td><b><font color= white>TOTAL ATEND.</td>",
                               "<td><b><font color= white>ENVIO OK</td>",
                       	       "<td><b><font color= white>FORA DO PRAZ</td>",
                       	       "<td><b><font color= white>PEND.</td>",
                            "</font></tr>"
                            
 for l_ind = 1 to arr_count()
     
     if  not (l_ind mod 2) = 0 then
         let l_bgcolor = " bgcolor=#EEEEEE "
     else
         let l_bgcolor = " "
     end if
     
     let lr_mail.msg = lr_mail.msg clipped , "<tr ", l_bgcolor clipped , ">",
                                                "<td>", am_ctbm00[l_ind].pstcoddig1  using "<<<<&" , " - ", 
                                                        am_ctbm00[l_ind].nomgrr1 clipped, "</td>",
                                                "<td>", am_ctbm00[l_ind].totatend using "<<<<&" , "</td>",
                                                "<td>", am_ctbm00[l_ind].totenvok using "<<<<&", "</td>",
                                                "<td>", am_ctbm00[l_ind].totenvfp using "<<<<&", "</td>",
                                                "<td>", am_ctbm00[l_ind].totpend using "<<<<&", "</td>",
                                             "</tr>"                                    
 end for
 
 let lr_mail.msg = lr_mail.msg clipped, "</table><br><br><b>Porto Socorro<br></b>Corporacao Porto Seguro - http://www.portoseguro.com.br ",
                                     "</body>",
                                  "</html>"

 display lr_mail.msg clipped
 
 error "Enviando email. " 
 
 call ctx22g00_envia_email_html("RELRIS", lr_mail.ass, lr_mail.msg)
      returning lr_retorno.cod_erro
       
 if  lr_retorno.cod_erro <> 0 then
     error "Erro no envio do email: ",
     lr_retorno.cod_erro using "<<<<<<&"
 else
     error "E-mail enviado com sucesso."
 end if      

 end function 