 ###########################################################################
 # Nome do Modulo: ctc42m01                                         Sergio #
 #                                                                  Burini #
 # Cadastro de Socorristas com o SIMCards                         Jun/2008 #
 ###########################################################################
 #                                                                         #
 #                  * * * Alteracoes * * *                                 #
 #                                                                         #
 # Data       Autor Fabrica  Origem    Alteracao                           #
 # ---------- -------------- --------- ----------------------------------- #
 #-------------------------------------------------------------------------#


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto

     define ma_sinblqvcl array[100] of record
                                           aux          char(01),
                                           blqseq       like datksinblqvcl.blqseq,
                                           atdvclsgl    like datkveiculo.atdvclsgl,
                                           socvclcod    like datksinblqvcl.socvclcod,
                                           socvcltipdes char(30),
                                           nomgrr       like dpaksocor.nomgrr,
                                           blqdat       date,
                                           blqhor       datetime hour to second
                                       end record 

     define mr_sinblqvcl record
                              blqseq    like datksinblqvcl.blqseq, 
                              socvclcod like datksinblqvcl.socvclcod,
                              blqdat    like datksinblqvcl.blqdat,
                              blqsit    like datksinblqvcl.blqsit
                         end record 
                         
     define mr_motivo record
                          txt char(200)
                      end record                         
                   
     define m_ind   smallint,
            m_nomgrr like dpaksocor.nomgrr
  

#---------------------------#
 function ctc42m02_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select blqseq, ",
                       " socvclcod, ",
                       " blqdat, ",
                       " blqsit ",
                  " from datksinblqvcl ",
                 " where blqsit = 'S' "

     prepare pctc42m0201 from l_sql          
     declare cctc42m0201 cursor for pctc42m0201

     let l_sql = "select socvcltip, ",
                       " atdvclsgl, ",
                       " nomgrr ",     
                  " from datkveiculo vcl, ",                  
                       " dpaksocor   pst ",               
                 " where vcl.pstcoddig = pst.pstcoddig ",
                   " and vcl.socvclcod = ? "       

     prepare pctc42m0202 from l_sql          
     declare cctc42m0202 cursor for pctc42m0202

     let l_sql = "select cpodes ",                 
                  " from iddkdominio ",              
                 " where cponom = ? ",     
                   " and cpocod = ? "               

     prepare pctc42m0203 from l_sql                 
     declare cctc42m0203 cursor for pctc42m0203   

     let l_sql = "update datksinblqvcl ",
                   " set blqsit = 'N', ",
                       " dblusr = ?, ",
                       " dbqmtv = ?, ",
                       " dbqdat = current ",
                 " where blqseq = ? "   

     prepare pctc42m0205 from l_sql
     
     let l_sql = "select cpodes ",                 
                  " from iddkdominio ",              
                 " where cponom = ? "             

     prepare pctc42m0206 from l_sql                 
     declare cctc42m0206 cursor for pctc42m0206  
     
     let l_sql = "update datkmdt ",
                   " set mdtstt = 0 ",
                 " where mdtcod = ? "
     
     prepare pctc42m0207 from l_sql                    
     
     let l_sql = "select mdtcod ",
                  " from datkveiculo ",     
                 " where socvclcod = ? "     
     
     prepare pctc42m0208 from l_sql                  
     declare cctc42m0208 cursor for pctc42m0208      
     
       

 end function

#-------------------# 
 function ctc42m02()
