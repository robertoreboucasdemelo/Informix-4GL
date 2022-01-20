 #-----------------------------------------------------------------------------#
 # Sistema.......: AUTOMOVEL-CENTRAL 24 HORAS- SISTEMA DE PROCEDIMENTOS
 # Modulo........: CTC21M01
 # Descricao.....: TELA DE CADASTRO DOS CAMPOS QUE COMPOEM O PROCEDIMENTO
 # Atualizacao...: 20/mai/1998
 # Compilar como.: OBJECT
 # Analista......: ALMEIDA
 # Programador...: MARCO
 # PSI...........:
 #-----------------------------------------------------------------------------#

 database porto

 #------------------------------------------------------------------------
  function ctc21m04()
 #------------------------------------------------------------------------

 define d_ctc21m04      record
        prtcpointcod    like dattprt.prtcpointcod,
        prtcpointnom    like dattprt.prtcpointnom,
        prtcponom       like dattprt.prtcponom,
        prtcpodes       like dattprt.prtcpodes,
        atldat          like dattprt.atldat,
        altemp          like dattprt.altemp,
        atlmat          like dattprt.atlmat
 end record

 define a_ctc21m04      array[100] of record
        prtcponom       like dattprt.prtcponom,
        prtcpodes       like dattprt.prtcpodes,
        prtcpointcod    like dattprt.prtcpointcod,
        prtcpointnom    like dattprt.prtcpointnom
 end record

 define arr_aux         smallint
 define scr_aux         smallint


 initialize a_ctc21m04  to null
 initialize d_ctc21m04  to null

 let arr_aux  =  1
 let scr_aux  =  1

 open window w_ctc21m04 at 8,12 with form "ctc21m04"
      attribute(border,form line 1)

 message " (F17)Abandona, (F8)Seleciona"

 declare c_dattprt cursor with hold for
    select prtcpointcod,
           prtcponom,
           prtcpodes,
           prtcpointnom
      from dattprt

 foreach c_dattprt into a_ctc21m04[arr_aux].prtcpointcod,
                        a_ctc21m04[arr_aux].prtcponom,
                        a_ctc21m04[arr_aux].prtcpodes,
                        a_ctc21m04[arr_aux].prtcpointnom

    let arr_aux = arr_aux + 1

    if arr_aux  >  100   then
       error " Limite excedido. Existem mais de 100 campos cadastrados!"
       exit foreach
    end if

 end foreach

 call set_count(arr_aux - 1)

 display  array a_ctc21m04 to s_ctc21m04.*

    on key (F8)
       let arr_aux = arr_curr()
       exit display

    on key (interrupt)
       initialize a_ctc21m04 to null
       exit display

 end display

 close window w_ctc21m04

 return a_ctc21m04[arr_aux].prtcpointcod,
        a_ctc21m04[arr_aux].prtcponom,
        a_ctc21m04[arr_aux].prtcpointnom

 end function   ###--- ctc21m04
