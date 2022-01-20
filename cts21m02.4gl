###############################################################################
# Nome do Modulo: CTS21M02                                            Marcelo #
#                                                                    Gilberto #
# Informacoes sobre o sinistro (Vistoria de Sinistro R.E.)           Nov/1995 #
###############################################################################

database porto

#---------------------------------------------------------------
 function cts21m02(param)
#---------------------------------------------------------------

 define param   record
    sinhst      like datmpedvist.sinhst,
    sinobs      like datmpedvist.sinobs
 end record

 define d_cts21m02  record
    hist1       char(50)               ,
    hist2       char(50)               ,
    hist3       char(50)               ,
    obs1        char(50)               ,
    obs2        char(50)               ,
    obs3        char(50)
 end record



	initialize  d_cts21m02.*  to  null

 open window w_cts21m02 at 10,27 with form "cts21m02"
      attribute(form line first, border)

 if param.sinhst   is not null   then
    let d_cts21m02.hist1 = param.sinhst[001,050]
    let d_cts21m02.hist2 = param.sinhst[051,100]
    let d_cts21m02.hist3 = param.sinhst[101,150]
 end if

 if param.sinobs   is not null   then
    let d_cts21m02.obs1  = param.sinobs[001,050]
    let d_cts21m02.obs2  = param.sinobs[051,100]
    let d_cts21m02.obs3  = param.sinobs[101,150]
 end if

 display by name d_cts21m02.*

 input by name d_cts21m02.hist1, d_cts21m02.hist2, d_cts21m02.hist3,
               d_cts21m02.obs1 , d_cts21m02.obs2 , d_cts21m02.obs3
               without defaults

    before field hist1
       display by name d_cts21m02.hist1      attribute (reverse)

     after  field hist1
        display by name d_cts21m02.hist1

     before field hist2
        display by name d_cts21m02.hist2      attribute (reverse)

     after  field hist2
        display by name d_cts21m02.hist2

     before field hist3
        display by name d_cts21m02.hist3      attribute (reverse)

     after  field hist3
        display by name d_cts21m02.hist3

     before field obs1
        display by name d_cts21m02.obs1      attribute (reverse)

     after  field obs1
        display by name d_cts21m02.obs1

     before field obs2
        display by name d_cts21m02.obs2      attribute (reverse)

     after  field obs2
        display by name d_cts21m02.obs2

     before field obs3
        display by name d_cts21m02.obs3      attribute (reverse)

     after  field obs3
        display by name d_cts21m02.obs3

     on key(interrupt)
        exit input

  end input

  let param.sinhst =  d_cts21m02.hist1, d_cts21m02.hist2, d_cts21m02.hist3

  let param.sinobs =  d_cts21m02.obs1, d_cts21m02.obs2, d_cts21m02.obs3

  let int_flag = false
  close window w_cts21m02

  return param.sinhst, param.sinobs

end function  #  cts21m02
