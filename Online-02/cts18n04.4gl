###############################################################################
# Nome do Modulo: CTS18N04                                           Marcelo  #
#                                                                    Gilberto #
# Menu de descricao/comentarios sobre acidente                       Ago/1997 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function cts18n04(d_cts18n04)
#---------------------------------------------------------------

 define d_cts18n04  record
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano
 end record



 open window w_cts18n04 at 04,02 with 20 rows, 78 columns

 display "--------------------------------------------------------------",
         "------cts18n04--" at 03,01

 menu "ACIDENTE"
    command key ("D")           "Descricao"
                                "Descricao do acidente"
       call cts18n04_menu(d_cts18n04.*, "D")
       next option "Comentarios"

    command key ("C")           "Comentarios"
                                "Comentarios do atendente"
       call cts18n04_menu(d_cts18n04.*, "C")
       next option "Encerra"

    command key (interrupt,E)   "Encerra"    "Retorna ao menu anterior"
       if g_documento.acao is not null then
          error " Obrigatorio registrar algo no historico!"
          next option "Descricao"
       else
          exit menu
       end if
 end menu

 close window w_cts18n04

end function  ###  cts18n04

#---------------------------------------------------------------
 function cts18n04_menu(d_cts18n04)
#---------------------------------------------------------------

 define d_cts18n04  record
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano,
    sinacdflg       like ssamavsdes.sinacdflg
 end record



 open window w_cts18m04 at 04,02 with form "cts18m04"
                        attribute (form line first)

 call cts18n04_cab(d_cts18n04.*)

 menu "HISTORICO"
    command key ("I")           "Implementa"
                                "Implementa informacoes"
       call cts18m04("I",d_cts18n04.*)
       clear form
       call cts18n04_cab(d_cts18n04.*)
       next option "Encerra"

    command key ("C")           "Consulta"
                                "Consulta informacoes cadastradas"
       call cts18m04("C",d_cts18n04.*)
       clear form
       call cts18n04_cab(d_cts18n04.*)
       next option "Encerra"

    command key (interrupt,"E") "Encerra"    "Retorna ao menu anterior"
        if g_documento.acao is not null then
           error " Obrigatorio registrar algo no historico!"
           next option "Implementa"
        else
           exit menu
        end if
 end menu

 close window w_cts18m04

 let int_flag = false

end function  ###  cts18n04_menu

#---------------------------------------------------------------
 function cts18n04_cab(d_cts18n04)
#---------------------------------------------------------------

 define d_cts18n04  record
    sinavsnum       like ssamavsdes.sinavsnum,
    sinavsano       like ssamavsdes.sinavsano,
    sinacdflg       like ssamavsdes.sinacdflg
 end record

 define w_sinavs    char (11)


	let	w_sinavs  =  null

 let w_sinavs = d_cts18n04.sinavsnum using "&&&&&&", "-",
                d_cts18n04.sinavsano

 display w_sinavs to sinavs

 if d_cts18n04.sinacdflg = "D"  then
    display  "DESCRICAO DO ACIDENTE   "  to cabec
 else
    display  "COMENTARIOS DO ATENDENTE"  to cabec
 end if

end function  ###  cts18n04_cab
