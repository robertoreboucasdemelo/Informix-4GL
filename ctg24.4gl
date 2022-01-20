##############################################################################
# Nome do Modulo: ctg24                                          Beatriz     #
#                                                                 Araujo     #
# Menu do controle de socorristas                                ABR/2012    #
##############################################################################
##############################################################################
# NIVEIS DE ACESSO: 2 - Consultas                                            #
#                   6 - Atualizacoes                                         #
#                   8 - Dono do sistema                                      #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
##############################################################################
 globals "/homedsa/projetos/geral/globals/glct.4gl"  
 define  w_log    char(60)     
  
MAIN  
  
   define x_opcao char(10)  
   define x_data  date  
   define l_situacao smallint  
  
   let l_situacao = null  
  
   call fun_dba_abre_banco("CT24HS")  
  
   let w_log = f_path("ONLTEL","LOG")   
   if w_log is null then  
      let w_log = "."  
   end if  
   let w_log = w_log clipped,"/dat_ctg24.log"  
  
   call startlog(w_log)  
  
   #------------------------------------------  
   #  ABRE BANCO   (TESTE ou PRODUCAO)  
   #------------------------------------------  
  
   select sitename into g_hostname from  dual  
  
   defer interrupt  
   set lock mode to wait  
  
   options  
      prompt  line last,  
      comment line last,  
      message line last,  
      accept  key  F40  
  
   whenever error continue  
  
   open window WIN_CAB at 2,2 with 22 rows,78 columns  
        attribute (border)  
  
   let x_data = today  
   display "PORTO SOCORRO"  at 1,1  
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20  
   display x_data       at 1,69  
  
   open window WIN_MENU at 4,2 with 20 rows, 78 columns  
   call p_reg_logo()  
   call get_param()  
  
   display "--------------------------------------------------------------",  
           "---------ctg24--" at 3,1  
  
   menu "FROTA"  
  
   before menu  
      hide option all  
           show option "soCorristas"  
           show option "bloq_sOcorrista"  
  
           if g_issk.acsnivcod >= 2 and  
             (g_issk.dptsgl = "psocor" or g_issk.dptsgl = "desenv") then  
             show option "canDidatos"  
           end if   
           show option "Encerra"  
  
      command key ("D") "canDidatos"  
                        "Manutencao do cadastro de candidatos a socorristas"  
        call ctc39m00()  
  
      command key ("C") "soCorristas"  
                        "Manutencao do cadastro de socorristas"  
        call ctc44m00("","","","","","","","","","","","","")  
  
      command key ("O") "bloq_sOcorrista"                           
                  "Manutencao do seguro de vida de socorristas" 
      call ctc44m08()   

      command key (interrupt, "E") "Encerra"  
                        "Fim de servico"  
         exit menu  
   end menu  
  
   close window win_cab  
   close window win_menu  
  
END MAIN  
  
#----------------------------------------------------------  
 function p_reg_logo()  
#----------------------------------------------------------  
  
 define ba char(01)  
  
 open form reg from "apelogo2"  
 display form reg  
 let ba = ascii(92)  
 display ba at 15,23  
 display ba at 14,22  
 display "PORTO SEGURO" AT 16,52  
 display "                                  Seguros" at 17,23 attribute (reverse)  
  
end function  
