###############################################################################
# Nome do Modulo: CTB12M07                                           Gilberto #
#                                                                     Marcelo #
# Localiza laudo de servico (PAGAMENTOS)                             Abr/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 13/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###############################################################################

database porto

#------------------------------------------------------------
 function ctb12m07()
#------------------------------------------------------------

 define a_ctb12m07    array[400] of record
    servico2          char (13)                   ,
    nom               like datmservico.nom        ,
    situacao          char (14)                   ,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    vcldes            like datmservico.vcldes     ,
    vcllicnum2        like datmservico.vcllicnum
 end record

 define d_ctb12m07    record
    atddat            like datmservico.atddat   ,
    atdsrvorg         like datmservico.atdsrvorg,
    srvtipdes         like datksrvtip.srvtipdes ,
    vcllicnum         like datmservico.vcllicnum,
    nome              char (30)
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    acao              char(03)                  ,
    nome              char(15)                  ,
    total             char(10)                  ,
    comando1          char(800)                 ,
    comando2          char(200)                 ,
    selected          smallint                  ,
    atdsrvorg         like datmservico.atdsrvorg,
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod
 end record

 define retorno       record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define arr_aux       smallint
 define scr_aux       smallint

#----------------------------------------
# PREPARA COMANDO SQL
#----------------------------------------
 let ws.comando1 = "select atdetpcod    ",
                  "  from datmsrvacp   ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?",
                  "   and atdsrvseq = (select max(atdsrvseq)",
                                      "  from datmsrvacp    ",
                                      " where atdsrvnum = ? ",
                                      "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando1
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let ws.comando1 = "select atdetpdes    ",
                   "  from datketapa    ",
                   " where atdetpcod = ?"
 prepare sel_datketapa from ws.comando1
 declare c_datketapa cursor for sel_datketapa


open window w_ctb12m07 at  07,02 with form "ctb12m07"
            attribute(form line first)

