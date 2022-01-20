############################################################################
# Nome de Modulo: CTB11M14                                        Gilberto #
#                                                                 Marcelo  #
# Exibe contabilizacao da ordem de pagamento                      Dez/1997 #
############################################################################

database porto

#--------------------------------------------------------------------
function ctb11m14(param)
#--------------------------------------------------------------------
  define param       record
     socopgnum       like dbsmopgitm.socopgnum
  end record

  define a_ctb11m14  array[09] of record
     ctbdspcod       dec(2,0),
     ctbdspdes       char(33),
     ctbdspqtd       dec(7,0),
     ctbdspvlr       dec(15,5)
  end record

  define ws          record
     socitmdspcod    like dbsmopgitm.socitmdspcod,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr
  end record

  define arr_aux     smallint
  define scr_aux     smallint


  open window w_ctb11m14 at 08,02 with form "ctb11m14"
       attribute(form line first)

  initialize a_ctb11m14   to null
  initialize ws.*         to null

  for arr_aux = 1  to  09
    case arr_aux
         when 1  # SINISTRO/RPT
              let a_ctb11m14[01].ctbdspcod = 01
              let a_ctb11m14[01].ctbdspdes = "SINISTROS A REGULARIZAR"

         when 2  # REPLACE
              let a_ctb11m14[02].ctbdspcod = 02
              let a_ctb11m14[02].ctbdspdes = "SINISTROS A REGULARIZAR - REPLACE"

         when 3
              let a_ctb11m14[03].ctbdspcod = 03
              let a_ctb11m14[03].ctbdspdes = "CONTAS A PAGAR"

         when 4  #  DAF/OPER.ESTRADA/ASSIST.PASSAG.
              let a_ctb11m14[04].ctbdspcod = 04
              let a_ctb11m14[04].ctbdspdes = "OUTRAS DESPESAS OPERACIONAIS"

         when 5  # AVIS/MEGA/SEGCAR/REPAR
              let a_ctb11m14[05].ctbdspcod = 05
              let a_ctb11m14[05].ctbdspdes = "PORTO SOCORRO - LOCADORAS"

         when 6  # PORTOCARD
              let a_ctb11m14[06].ctbdspcod = 06
              let a_ctb11m14[06].ctbdspdes = "PORTO SOCORRO - PORTO SEGURO VISA"

         when 7  # HELP ALPHIVILLE
              let a_ctb11m14[07].ctbdspcod = 07
              let a_ctb11m14[07].ctbdspdes = "CORPORATE"

         when 8  # LINHA DE ESPACO
              let a_ctb11m14[08].ctbdspdes = ""

         when 9  # LINHA DE TOTAIS
              let a_ctb11m14[09].ctbdspdes = "TOTAL"
    end case

    let a_ctb11m14[arr_aux].ctbdspqtd = 00
    let a_ctb11m14[arr_aux].ctbdspvlr = 00.00
  end for

  #------------------------------------------------------
  # COLOCA LINHAS EM BRANCO
  #------------------------------------------------------
  initialize a_ctb11m14[08].ctbdspcod  to null
  initialize a_ctb11m14[08].ctbdspqtd  to null
  initialize a_ctb11m14[08].ctbdspvlr  to null

  #------------------------------------------------------
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #------------------------------------------------------
  message " Aguarde, pesquisando... "  attribute(reverse)

  declare c_ctb11m14  cursor for
    select dbsmopgitm.socitmdspcod,
           dbsmopgitm.socopgitmvlr,
           sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

    group by dbsmopgitm.socopgitmnum,
             dbsmopgitm.socitmdspcod,
             dbsmopgitm.socopgitmvlr

  foreach c_ctb11m14 into ws.socitmdspcod,
                          ws.socopgtotvlr,
                          ws.socopgitmcst

     if ws.socopgitmcst  is not null   then
        let ws.socopgtotvlr = ws.socopgtotvlr + ws.socopgitmcst
     end if

     let arr_aux = ws.socitmdspcod

     let a_ctb11m14[arr_aux].ctbdspqtd =
         a_ctb11m14[arr_aux].ctbdspqtd + 1

     let a_ctb11m14[arr_aux].ctbdspvlr =
         a_ctb11m14[arr_aux].ctbdspvlr + ws.socopgtotvlr

     #------------------------------------------------------
     # TOTAIS DA O.P.
     #------------------------------------------------------
     let a_ctb11m14[09].ctbdspqtd = a_ctb11m14[09].ctbdspqtd + 1
     let a_ctb11m14[09].ctbdspvlr = a_ctb11m14[09].ctbdspvlr + ws.socopgtotvlr

  end foreach

  call set_count(09)
  message " (F17)Abandona, (F3)Prox.Pag, (F4)Pag.Ant"

  display array a_ctb11m14 to s_ctb11m14.*
     on key (interrupt,control-c)
        exit display
  end display

  let int_flag = false
  close c_ctb11m14
  close window w_ctb11m14

end function  ###  ctb11m14
