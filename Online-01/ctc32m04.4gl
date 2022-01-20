############################################################################
# Menu de Modulo: ctc32m04                                        Gilberto #
#                                                                  Marcelo #
# Consulta Cadastro de Bloqueios                                  Abr/1998 #
############################################################################
#                      MANUTENCAO                                          #               
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86              #
#--------------------------------------------------------------------------#
# 31/12/2009  Amilton, Meta                      Projeto Succod smallint   #
#--------------------------------------------------------------------------#
 database porto

#---------------------------------------------------------------
 function ctc32m04()
#---------------------------------------------------------------

 define d_ctc32m04   record
    psqdat           date
 end record

 define a_ctc32m04   array[100] of record
    blqnum           like datkblq.blqnum,
    blqchvdes        char(09),
    blqchvcnt        char(25),
    blqnivdes        char(08),
    viginc           like datkblq.viginc,
    vigfnl           like datkblq.vigfnl
 end record

 define ws           record
    ramcod           like datkblq.ramcod,
    succod           like datkblq.succod,
    aplnumdig        like datkblq.aplnumdig,
    itmnumdig        like datkblq.itmnumdig,
    vcllicnum        like datkblq.vcllicnum,
    vclchsinc        like datkblq.vclchsinc,
    vclchsfnl        like datkblq.vclchsfnl,
    corsus           like datkblq.corsus,
    pstcoddig        like datkblq.pstcoddig,
    segnumdig        like datkblq.segnumdig,
    ctgtrfcod        like datkblq.ctgtrfcod,
    blqnivcod        like datkblq.blqnivcod,
    comando1         char(800),
    comando2         char(300)
 end record

 define arr_aux      integer
 define scr_aux      integer


 open window w_ctc32m04 at  06,02 with form "ctc32m04"
             attribute(form line first)

 while true

    initialize ws.*               to null
    initialize a_ctc32m04         to null
    initialize d_ctc32m04.psqdat  to null

    let int_flag = false
    let arr_aux  = 1

    input by name d_ctc32m04.*  without defaults

       before field psqdat
              display by name d_ctc32m04.psqdat     attribute(reverse)

       after  field psqdat
              display by name d_ctc32m04.psqdat

              if d_ctc32m04.psqdat  is null  then
                 error " Data para pesquisa deve ser informada!"
                 next field psqdat
              end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

    #-----------------------------------------------------------------
    # Monta comando SQL para consulta
    #-----------------------------------------------------------------
    let ws.comando1 = "select blqnum,    ",
                      "       viginc,    ",
                      "       vigfnl,    ",
                      "       ramcod,    ",
                      "       succod,    ",
                      "       aplnumdig, ",
                      "       itmnumdig, ",
                      "       vcllicnum, ",
                      "       vclchsinc, ",
                      "       vclchsfnl, ",
                      "       corsus,    ",
                      "       pstcoddig, ",
                      "       segnumdig, ",
                      "       ctgtrfcod, ",
                      "       blqnivcod  "

    if d_ctc32m04.psqdat  is not null   then
       let ws.comando2 = " from datkblq ",
                         " where viginc > ? "
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)

    let ws.comando1 = ws.comando1 clipped," ", ws.comando2
    prepare comando_aux from ws.comando1

    declare c_ctc32m04 cursor for comando_aux

    if d_ctc32m04.psqdat  is not null   then
       open c_ctc32m04  using  d_ctc32m04.psqdat
    end if

    foreach c_ctc32m04 into  a_ctc32m04[arr_aux].blqnum,
                             a_ctc32m04[arr_aux].viginc,
                             a_ctc32m04[arr_aux].vigfnl,
                             ws.ramcod,
                             ws.succod,
                             ws.aplnumdig,
                             ws.itmnumdig,
                             ws.vcllicnum,
                             ws.vclchsinc,
                             ws.vclchsfnl,
                             ws.corsus,
                             ws.pstcoddig,
                             ws.segnumdig,
                             ws.ctgtrfcod,
                             ws.blqnivcod

       case ws.blqnivcod
            when 01   let a_ctc32m04[arr_aux].blqnivdes = "ALERTA"
            when 02   let a_ctc32m04[arr_aux].blqnivdes = "SENHA"
            when 03   let a_ctc32m04[arr_aux].blqnivdes = "N.ATENDE"
       end case

       if ws.ramcod      is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "APOLICE"

          if ws.ramcod  =  31  or  
             ws.ramcod  =  531  then
             let a_ctc32m04[arr_aux].blqchvcnt =
                 ws.ramcod     using "&&&&"       clipped, "/",
                 ws.succod     using "###&&"      clipped, "/",#using "&&"         clipped, "/", # Projeto succod
                 ws.aplnumdig  using "<<<<<<<<<"  clipped, "/",
                 ws.itmnumdig  using "<<<<<<<"    clipped
          else
             let a_ctc32m04[arr_aux].blqchvcnt =
                 ws.ramcod     using "&&&&"       clipped, "/",
                 ws.succod     using "###&&"      clipped, "/",#using "&&"         clipped, "/", # Projeto Succod
                 ws.aplnumdig  using "<<<<<<<<<"
          end if
       end if

       if ws.vcllicnum   is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "PLACA"
          let a_ctc32m04[arr_aux].blqchvcnt = ws.vcllicnum
       end if

       if ws.vclchsinc   is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "CHASSI"
          let a_ctc32m04[arr_aux].blqchvcnt = ws.vclchsinc clipped, ws.vclchsfnl
       end if

       if ws.corsus      is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "SUSEP"
          let a_ctc32m04[arr_aux].blqchvcnt = ws.corsus
       end if

       if ws.pstcoddig   is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "PREST."
          let a_ctc32m04[arr_aux].blqchvcnt = ws.pstcoddig
       end if

       if ws.segnumdig   is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "SEGUR."
          let a_ctc32m04[arr_aux].blqchvcnt = ws.segnumdig
       end if

       if ws.ctgtrfcod   is not null   then
          let a_ctc32m04[arr_aux].blqchvdes = "C.TARIF."
          let a_ctc32m04[arr_aux].blqchvcnt = ws.ctgtrfcod
       end if

       let arr_aux = arr_aux + 1
       if arr_aux  >  100    then
          error " Limite excedido, pesquisa com mais de 100 bloqueios!"
          exit foreach
       end if

    end foreach

    message ""

    if arr_aux  >  1   then
       message " (F17)Abandona"
       call set_count(arr_aux-1)

       display array  a_ctc32m04 to s_ctc32m04.*

          on key(interrupt)
             for arr_aux = 1 to 10
                 clear s_ctc32m04[arr_aux].*
             end for
             initialize a_ctc32m04  to null
             exit display

       end display
    else
       error " Nao foi encontrado nenhum bloqueio para pesquisa!"
    end if

 end while

 let int_flag = false
 close window  w_ctc32m04

end function  #  ctc32m04