#-------------------# 

     define l_arr smallint,
            l_scr smallint,
            l_confirma char(01),
            l_atl smallint,
            l_mdtcod like datkmdt.mdtcod
     
     options
          delete key f8
     
     
     initialize ma_sinblqvcl to null
   
     call ctc42m02_prepare()
     
     open cctc42m0201
     fetch cctc42m0201 into mr_sinblqvcl.*

     if  sqlca.sqlcode = 0 then
     
         
         
         open window ctc42m02 at 4,2 with form "ctc42m02"
         
         while true
         
             clear form
             
             if  not ctc42m02_carrega_array() then
                 exit while
             end if
             
             display array ma_sinblqvcl to s_ctc42m02.*
             
                 on key (f8)
             
                    let l_confirma = cts08g01("C",                                          
                                              "S",                                          
                                              "DESBLOQUEIO DE VEICULO",                     
                                              "ESSA OPERACAO IRA DESBLOQUEAR",              
                                              "O VEICULO.",
                                              "CONTINUAR MESMO ASSIM?")                     
                    
                    let m_ind = arr_curr()
                    
                    if  l_confirma = 'S' then                                               
                        
                        let l_atl = true
                        
                        open window ctc42m02a at 4,2 with form "ctc42m02a"
                        
                        while true

                            input by name mr_motivo.txt
                            
                            if  mr_motivo.txt is null then
                            
                                let l_confirma = cts08g01("C",                                            
                                                          "S",                                            
                                                          "DESBLOQUEIO DE VEICULO",                       
                                                          "SEM MOTIVO DE DESBLOQUEIO",                
                                                          "A VIATURA NAO SERA LIBERADA.",     
                                                          "DESEJA CONTINUAR MESMO ASSIM?")                       
                                
                                if  l_confirma = 'S' then      
                                    let l_atl = false
                                    exit while
                                end if
                            else
                                exit while
                            end if                               

                        end while
                            
                        close window ctc42m02a
                        
                        if  l_atl then
                            execute pctc42m0205 using g_issk.funmat,
                                                      mr_motivo.txt,
                                                      ma_sinblqvcl[m_ind].blqseq
                            
                            if  sqlca.sqlcode = 0 then
                                call ctc42m02_envia_e_mail()

                                open cctc42m0208 using ma_sinblqvcl[m_ind].socvclcod
                                fetch cctc42m0208 into l_mdtcod
                                
                                execute pctc42m0207 using l_mdtcod
                                
                            end if
                        end if
                        
                        exit display
                    end if                                                                
             
             end display
             
             if  int_flag then
                 exit while
             end if
             
         end while

         close window ctc42m02

     else
         if  sqlca.sqlcode = notfound then 
             error "Nao existem veiculos bloqueados."
         else
             error "ERRO: ", sqlca.sqlcode, " no acesso a tabela datksinblqvcl"
         end if
         sleep 2
     end if
 end function
 
 
# select vclcoddig, atdvclsgl, nomgrr
#   from datkveiculo vcl,
#        dpaksocor   pst
#  where vcl.pstcoddig = pst.pstcoddig
#    and vcl.socvclcod = 11
#    
#    
#select vclmrcnom,",                                     
#       vcltipnom,",                                 
#       vclmdlnom ",                                 
#       from agbkveic, outer agbkmarca, outer agbktip
#      where agbkveic.vclcoddig  = ? ",              
#        and agbkmarca.vclmrccod = agbkveic.vclmrccod
#        and agbktip.vclmrccod   = agbkveic.vclmrccod
#        and agbktip.vcltipcod   = agbkveic.vcltipcod

#---------------------------------#
 function ctc42m02_carrega_array()
#---------------------------------#
     
     define lr_ctc42m02 record
                            vclcoddig like datkveiculo.vclcoddig,
                            atdvclsgl like datkveiculo.atdvclsgl,
                            socvcltip like datkveiculo.socvcltip,
                            socvcltipdes char(50)
                        end record
     
     define l_aux   char(20)

     initialize  lr_ctc42m02.*, l_aux to null

     let m_ind = 1

     foreach cctc42m0201 into mr_sinblqvcl.*

         open cctc42m0202 using mr_sinblqvcl.socvclcod
         fetch cctc42m0202 into lr_ctc42m02.socvcltip,
                                lr_ctc42m02.atdvclsgl,
                                m_nomgrr   

         let l_aux = 'socvcltip'
         open cctc42m0203 using l_aux, 
                                lr_ctc42m02.socvcltip
         fetch cctc42m0203 into lr_ctc42m02.socvcltipdes

         let ma_sinblqvcl[m_ind].blqseq       = mr_sinblqvcl.blqseq
         let ma_sinblqvcl[m_ind].atdvclsgl    = lr_ctc42m02.atdvclsgl
         let ma_sinblqvcl[m_ind].socvclcod    = mr_sinblqvcl.socvclcod
         let ma_sinblqvcl[m_ind].socvcltipdes = lr_ctc42m02.socvcltipdes
         let ma_sinblqvcl[m_ind].nomgrr       = m_nomgrr
         let ma_sinblqvcl[m_ind].blqdat       = mr_sinblqvcl.blqdat
                                               
                                               
         let l_aux = extend(mr_sinblqvcl.blqdat, hour to hour), ":",
                     extend(mr_sinblqvcl.blqdat, minute to minute), ":",  
                     extend(mr_sinblqvcl.blqdat, second to second)

         let ma_sinblqvcl[m_ind].blqhor = l_aux
         
         let m_ind = m_ind + 1 
         
     end foreach
     
     if  m_ind = 1 then
         return false
     end if
     
     call set_count(m_ind-1)
     
     return true

 end function
 
