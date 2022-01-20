###############################################################################
# Nome do Modulo: cts28m03                                            Ruiz    #
# Descricao bens atingidos (sinistro transportes)                    Ago/2002 #
###############################################################################

database porto

#---------------------------------------------------------------
 function cts28m03(param)
#---------------------------------------------------------------

 define param   record
    descr       char (264)
 end record

 define d_cts28m03  record
    obs1       char(50)               ,
    obs2       char(50)               ,
    obs3       char(50)               ,
    obs4       char(50)               ,
    obs5       char(50)               ,
    obs6       char(14)
 end record



	initialize  d_cts28m03.*  to  null

 open window w_cts28m03 at 10,27 with form "cts28m03"
      attribute(form line first, border)

 if param.descr    is not null   then
    let d_cts28m03.obs1 = param.descr[001,050]
    let d_cts28m03.obs2 = param.descr[051,100]
    let d_cts28m03.obs3 = param.descr[101,150]
    let d_cts28m03.obs4 = param.descr[151,200]
    let d_cts28m03.obs5 = param.descr[201,250]
    let d_cts28m03.obs6 = param.descr[251,264]
 end if

 display by name d_cts28m03.*

 input by name d_cts28m03.obs1, d_cts28m03.obs2, d_cts28m03.obs3,
               d_cts28m03.obs4, d_cts28m03.obs5, d_cts28m03.obs6
               without defaults

    before field obs1
        display by name d_cts28m03.obs1      attribute (reverse)

     after  field obs2
        display by name d_cts28m03.obs2

     before field obs3
        display by name d_cts28m03.obs3      attribute (reverse)

     after  field obs4
        display by name d_cts28m03.obs4

     before field obs5
        display by name d_cts28m03.obs5      attribute (reverse)

     before field obs6
        display by name d_cts28m03.obs6      attribute (reverse)

     on key(interrupt)
        exit input

  end input

  let param.descr =  d_cts28m03.obs1, d_cts28m03.obs2, d_cts28m03.obs3,
                     d_cts28m03.obs4, d_cts28m03.obs5, d_cts28m03.obs6

  let int_flag = false
  close window w_cts28m03

  return param.descr

end function  #  cts28m03
