###########################################################################
# Nome do Modulo: ctc44m02                                        Marcelo #
#                                                                Gilberto #
# Pop-up de dados dos dependentes                                Jul/1999 #
###########################################################################

 database porto

#------------------------------------------------------------
 function ctc44m02(d_ctc44m02)
#------------------------------------------------------------

 define d_ctc44m02    record
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd
 end record

 define ws            record
    retflg            char (01)
 end record


 initialize ws.*   to null
 let int_flag   =  false
 let ws.retflg  =  "N"

 open window ctc44m02 at 11,8 with form "ctc44m02"
      attribute (form line first, border)

 input by name d_ctc44m02.cojnom,
               d_ctc44m02.srrdpdqtd   without defaults

    before field cojnom
           display by name d_ctc44m02.cojnom attribute (reverse)

    after  field cojnom
           display by name d_ctc44m02.cojnom

    before field srrdpdqtd
           display by name d_ctc44m02.srrdpdqtd attribute (reverse)

    after  field srrdpdqtd
           display by name d_ctc44m02.srrdpdqtd

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cojnom
           end if

           if d_ctc44m02.srrdpdqtd  is null   then
              error " Quantidade de dependentes deve ser informada!"
              next field  srrdpdqtd
           end if

           if d_ctc44m02.srrdpdqtd  >  8   then
              error " Quantidade de dependentes nao deve ser maior que 8!"
              next field  srrdpdqtd
           end if

    on key (interrupt)
       exit input

 end input

 if not int_flag   then
    let ws.retflg  =  "S"
 end if

 close window ctc44m02

 return d_ctc44m02.*, ws.retflg

 end function   ###-- ctc44m02
