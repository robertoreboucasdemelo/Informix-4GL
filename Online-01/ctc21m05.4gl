 #-----------------------------------------------------------------------------#
 # Sistema.......: AUTOMOVEL-CENTRAL 24 HORAS- SISTEMA DE PROCEDIMENTOS
 # Modulo........: CTC21M01
 # Descricao.....: Pop up dos procedimentos
 # Atualizacao...: 20/mai/1998
 # Compilar como.: OBJECT
 # Analista......: ALMEIDA
 #-----------------------------------------------------------------------------#

 database porto

 #----------------------------------------------------------------------
 function ctc21m05(param)
 #----------------------------------------------------------------------

 define param         record
    prtprcnum         like datmprctxt.prtprcnum,
    prtcponom         like dattprt.prtcponom,
    relacional        char(02),
    prtprccntdes      like datmprtprc.prtprccntdes
 end record

 define a_ctc21m05    array[100] of record
    prctxt            like datmprctxt.prctxt
 end record

 define arr_aux       smallint
 define scr_aux       smallint


 initialize arr_aux     to null
 initialize a_ctc21m05  to null

 let arr_aux  =  1
 let scr_aux  =  1

 open window w_ctc21m05 at 8,9 with form "ctc21m05"
             attribute(border,form line 1)

 display param.prtcponom    to prtcponom     attribute (reverse)
 display param.relacional   to relacional    attribute (reverse)
 display param.prtprccntdes to prtprccntdes  attribute (reverse)

 message " (F17)Abandona"

 declare c_datmprctxt  cursor with hold for
    select prctxt
      from datmprctxt
     where prtprcnum = param.prtprcnum

 foreach c_datmprctxt into a_ctc21m05[arr_aux].prctxt

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
      error " Limite excedido. Existem mais de 100 linhas de texto cadastradas!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 display array a_ctc21m05 to s_ctc21m05.*

    on key (interrupt)
       initialize a_ctc21m05 to null
       exit display

 end display

 close window w_ctc21m05

 end function   ###---  ctc21m05
