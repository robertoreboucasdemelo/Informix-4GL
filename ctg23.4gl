# Data         Autor         PSI             Descrição                        #
# -----------  ------------- -------------   -------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                                                             #
###############################################################################


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
  define w_data date
  define w_log     char(60)
end globals


define m_prep     smallint
define l_data     date

#######################################################
  main
#######################################################
  call fun_dba_abre_banco("EMISAUTO")
  let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/ctg23.log"

   call startlog(w_log)

   #select sitename into g_hostname from dual

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue
   #initialize g_ppt.* to null

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns

   call p_reg_logo()

    display "---------------------------------------------------------------",
           "-----ctg23---" at 03,01

   # "Comparação Proposta Fase I"
   call cty21g00_input()

end main

   
#################################################################
 
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