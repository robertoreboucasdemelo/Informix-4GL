###########################################################################
# Nome do Modulo: CTC00M07                                       Marcelo  #
#                                                                Gilberto #
# Mostra informacoes sobre o credenciamento e atualizacao        Jan/1997 #
###########################################################################

database porto

#------------------------------------------------------------
 function ctc00m07(param)
#------------------------------------------------------------

  define param      record
     atldat         like dpaksocor.atldat   ,
     funmat         like dpaksocor.funmat   ,
     funnom         like isskfunc.funnom    ,
     cmtdat         like dpaksocor.cmtdat   ,
     cmtmatnum      like dpaksocor.cmtmatnum,
     cmtnom         like isskfunc.funnom
  end record

  define ws         record
     resp           char(01)
  end record


  let int_flag = false
  initialize ws.*   to null

  open window w_ctc00m07 at 11,29  with form  "ctc00m07"
              attribute(form line first, border)

  display by name  param.cmtdat  attribute(reverse)
  display by name  param.cmtmatnum
  display by name  param.cmtnom
  display by name  param.atldat  attribute(reverse)
  display by name  param.funmat
  display by name  param.funnom

  prompt " (F17)Abandona" for char  ws.resp

  close window w_ctc00m07
  let int_flag = false

end function   ### ctc00m07
