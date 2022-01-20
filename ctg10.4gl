 ##############################################################################  
 # Nome do Modulo: ctg10                                          Gilberto    #  
 #                                                                 Marcelo    #  
 # Menu do controle de frotas                                     Set/1998    #  
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
 # 30/10/2000  AS 22214     Ruiz         Chama funcao abre banco              #  
 #----------------------------------------------------------------------------#  
#                  * * *  A L T E R A C O E S  * * *                          #  
#                                                                             #  
# Data       Autor Fabrica         PSI    Alteracoes                          #  
# ---------- --------------------- ------ ------------------------------------#  
# 10/09/2005 JUNIOR (Meta)      Melhorias alterado de systables para dual     # 
#-----------------------------------------------------------------------------# 
# 05/05/2010 Burini                255734 Integração Vistoria x PSO           #
#-----------------------------------------------------------------------------#
# 25/06/2010 Beatriz Araujo        258024 Bloqueio de socorristas sem seguro  #
#                                         de vida                             #  
###############################################################################  
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
   let w_log = w_log clipped,"/dat_ctg10.log"  
  
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
           "---------ctg10--" at 3,1  
  
   menu "FROTA"  
  
   before menu  
      hide option all  
           show option "Veiculos"  
           show option "Trajetos"  
           show option "bloq_viStoria" 
           show option "Encerra"  
  
      command key ("V") "Veiculos"  
                        "Manutencao dos cadastros de veiculos do Porto Socorro"  
        call ctc34n00()  
  
      command key ("S") "bloq_viStoria"                               
                        "Manutencao das vistorias dos veiculos "  
        call ctc90m00()                                           
  
      command key ("P") "Pagers"  
                        "Manutencao do cadastro de pagers para impressao remota"  
        call ctc34m09()  
  
      command key ("T") "Trajetos"  
                        "Horario/Quilometragens dos veiculos da Porto Seguro"  
        initialize g_documento.*   to null  
        call ctb13m00()  
  
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