while true

   initialize ws.*          to null
   initialize retorno.*     to null
   initialize a_ctb12m07    to null
   let int_flag = false
   let arr_aux  = 1

   input by name d_ctb12m07.*

      before field atddat
         display by name d_ctb12m07.atddat    attribute (reverse)

         let d_ctb12m07.atddat = today

      after  field atddat
         display by name d_ctb12m07.atddat

         if d_ctb12m07.atddat  is null   then
            error " Informe a data do atendimento do servico!"
            next field atddat
         end if

      before field atdsrvorg
         initialize d_ctb12m07.srvtipdes to null
         display by name d_ctb12m07.srvtipdes
         display by name d_ctb12m07.atdsrvorg    attribute (reverse)

      after  field atdsrvorg
         display by name d_ctb12m07.atdsrvorg

         if d_ctb12m07.atdsrvorg  is null   then
            let d_ctb12m07.srvtipdes = "TODOS"
         else
            select srvtipdes
              into d_ctb12m07.srvtipdes
              from datksrvtip
             where atdsrvorg = d_ctb12m07.atdsrvorg

            if sqlca.sqlcode = notfound  then
               error "Tipo de servico invalido!"
               call cts00m09() returning d_ctb12m07.atdsrvorg
               next field atdsrvorg
            end if
         end if

         display by name d_ctb12m07.srvtipdes

      before field vcllicnum
         display by name d_ctb12m07.vcllicnum attribute (reverse)

      after field vcllicnum
         display by name d_ctb12m07.vcllicnum

         if d_ctb12m07.vcllicnum  is not null   then
            initialize d_ctb12m07.nome   to null
            exit input
         end if

      before field nome
         display by name d_ctb12m07.nome    attribute (reverse)

      after field nome
         display by name d_ctb12m07.nome

         initialize ws.nome  to null
         if d_ctb12m07.nome  is not null   then
            let ws.nome = d_ctb12m07.nome clipped, "*"
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   let ws.comando1 = "select srvtipabvdes",
                     "  from datksrvtip  ",
                     " where atdsrvorg = ?  "

   prepare sel_datksrvtip from ws.comando1
   declare c_datksrvtip cursor for sel_datksrvtip

   #-------------------------------------------
   # CONSULTA OS SERVICOS REALIZADOS NA DATA
   #-------------------------------------------
   if d_ctb12m07.nome   is not null   then
      if d_ctb12m07.atdsrvorg is not null   then
         let ws.comando2 = "  from datmservico ",
                           " where datmservico.atddat    = ?    and ",
                           "       datmservico.atdsrvorg = ?    and ",
                           "       datmservico.nom matches '", ws.nome, "'"
      else
         let ws.comando2 = "  from datmservico ",
                           " where datmservico.atddat    = ?    and ",
                           "       datmservico.atdsrvorg <> 10  and ",
                           "       datmservico.atdsrvorg <> 12  and ",
                           "       datmservico.nom matches '", ws.nome, "'"
      end if
   else
      if d_ctb12m07.vcllicnum  is not null   then
         if d_ctb12m07.atdsrvorg is not null   then
            let ws.comando2 = "  from datmservico ",
                              " where datmservico.atddat    = ?    and ",
                              "       datmservico.atdsrvorg = ?    and ",
                              "       datmservico.vcllicnum = ?     "
         else
            let ws.comando2 = "  from datmservico ",
                              " where datmservico.atddat    = ?    and ",
                              "       datmservico.atdsrvorg <> 10  and ",
                              "       datmservico.atdsrvorg <> 12  and ",
                              "       datmservico.vcllicnum = ?     "
         end if
      else
         if d_ctb12m07.atdsrvorg is not null   then
            let ws.comando2 = "  from datmservico ",
                              " where datmservico.atddat    = ?    and ",
                              "       datmservico.atdsrvorg = ?        "
         else
            let ws.comando2 = "  from datmservico ",
                              " where datmservico.atddat    = ?    and ",
                              "       datmservico.atdsrvorg <> 10  and ",
                              "       datmservico.atdsrvorg <> 12      "
         end if
      end if
   end if

   let ws.comando1 = " select                 ",
                     " datmservico.atdsrvnum, ",
                     " datmservico.atdsrvano, ",
                     " datmservico.nom      , ",
                     " datmservico.vcldes   , ",
                     " datmservico.vcllicnum, ",
                     " datmservico.atdfnlflg, ",
                     " datmservico.atdsrvorg  ",
                     ws.comando2 clipped

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare comando_aux from ws.comando1
   declare c_ctb12m07 cursor for comando_aux

   if d_ctb12m07.vcllicnum  is not null   then
      if d_ctb12m07.atdsrvorg  is not null   then
         open c_ctb12m07  using d_ctb12m07.atddat, d_ctb12m07.atdsrvorg,
                                d_ctb12m07.vcllicnum
      else
         open c_ctb12m07  using d_ctb12m07.atddat, d_ctb12m07.vcllicnum
      end if
   else
      if d_ctb12m07.nome  is not null   then
         if d_ctb12m07.atdsrvorg  is not null   then
            open c_ctb12m07  using d_ctb12m07.atddat, d_ctb12m07.atdsrvorg
         else
            open c_ctb12m07  using d_ctb12m07.atddat
         end if
      else
         if d_ctb12m07.atdsrvorg  is not null   then
            open c_ctb12m07  using d_ctb12m07.atddat, d_ctb12m07.atdsrvorg
         else
            open c_ctb12m07  using d_ctb12m07.atddat
         end if
      end if
   end if

   foreach  c_ctb12m07  into  ws.atdsrvnum                  ,
                              ws.atdsrvano                  ,
                              a_ctb12m07[arr_aux].nom       ,
                              a_ctb12m07[arr_aux].vcldes    ,
                              a_ctb12m07[arr_aux].vcllicnum2,
                              ws.atdfnlflg                 ,
                              ws.atdsrvorg

      let a_ctb12m07[arr_aux].servico2 =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                     " ", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                     "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

      #------------------------------------------------------------
      # Verifica etapa do servico
      #------------------------------------------------------------
    # if ws.atdfnlflg  is null    then
    #    let a_ctb12m07[arr_aux].situacao = "AGUARDANDO"
    # else
    #    case  ws.atdfnlflg
    #       when  "L"
    #          let a_ctb12m07[arr_aux].situacao = "CANCELADO"
    #       when  "C"
    #          let a_ctb12m07[arr_aux].situacao = "CONCLUIDO"
    #       when  "E"
    #          let a_ctb12m07[arr_aux].situacao = "EXCLUIDO"
    #       otherwise
    #          let a_ctb12m07[arr_aux].situacao = "N/PREVISTO"
    #    end case
    # end if
      open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                               ws.atdsrvnum, ws.atdsrvano
      fetch c_datmsrvacp into  ws.atdetpcod
      close c_datmsrvacp

      if sqlca.sqlcode = 0  then
         open  c_datketapa using ws.atdetpcod
         fetch c_datketapa into  a_ctb12m07[arr_aux].situacao
         close c_datketapa
        else
         let a_ctb12m07[arr_aux].situacao = "N/PREVISTO"
      end if

      initialize a_ctb12m07[arr_aux].srvtipabvdes  to null

      open  c_datksrvtip using ws.atdsrvorg
      fetch c_datksrvtip into  a_ctb12m07[arr_aux].srvtipabvdes
      close c_datksrvtip

      let arr_aux = arr_aux + 1
      if arr_aux > 400  then
         error " Limite excedido, pesquisa com mais de 400 servicos!"
         exit foreach
      end if

   end foreach

   if arr_aux  =  1   then
      error " Nao existem servicos para pesquisa!"
   end if

   let ws.total = "Total: ", arr_aux - 1  using "&&&"

   display by name ws.total attribute (reverse)
   message " (F17)Abandona, (F8)Seleciona"

   call set_count(arr_aux-1)

   display array  a_ctb12m07 to s_ctb12m07.*
      on key(interrupt)
         initialize ws.total to null
         display by name ws.total
         exit display

      on key (F8)
         let arr_aux = arr_curr()
         let retorno.atdsrvnum = a_ctb12m07[arr_aux].servico2[4,10]
         let retorno.atdsrvano = a_ctb12m07[arr_aux].servico2[12,13]
         let ws.selected = true
         exit display
   end display

   for arr_aux = 1 to 4
      clear s_ctb12m07[arr_aux].servico2
      clear s_ctb12m07[arr_aux].srvtipabvdes
      clear s_ctb12m07[arr_aux].nom
      clear s_ctb12m07[arr_aux].situacao
      clear s_ctb12m07[arr_aux].vcldes
      clear s_ctb12m07[arr_aux].vcllicnum2
   end for

   if ws.selected = true              and
      retorno.atdsrvnum  is not null  and
      retorno.atdsrvano  is not null  then
      exit while
   end if
end while

let int_flag = false
close window  w_ctb12m07
return retorno.*

end function  ###  ctb12m07
