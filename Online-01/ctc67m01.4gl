############################################################################
# Nome do Modulo: ctc67m01                                               #
#                                                                          #
# Exibe janela para digitacao do motivo de alteracao da situacao de servico#
############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function ctc67m01()
#--------------------------------------------------------------

 define d_ctc67m01 record
    srvaltobstxt         char(51)
 end record


 initialize  d_ctc67m01.*  to  null

 open window ctc67m01 at 12,05 with form "ctc67m01"
                      attribute (form line 1, border)

 input by name d_ctc67m01.* without defaults

    before field srvaltobstxt
       display by name d_ctc67m01.srvaltobstxt    attribute (reverse)

    after field srvaltobstxt
       display by name d_ctc67m01.srvaltobstxt
       if d_ctc67m01.srvaltobstxt is null  or
          d_ctc67m01.srvaltobstxt  =  " "   then
          error " ctc67m01 em branco nao e' permitido!"
          next field srvaltobstxt
       end if

    on key (interrupt,f9)
          let d_ctc67m01.srvaltobstxt = null
          exit input

 end input

 let int_flag = false
 close window ctc67m01
 return d_ctc67m01.srvaltobstxt

end function  ###  ctc67m01
