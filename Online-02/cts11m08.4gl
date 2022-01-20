#############################################################################
# Nome do Modulo: cts11m08                                         Marcelo  #
#                                                                  Gilberto #
# Preferencias - Passagem Aerea                                    Jul/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/05/2002  PSI 154199   Ruiz         consultar data/hora da viagem.      #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#############################################################################


database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function cts11m08(d_cts11m08)
#--------------------------------------------------------------------

 define d_cts11m08    record
    trppfrdat         like datmassistpassag.trppfrdat,
    trppfrhor         like datmassistpassag.trppfrhor
 end record

 define ws            record
    confirma          char (01)
 end record

 define l_data        date,
        l_hora2       datetime hour to minute


	initialize  ws.*  to  null

 let int_flag  =  false

 open window cts11m08 at 12,44 with form "cts11m08"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona "

 if g_documento.atdsrvnum is not null then
    select trppfrdat,trppfrhor
      into d_cts11m08.trppfrdat,
           d_cts11m08.trppfrhor
      from datmassistpassag
     where atdsrvnum = g_documento.atdsrvnum
       and atdsrvano = g_documento.atdsrvano
 end if
 input by name d_cts11m08.* without defaults

    before field trppfrdat
       if g_documento.atdsrvnum is null then
          display by name d_cts11m08.trppfrdat attribute (reverse)
       else
          display by name d_cts11m08.trppfrdat
       end if

    after  field trppfrdat
       if g_documento.atdsrvnum is not null then
          next field trppfrdat
       end if
       display by name d_cts11m08.trppfrdat

       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2
       if d_cts11m08.trppfrdat is not null  then
          if d_cts11m08.trppfrdat < l_data  then
             error " Data de preferencia nao pode ser anterior a hoje! "
             next field trppfrdat
          end if

          if d_cts11m08.trppfrdat > l_data + 90 units day  then
             error " Data de preferencia nao pode ser maior que tres meses! "
             next field trppfrdat
          end if
       else
          initialize d_cts11m08.trppfrhor to null
          exit input
       end if

    before field trppfrhor
       display by name d_cts11m08.trppfrhor attribute (reverse)

    after  field trppfrhor
       display by name d_cts11m08.trppfrhor

       if fgl_lastkey() <> fgl_keyval("up")    or
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts11m08.trppfrhor is not null  then
             call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
             if d_cts11m08.trppfrdat  = l_data  and
                d_cts11m08.trppfrhor <= l_hora2 + 2 units hour  then
                error " Hora de preferencia deve ser (no minimo) apos duas horas!"
                next field trppfrhor
             end if
          end if
       end if

    on key (interrupt)
       exit input
 end input

 let int_flag = false

 close window cts11m08

 return d_cts11m08.*

end function  ###  cts11m08
