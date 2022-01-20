#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: ctg25                                                      #
# Objetivo.......: Modulo Principal de Cadastro do Siebel                     #
# Analista Resp. : Amilton Pinto                                              #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 12/08/2013                                                 #
#.............................................................................#
# Base de Beneficios Auto e RE Itau - sprint SPR-2015-20047/IN                #
#.............................................................................#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
  define m_prep smallint
  define w_data date
  define w_log     char(60)

end globals

#------#
  main
#------#
   call fun_dba_abre_banco("CT24HS")
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg25.log"

   call startlog(w_log)

   call get_param()

    select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last - 1,
      message line last,
      accept  key  F40

   whenever error continue
   initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O  S E G U R O " AT 1,30
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns

   call p_reg_logo()

    display "---------------------------------------------------------------",
           "-------ctg25---" at 03,01

   call ctg25_menu()

end main


#=====================
 function ctg25_menu()
#=====================

 menu "SIEBEL: "
      before menu
      show option "Cadastros"
      show option "Regras"
      show option "Encerra"

      command key ("C") "Cadastros"
                        "Cadastros Basicos"
                         call ctg25_cadastro()

      command key ("R") "Regras"
                        "Cadastros do Motor de Regras"
                         call ctg25_regras()


      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu

  close window WIN_MENU
  close window WIN_CAB

end function



#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)

	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function

#=================================
 function ctg25_cadastro()
#=================================

 menu "CADASTROS: "
      before menu
      show option "Porto"
      show option "Azul"
      show option "Itau"
      show option "Limpeza"
      show option "Encerra"
      
      command key ("P") "Porto"
                        "Cadastros Porto"
                         call ctg25_cadastro_porto()
                         
      command key ("A") "Azul"
                        "Cadastros Azul"
                         call ctg25_cadastro_azul()
                                                 
      command key ("I") "Itau"
                        "Cadastros Itau"
                         call ctg25_cadastro_itau()    
                         
      command key ("L") "Limpeza"
                        "Cadastros da Limpeza do Movimento"
                         call ctg25_cadastro_limpeza()                       
                                          
                         
      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu
  end menu
end function

#=====================================
 function ctg25_cadastro_porto_apol()
#=====================================
 menu "CADASTROS PORTO APOLICE: "
      before menu
      show option "Parametros"
      show option "Categoria"
      show option "Classe"
      show option "Clausula"
      show option "Cobertura"
      show option "E-Mails"
      show option "Dominio"
      show option "Especialidade"
      show option "De-Para"
      show option "Encerra"

      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m28()
      command key ("T") "Categoria"
                        "Consulta de Categorias Tarifarias"
                         call ctc69m12()

      command key ("L") "Classe"
                        "Consulta de Classes de Localizacao"
                         call ctc69m14()

      command key ("A") "Clausula"
                        "Consulta de Clausulas"
                         call ctc69m18()

      command key ("C") "Cobertura"
                        "Consulta de Coberturas"
                         call ctc69m13()

      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m29()
      command key ("D") "Dominio"
                        "Cadastro de Dominios"
                         call ctc69m19()
      command key ("S") "Especialidade"
                        "Cadastro de Especialidades"
                         call ctc69m23()
      command key ("F") "De-Para"
                        "Cadastro de De-Para's"
                         call ctg25_depara()


      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu
  end menu
  
end function

#=====================================
 function ctg25_cadastro_porto_prop()
#=====================================
 menu "CADASTROS PORTO PROPOSTA: "
      before menu
      show option "Parametros"
      show option "E-Mails"
      show option "Encerra"

      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m39()
     

      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m40()
     
      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu
  end menu
  
end function

#=====================================
 function ctg25_cadastro_porto()
#=====================================
 menu "CADASTROS PORTO PROPOSTA: "
      before menu
      show option "Apolice"
      show option "Proposta"
      show option "Encerra"

      command key ("A") "Apolice"
                        "Cadastro Porto Apolice"
                         call ctg25_cadastro_porto_apol()
     

      command key ("P") "Proposta"
                        "Cadastro Porto Proposta"
                         call ctg25_cadastro_porto_prop()
     
      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu
  end menu
  
end function

#=================================
 function ctg25_cadastro_azul()