#--------------------------------# 
 function ctc42m02_envia_e_mail()
#--------------------------------# 
 
     define l_cod_erro  integer,
            l_msg_erro  char(020),
            l_funnom    char(050),
            l_mail      char(050),
            l_mailpso   char(100),
            l_aux       char(100)       
     
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
                    
     initialize lr_mail.*, l_mailpso to null
     
     
     let l_aux = 'PSOMAILSIMCARD'
     open cctc42m0206 using l_aux                     
     foreach cctc42m0206 into l_mail
         let lr_mail.des = lr_mail.des clipped, ",", l_mail
     end foreach     

     let lr_mail.rem = "porto.socorro@portoseguro.com.br"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "DESBLOQUEIO DE VIATURA - SINCARD DIVERGENTE"
     let lr_mail.idr = "F0104577"
     let lr_mail.tip = "html"     
     
     call cty08g00_nome_func(g_issk.empcod, g_issk.funmat,"F")
          returning l_cod_erro,
                    l_msg_erro,
                    l_funnom

     let lr_mail.msg = "<html>",
                           "<body>",
                              "<table width=100% border=0 bgcolor=red cellpadding='0' cellspacing='5'>",
                                  "<tr>",
                                      "<td><font face=arial size=2 color=white><center><b>ATENCAO! LIBERACAO DE VIATURA COM SINCARD BLOQUEADO</b></center></font>",
                                      "</td>",
                                  "</tr>",
                              "</table>",
                              "<br>",
                              "<font face=arial size=2>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; A viatura ",
                              "<b>", ma_sinblqvcl[m_ind].atdvclsgl clipped,"</b> do prestador <b>", m_nomgrr clipped,"</b> foi ativada pelo usuario <b>", upshift(l_funnom) clipped,"</b> no dia <b>", 
                              extend(current,day to day),"/", 
                              extend(current,month to month),"/", 
                              extend(current,year to year),"</b> as <b>",
                              extend(current,hour to hour),":",
                              extend(current,minute to minute),":",
                              extend(current,second to second),"</b>",
                              ". Este veiculo havia sido bloqueado devido a nao conformidade do SIMCard cadastrado no Porto Socorro e o utilizado no veiculo.",
                           
                              "<br><br>",
                              "<table border=0 cellspacing=0 cellpadding=2 width=80%>",
                                  "<tr>",
                                      "<td bgcolor=#1B70E1><font size=2 color=white face=arial><b><center>",
                                      "Motivo do Desbloqueio</b></font></center></td>",
                                  "</tr>",
                                  "<tr>",
                                      "<td bgcolor=#E2E9F1><font size=2 face=arial>", mr_motivo.txt clipped,"</td>",
                                  "</tr>",
                              "</table>",
                              "<br>Porto Seguro - Informatica<br>"
                              
      let l_aux = 'PSOASSINATURAMAIL'
      open cctc42m0206 using l_aux                     
      foreach cctc42m0206 into l_mail
          let l_mailpso = l_mailpso clipped, ",", l_mail
      end foreach
                   
     let lr_mail.msg = lr_mail.msg clipped, "<a href=mailto:", l_mailpso,">Sistemas Araguaia</a>",
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
