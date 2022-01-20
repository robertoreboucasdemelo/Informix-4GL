#############################################################################
# Nome de Modulo: CTB11M10                                         Gilberto #
#                                                                  Marcelo  #
# Consulta itens da ordem de pagamento                             Abr/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 10/04/2001  PSI 12759-0  Wagner       Inclusao campo desconto do item     #
#############################################################################
#                   * * * Alteracoes * * *                                  ##
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 24/03/2004 Robson, Meta      PSI187143  Criar funcao ctb11m10_consadic()   #
#                                         para pesquisar e exibir os custos  #
#                                         adicionais dos itens selecionados  #
#                                         via F8.                            #
#----------------------------------------------------------------------------#

database porto

#PSI187143 -Robson -Inicio

define m_prep_sql smallint

#--------------------------#
function ctb11m10_prepare()
#--------------------------#
 define l_sql char(800)

 let l_sql = ' select dbskcustosocorro.soccstcod '
                  ,' ,dbskcustosocorro.soccstdes '
                  ,' ,dbsmopgcst.cstqtd '
                  ,' ,dbsmopgcst.socopgitmcst '
                  ,' ,dbskcustosocorro.soccstclccod '
                  ,' ,dbskcustosocorro.soccstexbseq '
              ,' from dbskcustosocorro '
                  ,' ,dbsmopgcst '
             ,' where dbskcustosocorro.soccstcod = dbsmopgcst.soccstcod '
               ,' and dbskcustosocorro.soccstcod not in (1,2,7,8) '
               ,' and dbsmopgcst.socopgnum    = ? '
               ,' and dbsmopgcst.socopgitmnum = ? '
             ,' order by dbskcustosocorro.soccstexbseq '
                     ,' ,dbskcustosocorro.soccstdes '
 prepare pctb11m10001 from l_sql
 declare cctb11m10001 cursor for pctb11m10001

 let m_prep_sql = true

end function

#PSI187143 -Robson -Fim

#--------------------------------------------------------------------
 function ctb11m10(param)
#--------------------------------------------------------------------

  define param       record
     socopgnum       like dbsmopgitm.socopgnum,
     atdsrvorg       like datmservico.atdsrvorg
  end record

  define a_ctb11m10  array[1800] of record
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvorg       like datmservico.atdsrvorg,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     vlrfxacod       like dbsmopgitm.vlrfxacod,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     socopgdscvlr    like dbsmopgitm.socopgitmvlr,
     socconlibflg    like dbsmopgitm.socconlibflg,
     socopgitmnum    like dbsmopgitm.socopgitmnum
  end record

  define ws          record
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     srvrmedifvlr    like dbsksrvrmeprc.srvrmedifvlr
  end record

  define arr_aux     smallint


  open window w_ctb11m10 at 08,02 with form "ctb11m10"
       attribute(form line first)

  initialize a_ctb11m10    to null
  initialize ws.*          to null
  let arr_aux = 1

  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb11m10  cursor for
    select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
           dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
           dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
           dbsmopgitm.vlrfxacod   , sum(dbsmopgcst.socopgitmcst),
           datmservico.atdsrvorg
      from dbsmopgitm, outer datmservico, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           datmservico.atdsrvnum   = dbsmopgitm.atdsrvnum      and
           datmservico.atdsrvano   = dbsmopgitm.atdsrvano      and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

     group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
              dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
              dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
              dbsmopgitm.vlrfxacod   , datmservico.atdsrvorg

     order by dbsmopgitm.socopgitmnum

  foreach c_ctb11m10 into a_ctb11m10[arr_aux].nfsnum,
                          a_ctb11m10[arr_aux].atdsrvnum,
                          a_ctb11m10[arr_aux].atdsrvano,
                          a_ctb11m10[arr_aux].socopgitmvlr,
                          a_ctb11m10[arr_aux].socconlibflg,
                          a_ctb11m10[arr_aux].socopgitmnum,
                          a_ctb11m10[arr_aux].vlrfxacod,
                          ws.socopgitmcst,
                          a_ctb11m10[arr_aux].atdsrvorg

     select socopgitmcst
       into a_ctb11m10[arr_aux].socopgdscvlr
       from dbsmopgcst
      where dbsmopgcst.socopgnum    = param.socopgnum
        and dbsmopgcst.socopgitmnum = a_ctb11m10[arr_aux].socopgitmnum
        and dbsmopgcst.soccstcod    = 07

     if sqlca.sqlcode = notfound then
        let a_ctb11m10[arr_aux].socopgdscvlr = 0
     end if

     if param.atdsrvorg  is not null   then
        if a_ctb11m10[arr_aux].atdsrvorg <> param.atdsrvorg   then
           initialize a_ctb11m10[arr_aux].*  to null
           continue foreach
        end if
     end if

     let a_ctb11m10[arr_aux].socopgtotvlr = a_ctb11m10[arr_aux].socopgitmvlr

     if ws.socopgitmcst  is not null   then
        let a_ctb11m10[arr_aux].socopgtotvlr =
            a_ctb11m10[arr_aux].socopgtotvlr + ws.socopgitmcst
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 1800   then
        error " Limite excedido! Ordem de pagamento com mais de 1800 itens!"
        exit foreach
     end if

  end foreach

  message ""
  call set_count(arr_aux-1)
  message " (F8)Consulta  (F17)Abandona " #PSI187143 -Robson

  display array a_ctb11m10 to s_ctb11m10.*

