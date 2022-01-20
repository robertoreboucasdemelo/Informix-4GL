###############################################################################
# Nome do Modulo: cta00m13                                           Marcelo  #
#                                                                             #
# Consulta/Escolhe Itens da Apolice (AUTO)                           NOV/1994 #
###############################################################################

 database porto

#-----------------------#
 function cta00m13(param)
#-----------------------#

 define param         record
    succod            like abbmveic.succod   ,
    aplnumdig         like abbmveic.aplnumdig
 end record

 define a_cta00m13    array[501] of record
    itmnumdig         like abbmitem.itmnumdig,
    vcldes            char (25),
    vcllicnum         like abbmveic.vcllicnum,
    vclchsfnl         like abbmveic.vclchsfnl
 end record

 define ws            record
    sql               char (200)              ,
    itmnumchr         char (07)               ,
    itmnumdig         like abbmdoc.itmnumdig  ,
    dctnumseq         like abbmdoc.dctnumseq  ,
    vclcoddig         like abbmveic.vclcoddig ,
    vclmrccod         like agbkveic.vclmrccod ,
    vcltipcod         like agbkveic.vcltipcod ,
    vclmdlnom         like agbkveic.vclmdlnom ,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom
 end record

 define g_funapol     record
    result            char (01),
    dctnumseq         like abbmveic.dctnumseq,
    vclsitatu         like abbmitem.vclsitatu,
    autsitatu         like abbmitem.autsitatu,
    dmtsitatu         like abbmitem.dmtsitatu,
    dpssitatu         like abbmitem.dpssitatu,
    appsitatu         like abbmitem.appsitatu,
    vidsitatu         like abbmitem.vidsitatu
 end record

 define arr_aux       smallint,
        w_pf1         integer

  let arr_aux = null

  initialize a_cta00m13, ws, g_funapol to null

 let int_flag  =  false

 let ws.sql = "select vclcoddig, ",
                    " vclchsfnl, ",
                    " vcllicnum ",
               " from abbmveic ",
              " where succod = ?  and ",
                    " aplnumdig = ?  and ",
                    " itmnumdig = ?  and ",
                    " dctnumseq = ? "

 prepare p_cta00m13_001 from ws.sql
 declare c_cta00m13_001 cursor for p_cta00m13_001

 let ws.sql = "select vclmrccod, ",
                    " vcltipcod, ",
                    " vclmdlnom ",
               " from agbkveic ",
              " where vclcoddig = ?"

 prepare p_cta00m13_002 from ws.sql
 declare c_cta00m13_002 cursor for p_cta00m13_002

 let ws.sql = "select vclmrcnom    ",
              "  from agbkmarca    ",
              " where vclmrccod = ?"

 prepare p_cta00m13_003 from ws.sql
 declare c_cta00m13_003 cursor for p_cta00m13_003

 let ws.sql = "select vcltipnom",
              "  from agbktip  ",
              " where vclmrccod = ?  and",
              "       vcltipcod = ?     "

 prepare p_cta00m13_004   from ws.sql
 declare c_cta00m13_004   cursor for p_cta00m13_004

 message " Aguarde, pesquisando..." attribute (reverse)

 declare c_cta00m13_005 cursor for
    select itmnumdig, max (dctnumseq)
      from abbmdoc
     where succod     = param.succod      and
           aplnumdig  = param.aplnumdig   and
           itmnumdig >= 0                 and
           itmnumdig <= 9999999
     group by itmnumdig

 let arr_aux = 1

 foreach c_cta00m13_005 into ws.itmnumdig, ws.dctnumseq

    call f_funapol_ultima_situacao (param.succod, param.aplnumdig, ws.itmnumdig)
                         returning g_funapol.*

   if g_funapol.result = "O"  then
      open  c_cta00m13_001 using param.succod,
                             param.aplnumdig,
                             ws.itmnumdig,
                             #g_funapol.vclsitatu
                             g_funapol.dctnumseq
      fetch c_cta00m13_001 into  ws.vclcoddig,
                             a_cta00m13[arr_aux].vclchsfnl,
                             a_cta00m13[arr_aux].vcllicnum

      if sqlca.sqlcode = 0  then
         open  c_cta00m13_002 using ws.vclcoddig
         fetch c_cta00m13_002 into  ws.vclmrccod,
                                ws.vcltipcod,
                                ws.vclmdlnom
         close c_cta00m13_002

         open  c_cta00m13_003 using ws.vclmrccod
         fetch c_cta00m13_003 into  ws.vclmrcnom
         close c_cta00m13_003

         open  c_cta00m13_004   using ws.vclmrccod,
                                 ws.vcltipcod
         fetch c_cta00m13_004   into  ws.vcltipnom
         close c_cta00m13_004

         let a_cta00m13[arr_aux].vcldes  = ws.vclmrcnom clipped," ",
                                           ws.vcltipnom clipped," ",
                                           ws.vclmdlnom

         let a_cta00m13[arr_aux].itmnumdig = ws.itmnumdig

         let arr_aux = arr_aux + 1

         if arr_aux > 500  then
            error " Limite excedido. Apolice com mais de 500 itens!"
            exit foreach
         end if

      end if
   end if

 end foreach

 message " "

 if arr_aux > 1  then
   #if arr_aux = 2  then
   #   let arr_aux = 1
   #else
       call set_count(arr_aux - 1)

       open window cta00m13 at 08,14 with form "cta00m13"
                   attribute(border, form line first)

       message " (F17)Abandona, (F8)Seleciona"

       display array a_cta00m13 to s_cta00m13.*
         on key (F8)
            let arr_aux = arr_curr()
            exit display

         on key (interrupt)
            let int_flag = false
            initialize a_cta00m13  to null
            exit display
       end display

       close window cta00m13
   #end if
 end if

 let int_flag = false

 let ws.itmnumchr = a_cta00m13[arr_aux].itmnumdig using "#####&&"
 let ws.itmnumdig = ws.itmnumchr[1,6]

 return ws.itmnumdig

end function  ###  cta00m13