#=================================
 menu "CADASTROS AZUL: "
      before menu
      show option "Parametros"
      show option "Clausula"
      show option "Cobertura"
      show option "E-Mails"
      show option "Encerra"
      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m26()
      command key ("A") "Clausula"
                        "Cadastro de Clausulas"
                         call ctc69m27()
      command key ("C") "Cobertura"
                        "Cadastro de Coberturas"
                         call ctc69m32()
      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m30()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function

#=================================
 function ctg25_cadastro_itau()
#=================================
 
 menu "CADASTROS ITAU: "
      before menu
      show option "Auto"
      show option "RE"
      show option "Encerra"
      
      command key ("A") "Auto"
                        "Cadastros do Auto"
                         call ctg25_cadastro_itau_auto()
     
      command key ("R") "RE"
                        "Cadastros do RE"
                         call ctg25_cadastro_itau_re()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function

#====================================
 function ctg25_cadastro_itau_auto1()
#====================================
 
 menu "CADASTROS ITAU AUTO: "
      before menu
      show option "Parametros"
      show option "E-Mails"
      show option "Encerra"
      
      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m33()
     
      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m34()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function


#====================================
 function ctg25_cadastro_itau_re()
#====================================
 
 menu "CADASTROS ITAU RE: "
      before menu
      show option "Parametros"
      show option "E-Mails"
      show option "Encerra"
      
      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m35()
     
      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m36()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function

#====================================
 function ctg25_cadastro_limpeza()
#====================================
 
 menu "CADASTROS LIMPEZA MOVIMENTO: "
      before menu
      show option "Parametros"
      show option "E-Mails"
      show option "Encerra"
      
      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m37()
     
      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m38()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function

#==========================
 function ctg25_regras()
#=========================

 menu "REGRAS: "
      before menu
      show option "Porto"
      show option "Azul"
      show option "Itau"     
      show option "Encerra"


      command key ("P") "Porto"
                        "Cadastro de Regras da Porto"
                         call ctc69m06()
                         
      command key ("A") "Azul"
                        "Cadastro de Regras da Azul"
                         call ctc69m41()
                         
      command key ("I") "Itau"
                        "Cadastro de Regras do Itau"
                         call ctg25_regra_itau()                                     


      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function
#=========================
 function ctg25_depara()
#========================
 menu "DE-PARA: "
      before menu
      show option "Especialidade"
      show option "Pacote"
      show option "Encerra"
      command key ("C") "Especialidade"
                        "De-Para de Especialidade"
                         call ctc69m24()
      command key ("R") "Pacote"
                        "De-Para de Pacote"
                         call ctc69m25()
      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu
  end menu
  
end function

#====================================
 function ctg25_regra_itau_auto()
#====================================
 
 menu "REGRAS: "
      before menu
      show option "Nova_Emissao"
      show option "Antiga_Emissao"
      show option "Encerra"
      
      command key ("N") "Nova_Emissao"
                        "Cadastro de Parametros"
                         call ctc69m43() 
     
      command key ("A") "Antiga_Emissao"
                        "Cadastro de E-Mails"
                         call ctc69m42() 

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu

end function  

#=================================
 function ctg25_regra_itau()
#=================================
 
 menu "CADASTROS ITAU: "
      before menu
      show option "Auto"
      show option "RE"
      show option "Encerra"
      
      command key ("A") "Auto"
                        "Regras do Auto"
                         call ctg25_regra_itau_auto()
     
      command key ("R") "RE"
                        "Regras do RE"
                         call ctc69m44()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function

#====================================
 function ctg25_cadastro_itau_auto()
#====================================
 
 menu "REGRAS: "
      before menu
      show option "Nova_Emissao"
      show option "Antiga_Emissao"
      show option "Encerra"
      
      command key ("N") "Nova_Emissao"
                        "Cadastro de Parametros"
                         call ctg25_cadastro_itau_auto2() 
     
      command key ("A") "Antiga_Emissao"
                        "Cadastro de E-Mails"
                         call ctg25_cadastro_itau_auto1()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu

end function 

#====================================
 function ctg25_cadastro_itau_auto2()
#====================================
 
 menu "CADASTROS ITAU AUTO: "
      before menu
      show option "Parametros"
      show option "E-Mails"
      show option "Encerra"
      
      command key ("P") "Parametros"
                        "Cadastro de Parametros"
                         call ctc69m45()
     
      command key ("M") "E-Mails"
                        "Cadastro de E-Mails"
                         call ctc69m46()

      command key (interrupt,E) "Encerra"
             "Fim de servico"
             exit menu

  end menu


end function 