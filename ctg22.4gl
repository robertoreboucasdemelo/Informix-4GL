###########################################################################
# Nome do Modulo: ctg22                                  Helder Oliveira  #
#                                                                         #
# Modulo Principal Cadastros ITAU                                Dez/2010 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################

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
   let w_log = w_log clipped,"/dat_ctg22.log"

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
   display "I T A U  S E G U R O S" AT 1,30
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns

   call p_reg_logo()

    display "---------------------------------------------------------------",
           "-------ctg22---" at 03,01

   call ctg22_menu()

end main


#=====================
 function ctg22_menu()
#=====================

 menu "ITAU: "

      command "Automovel"
                "Cadastro, Regras e  Inconsistencia Automovel"
                 call ctg22_automovel()

      command "Residencial"
                "Cadastro, Regras e  Inconsistencia Automovel"
                 call ctg22_residencial()

       command key (interrupt,E) "Encerra"
              "Fim de servico"
              exit menu

  end menu

  close window WIN_MENU
  close window WIN_CAB

end function

function ctg22_automovel()

 menu "AUTOMOVEL:"

      command "Cadastro"
                "Cadastro ITAU"
                 call ctg22_cadastro()

      command "Regras"
                "Regras ITAU"
                 call ctc92m00()

      command "Inconsistencia"
                "Consulta e tratamento das inconsistencias registradas."
                 call ctc91m20_input()

       command key (interrupt,E) "Encerra"
              "Fim de servico"
              exit menu

  end menu


end function

function ctg22_residencial()

 menu "RESIDENCIAL: "

      command "Cadastro"
                "Cadastro ITAU"
                 call ctg22_cadastro_re()

      command "Regras"
                "Regras ITAU"
                 call ctc97m00()

      command "Inconsistencia"
                "Consulta e tratamento das inconsistencias registradas."
                 call ctc97m20_input()

       command key (interrupt,E) "Encerra"
              "Fim de servico"
              exit menu

  end menu

 
end function




#========================
function ctg22_cadastro()
#========================
define r_return record
        carnom      char(100)
       ,lgdtip      like datkrpdatdcen.lgdtipdes
       ,lgdnom      like datkrpdatdcen.lgdnom
       ,lgdnum      like datkrpdatdcen.lgdnum
       ,brrnom      like datkrpdatdcen.brrnom
       ,cidnom      like datkrpdatdcen.cidnom
       ,ufdcod      like datkrpdatdcen.endufdsgl
       ,lgdcep      char(5)
       ,lgdcepcmp   char(3)
       ,endlgdcmp   like datkrpdatdcen.endcmpdes
       ,lclltt      like datkrpdatdcen.atdcenltt
       ,lcllgt      like datkrpdatdcen.atdcenlgt
       ,lclcttnom   char(100) # nome responsavel
       ,dddcod      like datkrpdatdcen.teldddnum
       ,lcltelnum   like datkrpdatdcen.telnum
       ,lclidttxt   char(100) # referencia do local - nao tem no cadastro 18/05/11
       ,stt         smallint
