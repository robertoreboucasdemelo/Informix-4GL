###############################################################################
# Nome do Modulo: CTS06M06                                              Pedro #
#                                                                     Marcelo #
# Inclui/Altera quantidade de vistorias autorizadas                  Jan/1995 #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts06m06()
#------------------------------------------------------------

 define d_cts06m06    record
    diasem            char (07)                    ,
    vstdat            like datmvstagen.vstdat      ,
    succod            like datmvstagen.succod      ,
    atrvstqtdc24      like datmvstagen.atrvstqtdc24,
    vstqtdaut         like datmvstagen.vstqtdaut   ,
    vstqtdc24         like datmvstagen.vstqtdc24   ,
    vstqtdvol         like datmvstagen.vstqtdvol
 end record

 define ws            record
    operacao          char(01),
    sucnom            like gabksuc.sucnom
 end record




	initialize  d_cts06m06.*  to  null

	initialize  ws.*  to  null

 open window w_cts06m06 at  06,02 with form "cts06m06"
             attribute(form line first)

 initialize d_cts06m06.*  to null

 while true

   let int_flag  =  false
   initialize ws.*  to null
   display by name ws.sucnom

   input by name d_cts06m06.vstdat,
                 d_cts06m06.succod

      before field vstdat
         display by name d_cts06m06.vstdat    attribute (reverse)

      after field vstdat
         display by name d_cts06m06.vstdat

         if d_cts06m06.vstdat  is null   then
            error " Data de realizacao da vistoria deve ser informada!"
            next field vstdat
         else
            if d_cts06m06.vstdat < today  then
               error "Nao e' possivel alterar quantidade de vistorias ",
                     "para data anterior a hoje!"
               next field vstdat
            end if
         end if

      before field succod
         display by name d_cts06m06.succod    attribute (reverse)

         let d_cts06m06.succod = g_issk.succod

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m06.succod
          display by name ws.sucnom

      after field succod
         display by name d_cts06m06.succod

         if d_cts06m06.succod  is null   then
            error " Sucursal deve ser informada!"
            next field succod
         end if

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m06.succod
          display by name ws.sucnom

         if g_issk.dptsgl  <>  "desenv"   then
            if d_cts06m06.succod  <>  g_issk.succod   then
               error " Nao devem ser consultadas vistorias de outra sucursal!"
               next field succod
            end if
         end if

         select atrvstqtdc24, vstqtdaut,
                vstqtdc24   , vstqtdvol
           into d_cts06m06.atrvstqtdc24,
                d_cts06m06.vstqtdaut   ,
                d_cts06m06.vstqtdc24   ,
                d_cts06m06.vstqtdvol
           from datmvstagen
          where succod = d_cts06m06.succod   and
                vstdat = d_cts06m06.vstdat

         if sqlca.sqlcode = notfound  then
            let ws.operacao  =  "i"
         else
            let ws.operacao  =  "m"
            display by name d_cts06m06.atrvstqtdc24
            display by name d_cts06m06.vstqtdaut
            display by name d_cts06m06.vstqtdc24
            display by name d_cts06m06.vstqtdvol
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   input by name d_cts06m06.atrvstqtdc24,
                 d_cts06m06.vstqtdaut     without defaults

      before field atrvstqtdc24
         display by name d_cts06m06.atrvstqtdc24 attribute (reverse)

      after field atrvstqtdc24
         display by name d_cts06m06.atrvstqtdc24

         if d_cts06m06.atrvstqtdc24  is null then 
            error " Informe a quantidade de vistorias para data!"
            next field atrvstqtdc24
         end if

         if ws.operacao  =  "m"    then
            if d_cts06m06.atrvstqtdc24  <  d_cts06m06.vstqtdc24   then
               error " Quantidade autorizada menor que quantidade",
                     " marcada para Central 24 Horas!"
               next field atrvstqtdc24
            end if
         end if
         if ws.operacao  =  "i"   then
            insert into datmvstagen (vstdat      ,
                                     atrvstqtdc24,
                                     vstqtdaut   ,
                                     vstqtdc24   ,
                                     vstqtdvol   ,
                                     succod      )
                             values (d_cts06m06.vstdat      ,
                                     d_cts06m06.atrvstqtdc24,
                                     d_cts06m06.vstqtdaut,
                                     0,
                                     0,
                                     d_cts06m06.succod)

            if sqlca.sqlcode <> 0  then
               error "Erro (", sqlca.sqlcode, ") na inclusao da agenda de ",
                     "vistorias previas. AVISE A INFORMATICA!"
            end if
         end if

         if ws.operacao  =  "m"   then
            update datmvstagen set (atrvstqtdc24, vstqtdaut)
                                 = (d_cts06m06.atrvstqtdc24,
                                    d_cts06m06.vstqtdaut   )
                   where succod  =  d_cts06m06.succod   and
                         vstdat  =  d_cts06m06.vstdat

            if sqlca.sqlcode <> 0 then
               error "Erro (", sqlca.sqlcode, ") na alteracao da agenda de ",
                     "vistorias previas. AVISE A INFORMATICA!"
               exit input
            end if
         end if

     #before field vstqtdaut
     #   display by name d_cts06m06.vstqtdaut attribute (reverse)

     #after field vstqtdaut  #  VISTORIA ROTERIZADA EM 01/01/2001.
     #   display by name d_cts06m06.vstqtdaut
     #   if d_cts06m06.vstqtdaut  is null   or
     #      d_cts06m06.vstqtdaut  =  0      then
     #      error " Informe a quantidade de vistorias para data!"
     #      next field vstqtdaut
     #   end if
     #   if ws.operacao  =  "m"    then
     #      if d_cts06m06.vstqtdaut  <  d_cts06m06.vstqtdvol   then
     #         error " Quantidade autorizada menor que quantidade",
     #               " marcada para volantes!"
     #         next field vstqtdaut
     #      end if
     #   end if

     #   if ws.operacao  =  "i"   then
     #      insert into datmvstagen (vstdat      ,
     #                               atrvstqtdc24,
     #                               vstqtdaut   ,
     #                               vstqtdc24   ,
     #                               vstqtdvol   ,
     #                               succod      )
     #                       values (d_cts06m06.vstdat      ,
     #                               d_cts06m06.atrvstqtdc24,
     #                               d_cts06m06.vstqtdaut,
     #                               0,
     #                               0,
     #                               d_cts06m06.succod)

     #      if sqlca.sqlcode <> 0  then
     #         error "Erro (", sqlca.sqlcode, ") na inclusao da agenda de ",
     #               "vistorias previas. AVISE A INFORMATICA!"
     #      end if
     #   end if
     #
     #   if ws.operacao  =  "m"   then
     #      update datmvstagen set (atrvstqtdc24, vstqtdaut)
     #                           = (d_cts06m06.atrvstqtdc24,
     #                              d_cts06m06.vstqtdaut   )
     #             where succod  =  d_cts06m06.succod   and
     #                   vstdat  =  d_cts06m06.vstdat

     #      if sqlca.sqlcode <> 0 then
     #         error "Erro (", sqlca.sqlcode, ") na alteracao da agenda de ",
     #               "vistorias previas. AVISE A INFORMATICA!"
     #         exit input
     #      end if
     #   end if

      on key (interrupt)
         exit input

   end input

   initialize d_cts06m06.*  to null
   clear form

 end while

 let int_flag = false
 initialize d_cts06m06.*   to null
 close window  w_cts06m06

end function  #  cts06m06
