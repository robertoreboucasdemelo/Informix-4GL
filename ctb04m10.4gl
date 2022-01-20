#############################################################################
# Nome de Modulo: CTB04M10                                         Wagner   #
#                                                                           #
# Consulta itens da ordem de pagamento de RE                       Dez/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################
#                   * * * Alteracoes * * *                                  ##
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 24/03/2004 Robson, Meta      PSI187143  Criar funcao ctb04m10_consadic()   #
#                                         para pesquisar e exibir os custos  #
#                                         adicionais dos itens selecionados  #
#                                         via F8.                            #
#----------------------------------------------------------------------------#

database porto
#PSI187143 -Robson -Inicio
define m_prep_sql smallint

#--------------------------#
function ctb04m10_prepare()
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
 prepare pctb04m10001 from l_sql
 declare cctb04m10001 cursor for pctb04m10001

 let m_prep_sql = true
 
end function   
#PSI187143 -Robson -Fim

#--------------------------------------------------------------------
 function ctb04m10(param)
#--------------------------------------------------------------------

  define param       record
     socopgnum       like dbsmopgitm.socopgnum,
     atdsrvorg       like datmservico.atdsrvorg
  end record

  define a_ctb04m10  array[800] of record
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvorg       like datmservico.atdsrvorg,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     socopgdscvlr    like dbsmopgitm.socopgitmvlr,
     socconlibflg    like dbsmopgitm.socconlibflg,
     socopgitmnum    like dbsmopgitm.socopgitmnum
  end record

  define ws          record
     socopgitmcst    like dbsmopgcst.socopgitmcst
  end record

  define arr_aux     smallint


  open window w_ctb04m10 at 08,02 with form "ctb04m10"
       attribute(form line first)

  initialize a_ctb04m10    to null
  initialize ws.*          to null
  let arr_aux = 1

  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb04m10  cursor for
    select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
           dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
           dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
           datmservico.atdsrvorg  , sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, outer datmservico, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum           and
           datmservico.atdsrvnum   = dbsmopgitm.atdsrvnum      and
           datmservico.atdsrvano   = dbsmopgitm.atdsrvano      and
           dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum      and
           dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

     group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
              dbsmopgitm.atdsrvano   , dbsmopgitm.socopgitmvlr,
              dbsmopgitm.socconlibflg, dbsmopgitm.socopgitmnum,
              datmservico.atdsrvorg

     order by dbsmopgitm.socopgitmnum

  foreach c_ctb04m10 into a_ctb04m10[arr_aux].nfsnum,
                          a_ctb04m10[arr_aux].atdsrvnum,
                          a_ctb04m10[arr_aux].atdsrvano,
                          a_ctb04m10[arr_aux].socopgitmvlr,
                          a_ctb04m10[arr_aux].socconlibflg,
                          a_ctb04m10[arr_aux].socopgitmnum,
                          a_ctb04m10[arr_aux].atdsrvorg   ,
                          ws.socopgitmcst

     if param.atdsrvorg  is not null   then
        if a_ctb04m10[arr_aux].atdsrvorg <> param.atdsrvorg   then
           initialize a_ctb04m10[arr_aux].*  to null
           continue foreach
        end if
     end if

     let a_ctb04m10[arr_aux].socopgtotvlr = a_ctb04m10[arr_aux].socopgitmvlr

     if ws.socopgitmcst  is not null   then
        let a_ctb04m10[arr_aux].socopgtotvlr =
            a_ctb04m10[arr_aux].socopgtotvlr + ws.socopgitmcst
     end if

     let a_ctb04m10[arr_aux].socopgdscvlr = a_ctb04m10[arr_aux].socopgtotvlr -
                                            a_ctb04m10[arr_aux].socopgitmvlr
     if a_ctb04m10[arr_aux].socopgdscvlr is null then 
        let a_ctb04m10[arr_aux].socopgdscvlr = 0
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 800   then
        error " Limite excedido! Ordem de pagamento com mais de 800 itens!"
        exit foreach
     end if

  end foreach

  message ""
  call set_count(arr_aux-1)
  message " (F8)Consulta  (F17)Abandona " #PSI187143 -Robson

  display array a_ctb04m10 to s_ctb04m10.*

# PSI187143 -Robson - inicio

     on key (F8)
        let arr_aux = arr_curr()
        call ctb04m10_consadic(a_ctb04m10[arr_aux].atdsrvorg
                              ,a_ctb04m10[arr_aux].atdsrvnum
                              ,a_ctb04m10[arr_aux].atdsrvano
                              ,param.socopgnum
                              ,a_ctb04m10[arr_aux].socopgitmnum)        

# PSI187143 -Robson - fim

     on key (interrupt,control-c)
        exit display
  end display

  let int_flag = false
  close window w_ctb04m10

end function  ###  ctb04m10


#PSI187143 -Robson -Inicio
#-----------------------------------#
function ctb04m10_consadic(lr_param)
#-----------------------------------#
 define lr_param record
    atdsrvorg     like datmservico.atdsrvorg
   ,atdsrvnum     like dbsmopgitm.atdsrvnum
   ,atdsrvano     like dbsmopgitm.atdsrvano
   ,socopgnum     like dbsmopgitm.socopgnum
   ,socopgitmnum  like dbsmopgitm.socopgitmnum
 end record

 define al_ctb04m10 array[500] of record
   soccstcod     like dbskcustosocorro.soccstcod                  
  ,soccstdes     like dbskcustosocorro.soccstdes
  ,cstqtd        like dbsmopgcst.cstqtd
  ,socopgitmcst  like dbsmopgcst.socopgitmcst
  ,soccstclccod  like dbskcustosocorro.soccstclccod
 end record

 define l_soccstexbseq  like dbskcustosocorro.soccstexbseq

 define l_cont  smallint

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctb04m10_prepare()
 end if

 initialize al_ctb04m10 to null
 let l_cont = 1
 let l_soccstexbseq = null

 open cctb04m10001 using lr_param.socopgnum
                        ,lr_param.socopgitmnum
 foreach cctb04m10001 into al_ctb04m10[l_cont].soccstcod   
                          ,al_ctb04m10[l_cont].soccstdes   
                          ,al_ctb04m10[l_cont].cstqtd      
                          ,al_ctb04m10[l_cont].socopgitmcst
                          ,al_ctb04m10[l_cont].soccstclccod
                          ,l_soccstexbseq
    let l_cont = l_cont + 1
    if l_cont > 500 then
       error ' Limite de array excedido ' sleep 2
       exit foreach
    end if
 end foreach
 close cctb04m10001
 
 if l_cont = 1 then
    error ' Nao existem totais ' sleep 2
 else
    open window w_ctb04m07 at 09,02 with form "ctb04m07"
         attribute(form line first)

    let l_cont = l_cont - 1
    call set_count(l_cont)

    message '(CTR-C/F17) Abandona'

    display by name lr_param.atdsrvorg
    display by name lr_param.atdsrvnum
    display by name lr_param.atdsrvano
    
    display array al_ctb04m10 to s_ctb04m07.*
   
       on key(f17, control-c,interrupt)
          exit display
   
    end display
    close window w_ctb04m07
 end if

 let int_flag = false

end function
#PSI187143 -Robson -Fim 