# PSI187143 -Robson - inicio

     on key (F8)
        let arr_aux = arr_curr()
        call ctb11m10_consadic(a_ctb11m10[arr_aux].atdsrvorg
                              ,a_ctb11m10[arr_aux].atdsrvnum
                              ,a_ctb11m10[arr_aux].atdsrvano
                              ,param.socopgnum
                              ,a_ctb11m10[arr_aux].socopgitmnum)

# PSI187143 -Robson - fim

     on key (interrupt,control-c)
        exit display
  end display

  let int_flag = false
  close window w_ctb11m10

end function  ###  ctb11m10

#PSI187143 -Robson -Inicio
#-----------------------------------#
function ctb11m10_consadic(lr_param)
#-----------------------------------#
 define lr_param record
    atdsrvorg     like datmservico.atdsrvorg
   ,atdsrvnum     like dbsmopgitm.atdsrvnum
   ,atdsrvano     like dbsmopgitm.atdsrvano
   ,socopgnum     like dbsmopgitm.socopgnum
   ,socopgitmnum  like dbsmopgitm.socopgitmnum
 end record

 define al_ctb11m10 array[500] of record
   soccstcod     like dbskcustosocorro.soccstcod
  ,soccstdes     like dbskcustosocorro.soccstdes
  ,cstqtd        like dbsmopgcst.cstqtd
  ,socopgitmcst  like dbsmopgcst.socopgitmcst
  ,soccstclccod  like dbskcustosocorro.soccstclccod
 end record

 define l_cont         smallint
       ,l_soccstexbseq like dbskcustosocorro.soccstexbseq

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctb11m10_prepare()
 end if

 initialize al_ctb11m10 to null
 let l_cont = 1
 let l_soccstexbseq = null

 open cctb11m10001 using lr_param.socopgnum
                        ,lr_param.socopgitmnum
 foreach cctb11m10001 into al_ctb11m10[l_cont].soccstcod
                          ,al_ctb11m10[l_cont].soccstdes
                          ,al_ctb11m10[l_cont].cstqtd
                          ,al_ctb11m10[l_cont].socopgitmcst
                          ,al_ctb11m10[l_cont].soccstclccod
                          ,l_soccstexbseq
    let l_cont = l_cont + 1
    if l_cont > 500 then
       error ' Limite de array excedido ' sleep 2
       exit foreach
    end if
 end foreach
 close cctb11m10001

 if l_cont = 1 then
    error ' Nao existem totais ' sleep 2
 else
    open window w_ctb11m07 at 09,02 with form "ctb11m07"
         attribute(form line first)

    let l_cont = l_cont - 1
    call set_count(l_cont)

    message '(CTR-C/F17) Abandona'

    display by name lr_param.atdsrvorg
    display by name lr_param.atdsrvnum
    display by name lr_param.atdsrvano

    display array al_ctb11m10 to s_ctb11m07.*
       on key(f17, control-c,interrupt)
          exit display
    end display

    close window w_ctb11m07
 end if

 let int_flag = false

end function
#PSI187143 -Robson -Fim

