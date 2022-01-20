#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : Central 24hs                                            #
#  Modulo         : wdatc057.4gl                                            #
#                   Tela de entrada de dados para selecao de servicos       #
#                   bloqueados.                                             #
#  Analista Resp. : Carlos Zyon                                             #
#  PSI            : 177890                                                  #
#...........................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE - Rodrigo Santos - OSF 29106        #
#  Liberacao      :                                                         #
#...........................................................................#
#                     * * * A L T E R A C A O * * *                         #
#                                                                           #
#  Data         Autor Fabrica  Observacao                                   #
#  ----------   -------------  -------------------------------------------  #
#                                                                           #
#---------------------------------------------------------------------------#

database porto

main

  call wdatc057_validausuario()
  call wdatc057_preparasql()
  call wdatc057_montapagina()

end main


#---------------------------------------------------------------------------#
function wdatc057_validausuario()
#---------------------------------------------------------------------------#

  define param           record
         usrtip          char (1),
         webusrcod       char (06),
         sesnum          char (10),
         macsissgl       char (10)
  end record

 define ws2              record
        statusprc        dec  (1,0),
        sestblvardes1    char (256),
        sestblvardes2    char (256),
        sestblvardes3    char (256),
        sestblvardes4    char (256),
        sespcsprcnom     char (256),
        prgsgl           char (256),
        acsnivcod        dec  (1,0),
        webprscod        dec  (16,0)
 end record

 initialize param.* to null
 initialize ws2.* to null

  #------------------------------------------
  #  ABRE BANCO   (TESTE ou PRODUCAO)
  #------------------------------------------
  call fun_dba_abre_banco("CT24HS")
  set isolation to dirty read

  let param.usrtip    = arg_val(1)
  let param.webusrcod = arg_val(2)
  let param.sesnum    = arg_val(3)
  let param.macsissgl = arg_val(4)

  #---------------------------------------------
  #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
  #---------------------------------------------

  call wdatc002(param.*)
       returning ws2.*

  if ws2.statusprc <> 0 then
     display "NOSESS"
            ,"@@"
            ,"Por quest\365es de seguran\347a seu tempo de<BR> permanência "
            ,"nesta p\341gina atingiu o limite m\341ximo.@@"
     exit program(0)
  end if

#---------------------------------------------------------------------------#
end function  # wdatc057_validausuario()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc057_preparasql()
#---------------------------------------------------------------------------#

   declare cwdatc057001 cursor for
    select c24fsecod
          ,c24fsedes
      from datkfse
     where c24fsecod <> 2

   declare cwdatc057002 cursor for
    select c24evtcod
          ,c24evtrdzdes
      from datkevt
     where c24evtstt = 'A'

#---------------------------------------------------------------------------#
end function  # wdatc057_preparasql()
#---------------------------------------------------------------------------#


#---------------------------------------------------------------------------#
function wdatc057_montapagina()
#---------------------------------------------------------------------------#

   define   l_fase         record
            c24fsecod      like   datkfse.c24fsecod
           ,c24fsedes      like   datkfse.c24fsedes
   end record

   define   l_evento       record
            c24evtcod      like   datkevt.c24evtcod
           ,c24evtrdzdes   like   datkevt.c24evtrdzdes
   end record

   define   l_tag          char(3000)

   initialize l_tag to null
   initialize l_fase.* to null
   initialize l_evento.* to null

   display "PADRAO@@5"
          ,"@@De@@0@@@@(dd/mm/aaaa)@@10@@10"
          ,"@@text@@de@@@@this.value=wiasc007_formataData(this.value);"

   display "PADRAO@@5"
          ,"@@Até@@0@@@@(dd/mm/aaaa)@@10@@10"
          ,"@@text@@ate@@@@this.value=wiasc007_formataData(this.value);"

   let l_tag = "PADRAO@@2@@fase@@Fase@@0@@"
              ,"@@TODOS@@1@@0"

   foreach cwdatc057001 into l_fase.*

     let l_tag = l_tag clipped
                ,"@@"
                , l_fase.c24fsedes clipped
                ,"@@0@@", l_fase.c24fsecod using "<<"

   end foreach

   display l_tag clipped
   
   let l_tag = "PADRAO@@2@@evento@@Evento@@0@@"
              ,"@@TODOS@@1@@0"

   foreach cwdatc057002 into l_evento.*

     let l_tag = l_tag clipped
                ,"@@"
                , l_evento.c24evtrdzdes clipped
                ,"@@0@@", l_evento.c24evtcod using "<<"

   end foreach

   display l_tag clipped

#---------------------------------------------------------------------------#
end function  # wdatc057_montapagina()
#---------------------------------------------------------------------------#

