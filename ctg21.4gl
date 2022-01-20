#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctg21.4gl                                                 #
# Psi            : 228087                                                    #
#............................................................................#
# Desenvolvimento: Patricia Egri Wissinievski                                #
# Liberacao      :  /  /2008                                                 #
# Objetivo : Consulta Remuneracao variavel atendentes.                        #
#............................................................................#


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define w_log     char(60)



 define m_prep_sql      smallint


MAIN
   define w_data    date

   initialize g_c24paxnum   to null
   initialize g_documento.* to null

   call fun_dba_abre_banco("CT24HS")
   
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg21.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   

   select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue
   initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()



   display "---------------------------------------------------------------",
           "---------ctg21--" at 03,01

   menu "OPCOES"

   before menu
          hide option all
          if g_issk.prgsgl = "ctg21T" then
             let g_issk.prgsgl = "ctg21"
          end if
            show option "Extrato_RV"
            show option "Encerra"



      command key ("Z") "Extrato_RV"
                        "Remuneracao Variavel Atendimento"
              call ctc85m00()

      command key (interrupt,E) "Encerra" "Fim de servico"
         exit menu
   end menu

   close window win_cab
   close window win_menu

   let int_flag = false

END MAIN

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

