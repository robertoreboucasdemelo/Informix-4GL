#############################################################################
# Nome do Modulo: cts26m03                                            Pedro #
#                                                                   Marcelo #
# Laudo - Remocoes (Previsao de Termino do Servico)                Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Alteracao do conteudo do campo      #
#                                       ATDFNLFLG (flag finalizacao).       #
#############################################################################

 database porto

#-----------------------------------------------------------
 function cts26m03(param, k_cts26m03)
#-----------------------------------------------------------

 define param      record
    atdfnlflg      like datmservico.atdfnlflg,
    imdsrvflg      char (01)
 end record

 define k_cts26m03 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg,
    atdpvtretflg   like datmservico.atdpvtretflg
 end record

 define d_cts26m03 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg,
    atdpvtretflg   like datmservico.atdpvtretflg
 end record

 define prompt_key char (01)


	let	prompt_key  =  null

	initialize  d_cts26m03.*  to  null

 if k_cts26m03.atdpvtretflg  is null   then
    let k_cts26m03.atdpvtretflg = "N"
 end if
 let d_cts26m03.* = k_cts26m03.*

 open window cts26m03 at 11,54 with form "cts26m03"
                      attribute(border,form line 1)

 let int_flag = false

 display by name d_cts26m03.*

 input by name d_cts26m03.atdhorpvt,
               d_cts26m03.atdpvtretflg,
               d_cts26m03.atddatprg,
               d_cts26m03.atdhorprg
       without defaults

   before field atdhorpvt
          display by name k_cts26m03.*
          let d_cts26m03.* = k_cts26m03.*

          if param.atdfnlflg = "S"  then
             prompt " (F17)Abandona " for char  prompt_key
             exit input
          end if

          if param.imdsrvflg = "N"  then
             initialize d_cts26m03.atdhorpvt to null
             next field atddatprg
          else
             initialize d_cts26m03.atdhorprg to null
             initialize d_cts26m03.atddatprg to null
          end if

          display by name d_cts26m03.atdhorpvt attribute (reverse)

   after  field atdhorpvt
          display by name d_cts26m03.atdhorpvt

          if d_cts26m03.atdhorpvt is null then
             error " Previsao em horas deve ser informada para servico imediato!"
             next field atdhorpvt
          end if

   before field atdpvtretflg
          display by name d_cts26m03.atdpvtretflg attribute (reverse)

   after  field atdpvtretflg
          display by name d_cts26m03.atdpvtretflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts26m03.atdpvtretflg is null   or
                (d_cts26m03.atdpvtretflg <> "S"   and
                 d_cts26m03.atdpvtretflg <> "N")  then
                error " Retorno ao Segurado deve ser (S)im ou (N)ao!"
                next field atdpvtretflg
             end if

             if d_cts26m03.atdhorpvt is not null then
                exit input
             end if
          end if

   before field atddatprg
          display by name d_cts26m03.atddatprg attribute (reverse)

   after  field atddatprg
          display by name d_cts26m03.atddatprg

          if d_cts26m03.atddatprg is null or
             d_cts26m03.atddatprg =  0    then
             error " Data programada deve ser informada para servico programado!"
             next field atddatprg
          end if

          if d_cts26m03.atddatprg < today   then
             error " Data programada menor que data atual!"
             next field atddatprg
          end if

          if d_cts26m03.atddatprg > today + 7 units day   then
             error " Data programada para mais de 7 dias!"
             next field atddatprg
          end if

   before field atdhorprg
          display by name d_cts26m03.atdhorprg attribute (reverse)

   after  field atdhorprg
          display by name d_cts26m03.atdhorprg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atddatprg
          end if

          if d_cts26m03.atdhorprg is null or
             d_cts26m03.atdhorprg =  0    then
             error " Hora programada deve ser informada para servico programado!"
             next field atdhorprg
          end if

          if d_cts26m03.atddatprg = today                   and
             d_cts26m03.atdhorprg < current hour to minute  then
             error " Hora programada menor que hora atual!"
             next field atdhorprg
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag then
    let int_flag = false
 end if

 close window cts26m03

 return d_cts26m03.*

end function  ###  cts26m03
