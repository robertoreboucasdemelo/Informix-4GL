###########################################################################
# Nome do Modulo: ctc44m01                                        Marcelo #
#                                                                Gilberto #
# Pop-up de dados da filiacao                                    Jul/1999 #
###########################################################################

 database porto

#------------------------------------------------------------
 function ctc44m01(d_ctc44m01)
#------------------------------------------------------------

 define d_ctc44m01    record
    maenom            like datksrr.maenom,
    painom            like datksrr.painom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod
 end record

 define ws            record
    retflg            char (01)
 end record


 initialize ws.*  to null
 let int_flag   =  false
 let ws.retflg  =  "N"

 open window ctc44m01 at 10,7 with form "ctc44m01"
      attribute (form line first, border)

 input by name d_ctc44m01.maenom,
               d_ctc44m01.painom,
               d_ctc44m01.nacdes,
               d_ctc44m01.ufdcod   without defaults

    before field maenom
           display by name d_ctc44m01.maenom attribute (reverse)

    after  field maenom
           display by name d_ctc44m01.maenom

    before field painom
           display by name d_ctc44m01.painom attribute (reverse)

    after  field painom
           display by name d_ctc44m01.painom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  maenom
           end if

    before field nacdes
           if d_ctc44m01.nacdes is null  then
              let d_ctc44m01.nacdes = "BRASILEIRA"
           end if

           display by name d_ctc44m01.nacdes attribute (reverse)

    after  field nacdes
           display by name d_ctc44m01.nacdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  painom
           end if

           if d_ctc44m01.nacdes  is null   then
              error " Nacionalidade deve ser informada!"
              next field nacdes
           end if

    before field ufdcod
           display by name d_ctc44m01.ufdcod attribute (reverse)

    after  field ufdcod
           display by name d_ctc44m01.ufdcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  nacdes
           end if

           if d_ctc44m01.nacdes = "BRASILEIRA"  and
              d_ctc44m01.ufdcod is null         then
              error " Estado deve ser informado!"
              next field ufdcod
           end if

           if d_ctc44m01.ufdcod is not null  then
              select ufdcod
                from glakest
               where ufdcod  =  d_ctc44m01.ufdcod

              if sqlca.sqlcode  =  notfound   then
                 error " Estado nao cadastrado!"
                 next field ufdcod
              end if
           end if

    on key (interrupt)
       exit input

 end input

 if not int_flag   then
    let ws.retflg  =  "S"
 end if

 close window ctc44m01

 return d_ctc44m01.*, ws.retflg

end function  ###  ctc44m01