end record


   menu "CADASTROS: "
      before menu


         show option "Companhia"
         show option "Empresa"
         show option "Plano"
         show option "Produto"
         show option "Carro_Reserva"
         show option "Segmento"
         show option "Carga"
         show option "Score"
         show option "Servico"
         show option "Motivo"
         show option "Tp. Incons"
         show option "Garantia_Car_Res"
         show option "Ramo"
         show option "Unibanco"
         show option "C.A.R."
         show option "Oficina"
         show option "Tp_Assunto_Plano"
         show option "Pessoa_VIP"
         show option "Modalidade_Frota"
         show option "Canal_Venda"
         show option "Tp_Veiculo"
         show option "Grupo_Produto"

         show option "Encerra"

      command "Companhia"
              "Manutencao do cadastro da Companhia"
               call ctc91m00_input_array()

      command "Empresa"
              "Manutencao do cadastro de Assistencia Empresa"
               call ctc91m01_input_array()

      command "Plano"
              "Manutencao do cadastro do Plano Seguro"
               call ctc91m02_input_array()

      command "Produto"
              "Manutencao do cadastro do Produto"
               call ctc91m03_input_array()

      command "Carro_Reserva"
              "Manutencao do cadastro do Carro Reserva"
               call ctc91m04_input_array()

      command "Segmento"
              "Manutencao do cadastro do Segmento do Cliente"
               call ctc91m05_input_array()

      command "Carga"
              "Manutencao do cadastro do Tipo de Carga do Veiculo"
               call ctc91m06_input_array()

      command "Score"
              "Manutencao do cadastro do Score do Cliente"
               call ctc91m07_input_array()

      command "Servico"
              "Manutencao do cadastro de Servico Assistencia"
               call ctc91m08_input_array()

      command "Motivo"
              "Manutencao do cadastro de Motivo de Cancelamento"
               call ctc91m09_input_array()

      command "Tp. Incons"
              "Manutencao do cadastro de Tipo de Inconsistencia "
               call ctc91m10_input_array()

      command "Garantia_Car_Res"
              "Garantia do Carro Reserva"
               call ctc91m11_input_array()

      command "Ramo"
              "Manutencao do cadastro de Ramo "
               call ctc91m12_input_array()

      command "Unibanco"
              "Manutencao do cadastro de Codigo Unibanco"
               call ctc91m13_input_array()

      command "C.A.R."
              "Manutencao Centro de Atendimento Rapido"
              call ctc91m14()

      command "Oficina"
              "Manutencao de Oficinas Referenciadas"
              call ctc91m18()

      command "Tp_Assunto_Plano"
              "Manutencao Motivo Reserva das Regras Itau"
              call ctc92m07_input_array()

      command "Pessoa_VIP"
              "Manutencao Pessoas VIP Itau"
              call ctc92m08_input_array()

      command "Modalidade_Frota"
              "Manutencao do cadastro de Modalidade de Frota"
              call ctc91m15_input_array()

      command "Canal_Venda"
              "Manutencao do cadastro de Canal de Venda"
              call ctc91m16_input_array()

      command "Tp_Veiculo"
              "Manutencao do cadastro de Tipo de Veiculo"
              call ctc91m17_input_array()
              
      command "Grupo_Produto"
              "Manutencao do cadastro de Grupos do Produto"
              call ctc91m38()        
      
      command "Encerra"
              "Fim de servico"
              exit menu

   end menu

end function

#========================
function ctg22_cadastro_re()
#========================


   menu "CADASTROS RE: "
      before menu

     


         show option "Plano"
         show option "Produto"
         show option "Segmento"
         show option "Servico"
         show option "Tipo Cobertura"
         show option "Tipo Residencia"
         show option "Tipo Moradia"
         show option "Encerra"

      command "Plano"
              "Manutencao do cadastro do Plano Seguro"
               call ctc96m04_input_array()

      command "Produto"
              "Manutencao do cadastro do Produto"
               call ctc96m00_input_array()

      command "Segmento"
              "Manutencao do cadastro do Segmento do Cliente"
               call ctc96m02_input_array()

      command "Servico"
              "Manutencao do cadastro de Serviço Assistencia"
               call ctc96m01_input_array()

      command "Tipo Cobertura"
              "Manutencao do cadastro de Serviço Assistencia"
               call ctc96m06_input_array()

      command "Tipo Residencia"
              "Manutencao do cadastro de Serviço Assistencia"
               call ctc96m07_input_array()

      command "Tipo Moradia"
              "Manutencao do cadastro de Serviço Assistencia"
               call ctc96m08_input_array()

      command "Encerra"
              "Fim de servico"
              exit menu

   end menu

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
     display "ITAU SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)
end function
