############################################################################
# Nome do Modulo: CTS10M02                                        Marcelo  #
#                                                                 Gilberto #
# Exibe janela para digitacao do historico                        Mar/1996 #
############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function cts10m02(param)
#--------------------------------------------------------------

 define param     record
    hist1         like datmservhist.c24srvdsc ,
    hist2         like datmservhist.c24srvdsc ,
    hist3         like datmservhist.c24srvdsc ,
    hist4         like datmservhist.c24srvdsc ,
    hist5         like datmservhist.c24srvdsc
 end record
 define d_cts10m02 record
    descr         char(51)
 end record



	initialize  d_cts10m02.*  to  null

 let d_cts10m02.descr = "HISTORICO DO SERVICO"
 if param.hist1 = "OF CORT MOTIVO:"  then
    let d_cts10m02.descr = "JUSTIFIQUE A ESCOLHA PELA OFICINA EM OBSERVACAO"
 end if

 open window cts10m02 at 12,05 with form "cts10m02"
                      attribute (form line 1, border)
 display by name d_cts10m02.descr

 input by name param.* without defaults

    before field hist1
       if param.hist1 = "OF CORT MOTIVO:"  then
          display by name param.hist1
          next field hist2
       end if
       display by name param.hist1    attribute (reverse)

    after field hist1
       display by name param.hist1
       if param.hist1 is null  or
          param.hist1  =  " "   then
          error " Historico em branco nao e' permitido!"
          next field hist1
       end if

    before field hist2
       display by name param.hist2    attribute (reverse)

    after field hist2
       display by name param.hist2
       if param.hist2  is null  or
          param.hist2  =  " "   then
          error " Historico em branco nao e' permitido!"
          next field hist2
       end if

    before field hist3
       display by name param.hist3    attribute (reverse)

   after field hist3
       display by name param.hist3
       if param.hist3  is null  or
          param.hist3  =  " "   then
          error " Historico em branco nao e' permitido!"
          next field hist3
       end if

    before field hist4
       display by name param.hist4    attribute (reverse)

    after field hist4
       display by name param.hist4
       if param.hist4  is null  or
          param.hist4  =  " "   then
          error " Historico em branco nao e' permitido!"
          next field hist4
       end if

    before field hist5
       display by name param.hist5    attribute (reverse)

    after  field hist5
       display by name param.hist5
       if param.hist5  is null  or
          param.hist5  =  " "   then
          error " Historico em branco nao e' permitido!"
          next field hist5
       end if

    on key (interrupt)
       if param.hist1 = "OF CORT MOTIVO:" then
          if param.hist2 is null then
             error "Motivo em branco nao e' permitido!"
             next field hist2
          end if
       end if
       exit input
 end input

 let int_flag = false
 close window cts10m02
 return param.*

end function  ###  cts10m02
