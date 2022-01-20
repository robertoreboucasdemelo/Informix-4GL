 ##########################################################################
 # Nome do Modulo: CTN27N00                                      Marcelo  #
 #                                                               Gilberto #
 # Menu de consulta transmissoes (Fax/Imp Remota/MDT)            Set/1996 #
 ##########################################################################

 database porto

#--------------------------------------------------------------------------
 function ctn27n00()
#--------------------------------------------------------------------------
   let int_flag = false

   open window w_ctn27n00 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn27n00--" at 3,1

   menu "TRANSMISSOES"
     command key ("F") "Fax"
                 "Consulta servicos enviados por fax"
          call ctn27c00()

     command key ("I") "Imp_remota"
                 "Consulta servicos enviados para impressoras remotas"
          call ctn28c00()

     command key ("V") "MDT_enViada"
                 "Consulta mensagens enviadas para MDT's"
          call ctn43c00("","")

     command key ("R") "MDT_Recebida"
                 "Consulta mensagens recebidas dos MDT's"
          call ctn44c00(1,"","")

     command key ("T") "Teletrim"
                 "Consulta mensagens enviadas para TELETRIM"
          call ctn48c00()

     command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       exit menu

     clear screen
   end menu

   close window w_ctn27n00
   let int_flag = false

end function  # ctn27n00
