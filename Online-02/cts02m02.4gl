###############################################################################
# Nome do Modulo: CTS02M02                                              Pedro #
#                                                                     Marcelo #
# Laudo - Remocoes (Dados Ref. ao B.O.)                              Dez/1994 #
###############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
function cts02m02(k_cts02m02)
#-----------------------------------------------------------

 define  k_cts02m02    record
         bocnum        like datmservicocmp.bocnum   ,
         bocemi        like datmservicocmp.bocemi   ,
         vcllibflg     like datmservicocmp.vcllibflg
 end record

 define  d_cts02m02    record
         bocnum        like datmservicocmp.bocnum   ,
         bocemi        like datmservicocmp.bocemi   ,
         vcllibflg     like datmservicocmp.vcllibflg
 end record



	initialize  d_cts02m02.*  to  null

 let d_cts02m02.* = k_cts02m02.*

 open window cts02m02 at 11,54 with form "cts02m02"
                      attribute(border,form line 1)

 let int_flag = false

 display by name d_cts02m02.*

 input by name d_cts02m02.bocnum   ,
               d_cts02m02.bocemi   ,
               d_cts02m02.vcllibflg

   before field bocnum
          display by name k_cts02m02.*
          let d_cts02m02.* = k_cts02m02.*
          display by name d_cts02m02.bocnum    attribute (reverse)

   after  field bocnum
          display by name d_cts02m02.bocnum

   before field bocemi
          display by name d_cts02m02.bocemi    attribute (reverse)

   after  field bocemi
          display by name d_cts02m02.bocemi

   before field vcllibflg
          display by name d_cts02m02.vcllibflg attribute (reverse)

   after  field vcllibflg
          display by name d_cts02m02.vcllibflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m02.vcllibflg is not null then
                if d_cts02m02.vcllibflg <> "S"      and
                   d_cts02m02.vcllibflg <> "N"      then
                   error "Veiculo liberado e' item obrigatorio!"
                   next field vcllibflg
                end if
             end if
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag then
    let int_flag = false
 end if

 close window cts02m02

 return d_cts02m02.*

end function # cts02m02
