##########################################################################
# Nome do Modulo: CTN06N00                                      Marcelo  #
#                                                               Gilberto #
# Menu de Consulta de Oficinas                                  Jun/1997 #
##########################################################################
#                              MANUTENCOES
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#-------------------------------------------------------------------------
database porto

#--------------------------------------------------------------------------
 function ctn06n00(param)
#--------------------------------------------------------------------------

 define param       record
    ramcod          like gtakram.ramcod,
    tela            char (08)
 end record

 define k_ctn06n00  record
    pstcoddig       like gkpkpos.pstcoddig,
    nomrazsoc       like gkpkpos.nomrazsoc,
    endlgd          like gkpkpos.endlgd,
    endbrr          like gkpkpos.endbrr,
    endcid2         like gkpkpos.endcid,
    endufd2         like gkpkpos.endufd
 end record

 define ws          record
    endcep          like glaklgd.lgdcep,
    endcepcmp       like glaklgd.lgdcepcmp,
    psqtip          dec(1,0) ,
    grtmecflg       char (01)
 end record




  initialize  k_ctn06n00.*  to  null

  initialize  ws.*  to  null

 let int_flag = false
 initialize k_ctn06n00.*  to null
 initialize ws.*          to null

 if param.ramcod = 16  or    ###  Garantia Mecanica
    param.ramcod = 524  then  ###  Garantia Mecanica
    let ws.grtmecflg = "S"
 else
    let ws.grtmecflg = "N"
 end if

 open window w_ctn06n00 at 4,2 with 20 rows,78 columns

 display "---------------------------------------------------------------",
         "-----ctn06n00--" at 3,1

 menu "OFICINAS"

   command key ("N") "Nome"
                     "Consulta oficinas por NOME "

           let ws.psqtip = 2
           call ctn06c01(ws.endcep, ws.psqtip, ws.grtmecflg,param.tela)
                returning k_ctn06n00.pstcoddig,
                          k_ctn06n00.nomrazsoc,
                          k_ctn06n00.endlgd,
                          k_ctn06n00.endbrr,
                          k_ctn06n00.endcid2,
                          k_ctn06n00.endufd2
           exit menu

   command key ("C") "Cep"
                     "Consulta oficinas por CEP"

        call ctn00c02 ("SP","SAO PAULO"," "," ")
             returning ws.endcep, ws.endcepcmp

        if ws.endcep is null     then
           error "Nenhum criterio foi selecionado!"
        else
           let ws.psqtip = 1
           call ctn06c01(ws.endcep, ws.psqtip, ws.grtmecflg,param.tela)
                returning k_ctn06n00.pstcoddig,
                          k_ctn06n00.nomrazsoc,
                          k_ctn06n00.endlgd,
                          k_ctn06n00.endbrr,
                          k_ctn06n00.endcid2,
                          k_ctn06n00.endufd2
           exit menu
        end if
   command key ("R") "Relatorios"
                     "Relatorio de atendimentos por oficinas"
        call ctr00m00()
        exit menu

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
        exit menu
        clear screen

   end menu

   let int_flag = false
   close window w_ctn06n00

   return k_ctn06n00.pstcoddig,
          k_ctn06n00.nomrazsoc,
          k_ctn06n00.endlgd,
          k_ctn06n00.endbrr,
          k_ctn06n00.endcid2,
          k_ctn06n00.endufd2

end function  ###  ctn06n00
