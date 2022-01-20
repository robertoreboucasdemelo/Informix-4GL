#############################################################################
# Nome do Modulo: CTS02M04                                            Ruiz  #
# Previsao de ida ate loja - laudo de vidros                       JUn/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#############################################################################

 database porto


#-----------------------------------------------------------
 function cts02m04(param, k_cts02m04)
#-----------------------------------------------------------

 define param      record
    atdfnlflg      like datmservico.atdfnlflg,
    imdsrvflg      char (01)
 end record

 define k_cts02m04 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg
 end record

 define d_cts02m04 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg
 end record

 define prompt_key char (01)

 define l_data       date,
        l_hora2      datetime hour to minute

	let	prompt_key  =  null

	initialize  d_cts02m04.*  to  null

 let d_cts02m04.* = k_cts02m04.*

 open window cts02m04 at 10,46 with form "cts02m04"
                      attribute(border,form line 1)

 let int_flag = false

 display by name d_cts02m04.*

 input by name d_cts02m04.atdhorpvt,
               d_cts02m04.atddatprg,
               d_cts02m04.atdhorprg
       without defaults

   before field atdhorpvt
          display by name k_cts02m04.*
          let d_cts02m04.* = k_cts02m04.*

          if param.atdfnlflg = "S"  then
             prompt " (F17)Abandona " for char  prompt_key
             exit input
          end if

          if param.imdsrvflg = "N"  then
             initialize d_cts02m04.atdhorpvt to null
             next field atddatprg
          else
             initialize d_cts02m04.atdhorprg to null
             initialize d_cts02m04.atddatprg to null
          end if

          display by name d_cts02m04.atdhorpvt attribute (reverse)

   after  field atdhorpvt
          display by name d_cts02m04.atdhorpvt
          if d_cts02m04.atdhorpvt is null then
             error "Previsao em horas deve ser informada para servico imediato!"
             next field atdhorpvt
          end if
          exit input

   before field atddatprg
          display by name d_cts02m04.atddatprg attribute (reverse)

   after  field atddatprg
          display by name d_cts02m04.atddatprg

          if d_cts02m04.atddatprg is null or
             d_cts02m04.atddatprg =  0    then
             error "Data programada deve ser informada para servico programado!"
             next field atddatprg
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if d_cts02m04.atddatprg < l_data   then
             error " Data programada menor que data atual!"
             next field atddatprg
          end if

          if d_cts02m04.atddatprg > l_data + 7 units day   then
             error " Data programada para mais de 7 dias!"
             next field atddatprg
          end if

   before field atdhorprg
          display by name d_cts02m04.atdhorprg attribute (reverse)

   after  field atdhorprg
          display by name d_cts02m04.atdhorprg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atddatprg
          end if

          if d_cts02m04.atdhorprg is null or
             d_cts02m04.atdhorprg =  0    then
             error "Hora programada deve ser informada para servico programado!"
             next field atdhorprg
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if d_cts02m04.atddatprg = l_data   and
             d_cts02m04.atdhorprg < l_hora2  then
             error " Hora programada menor que hora atual!"
             next field atdhorprg
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag then
    let int_flag = false
 end if

 close window cts02m04

 return d_cts02m04.*

end function  ###  cts02m04
