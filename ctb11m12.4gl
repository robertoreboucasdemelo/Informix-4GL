#############################################################################
# Nome do Modulo: ctb11m12                                         Marcelo  #
#                                                                  Gilberto #
# Dados sobre tributacao                                           Out/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 03/05/1999  ** ERRO **   Gilberto     Inclusao de verificacao para evitar #
#                                       alteracoes na empresa depois da di- #
#                                       gitacao da empresa.                 #
#############################################################################

 database porto

#------------------------------------------------------------------------
 function ctb11m12(w_operacao, d_ctb11m12)
#------------------------------------------------------------------------

 define w_operacao    char (01)

 define d_ctb11m12    record
    cgccpfnum         like cgpkprestn.cgccpfnum,
    cgcord            like cgpkprestn.cgcord,
    empcod            like cgpkprestn.empcod,
    succod            like cgpkprestn.succod,
    prstip            like cgpkprestn.prstip
 end record

 define ws            record
    empcod            like gabkemp.empcod,
    empnom            like gabkemp.empnom,
    sucnom            like gabksuc.sucnom,
    prscod            like cgpkprestn.prscod,
    cntnom            like cgpkcontrn.cntnom,
    prstipdes         like cgckprest.prstipdes
 end record

 if w_operacao = "C"  then
    if d_ctb11m12.empcod is null  or
       d_ctb11m12.succod is null  or
       d_ctb11m12.prstip is null  then
       error " Nao ha' tributacao para esta ordem de pagamento!"
       return d_ctb11m12.*
    end if
 end if

 open window w_ctb11m12 at 12,18 with form "ctb11m12"
             attribute(form line first, border, comment line last - 1)

 message " (F17)Abandona"

 initialize ws.*  to null

 if d_ctb11m12.cgcord is null  then
    let d_ctb11m12.cgcord = 0
 end if

 input by name d_ctb11m12.empcod  without defaults

    before field empcod
       if d_ctb11m12.cgccpfnum is not null  and
          d_ctb11m12.cgcord    is not null  and
          d_ctb11m12.empcod    is not null  and
          d_ctb11m12.succod    is not null  and
          d_ctb11m12.prstip    is not null  then

          let ws.empcod = d_ctb11m12.empcod
          let ws.empnom = "*** NAO CADASTRADA! ***"

          select empnom
            into ws.empnom
            from gabkemp
           where empcod = d_ctb11m12.empcod

          let ws.sucnom = "*** NAO CADASTRADA! ***"

          select sucnom
            into ws.sucnom
            from gabksuc
           where succod = d_ctb11m12.succod

          let ws.prstipdes = "*** NAO CADASTRADO! ***"

          select prstipdes
            into ws.prstipdes
            from cgckprest
           where prstip = d_ctb11m12.prstip

          let ws.cntnom = "*** NAO CADASTRADO! ***"

          select cntnom
            into ws.cntnom
            from cgpkcontrn
           where cgccpfnum = d_ctb11m12.cgccpfnum  and
                 cgcord    = d_ctb11m12.cgcord

          select prscod
            into ws.prscod
            from cgpkprestn
           where cgccpfnum = d_ctb11m12.cgccpfnum  and
                 cgcord    = d_ctb11m12.cgcord     and
                 empcod    = d_ctb11m12.empcod     and
                 succod    = d_ctb11m12.succod     and
                 prstip    = d_ctb11m12.prstip     and
                 empcod <> 0 			   and
                 succod <> 0

          display by name d_ctb11m12.empcod thru d_ctb11m12.prstip
          display by name ws.*

          display by name d_ctb11m12.empcod attribute (reverse)
       else
          call ctb11m13 (d_ctb11m12.*)
               returning d_ctb11m12.*
          exit input
       end if

    after  field empcod
       display by name d_ctb11m12.empcod

       if w_operacao = "C"  then
          error " Nao e' possivel realizar alteracoes!"
          let d_ctb11m12.empcod = ws.empcod
          next field empcod
       end if

       if d_ctb11m12.empcod is null       or
          d_ctb11m12.empcod <> ws.empcod  then
          initialize d_ctb11m12.empcod thru d_ctb11m12.prstip  to null
          call ctb11m13 (d_ctb11m12.*)
               returning d_ctb11m12.*
          exit input
       end if

       select prscod
         into ws.prscod
         from cgpkprestn
        where cgccpfnum = d_ctb11m12.cgccpfnum  and
              cgcord    = d_ctb11m12.cgcord     and
              empcod    = d_ctb11m12.empcod     and
              succod    = d_ctb11m12.succod     and
              prstip    = d_ctb11m12.prstip     and
              empcod <> 0			and
              succod <> 0

       if sqlca.sqlcode <> 0  then
          error " Prestador nao cadastrado como contribuinte!"
          next field empcod
       end if

    on key (interrupt)
       select prscod
         into ws.prscod
         from cgpkprestn
        where cgccpfnum = d_ctb11m12.cgccpfnum  and
              cgcord    = d_ctb11m12.cgcord     and
              empcod    = d_ctb11m12.empcod     and
              succod    = d_ctb11m12.succod     and
              prstip    = d_ctb11m12.prstip     and
              empcod <> 0			and
              succod <> 0

       if sqlca.sqlcode <> 0  then
          error " Prestador nao cadastrado como contribuinte!"
          next field empcod
       end if

       exit input

 end input

 if d_ctb11m12.cgcord = 0  then
    initialize d_ctb11m12.cgcord to null
 end if

 let int_flag = false
 close window  w_ctb11m12
 return d_ctb11m12.*

end function  ###  ctb11m12
