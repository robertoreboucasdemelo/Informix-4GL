#############################################################################
# Nome do Modulo: CTS15M10                                         Marcelo  #
#                                                                  Gilberto #
# Locacao de veiculo para corretores                               Dez/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

#--------------------------------------------------------------
 function cts15m10(param)
#--------------------------------------------------------------

 define param        record
    corsus           like gcaksusep.corsus,
    cornom           like gcakcorr.cornom
 end record

 define d_cts15m10   record
    corsus           like gcaksusep.corsus,
    cornom           like gcakcorr.cornom ,
    confirma         char (01)
 end record



	initialize  d_cts15m10.*  to  null

 initialize d_cts15m10.*  to null

 let d_cts15m10.corsus = param.corsus
 let d_cts15m10.cornom = param.cornom

 let int_flag  =  false

 open window cts15m10 at 13,14 with form "cts15m10"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona "

 while true
    input by name d_cts15m10.corsus,
                  d_cts15m10.confirma  without defaults

       before field corsus
          display by name d_cts15m10.corsus attribute (reverse)

       after field corsus
          display by name d_cts15m10.corsus

          if d_cts15m10.corsus is null  then
             error " SUSEP do corretor deve ser informada! "
             next field corsus
          else
             select cornom
               into d_cts15m10.cornom
               from gcaksusep, gcakcorr
              where gcaksusep.corsus   = d_cts15m10.corsus    and
                    gcakcorr.corsuspcp = gcaksusep.corsuspcp

             if sqlca.sqlcode = notfound  then
                error " SUSEP do corretor nao cadastrada!"
                next field corsus
             else
                display by name d_cts15m10.cornom
                next field confirma
             end if
          end if

       before field confirma
          display by name d_cts15m10.confirma attribute (reverse)

       after field confirma
          display by name d_cts15m10.confirma

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts15m10.confirma is null  then
                error " Confirmacao e' necessaria! "
                next field confirma
             end if

             if d_cts15m10.confirma = "N"  then
                error " Dados nao confirmados! "
                next field corsus
             end if

             if d_cts15m10.confirma = "S"  then
                exit input
             else
                error " Confirma dados ? (S)im ou (N)ao "
                next field confirma
             end if
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    if d_cts15m10.confirma = "S"  then
       exit while
    end if

 end while

 close window cts15m10

 if int_flag = true  then
    let int_flag = false
    initialize d_cts15m10.* to null
    return param.corsus, param.cornom
 end if

 return d_cts15m10.corsus, d_cts15m10.cornom

end function  ###  cts15m10
