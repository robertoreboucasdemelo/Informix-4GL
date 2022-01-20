###############################################################################
# Nome do Modulo: CTN26C01                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de motivos para assistencia                                 Mar/1999 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctn26c01(param)
#-----------------------------------------------------------

 define param      record
    asitipcod      like datkasitip.asitipcod
 end record

 define a_ctn26c01 array[20] of record
    asimtvdes      like datkasimtv.asimtvdes,
    asimtvcod      like datkasimtv.asimtvcod
 end record

 define arr_aux smallint

 define ws         record
    sql            char (200),
    asitipcod      like datkasitip.asitipcod,
    asimtvcod      like datkasimtv.asimtvcod
 end record

 let ws.sql = "select asitipcod         ",
              "  from datrmtvasitip     ",
              " where asitipcod = ?  and",
              "       asimtvcod = ?  and",
              "       asimtvsit = 'A'   "
 prepare sel_datrmtvasitip from ws.sql
 declare c_datrmtvasitip cursor for sel_datrmtvasitip

 let int_flag = false

 let arr_aux  = 1
 initialize a_ctn26c01   to null

 declare c_ctn26c01 cursor for
    select asimtvdes, asimtvcod
      from datkasimtv
     where asimtvsit = "A"
     order by asimtvdes

 foreach c_ctn26c01 into a_ctn26c01[arr_aux].asimtvdes,
                         a_ctn26c01[arr_aux].asimtvcod

    if param.asitipcod is not null  then
       open  c_datrmtvasitip using param.asitipcod,
                                   a_ctn26c01[arr_aux].asimtvcod
       fetch c_datrmtvasitip
       if sqlca.sqlcode = notfound  then
          continue foreach
       end if
       close c_datrmtvasitip
    end if

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. Foram encontrados mais de 20 motivos para assistencia!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.asimtvcod = a_ctn26c01[arr_aux - 1].asimtvcod
    else
       open window ctn26c01 at 12,52 with form "ctn26c01"
                            attribute(form line 1, border)

       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_ctn26c01 to s_ctn26c01.*

          on key (interrupt,control-c)
             initialize a_ctn26c01     to null
             initialize ws.asimtvcod to null
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.asimtvcod = a_ctn26c01[arr_aux].asimtvcod
             exit display

       end display

       let int_flag = false
       close window ctn26c01
    end if
 else
    initialize ws.asimtvcod to null
    error " ATENCAO: Nao foi encontrado nenhum motivo!"
    sleep 2
 end if

 let int_flag = false

 return ws.asimtvcod

end function  ###  ctn26c01
