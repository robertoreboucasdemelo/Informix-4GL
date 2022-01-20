###############################################################################
# Sistema........: RE                                                         #
# Modulo.........: ctb10m10                                                   #
# PSI............: 15053-3                                                    #
# Objetivo.......: Cadastro de controle de precos para servicos de RE         #
# Analista Resp..: Wagner Agostinho                                           #
# Desenvolvimento: Leandro - Fabrica de Software                              #
# Liberacao......:                                                            #
# Data...........: 11/04/2002                                                 #
###############################################################################
#                                                                             #
# PSI 251143    Kevellin    Inclusao do Complemento de Mao de Obra e Retirada #
#                           da tela da data de atualizacao                    #
#                                                                             #
###############################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_tela          record
       soctrfcod       like dbsktarifasocorro.soctrfcod
      ,soctrfdes       like dbsktarifasocorro.soctrfdes
      ,socntzcod       like datksocntz.socntzcod
      ,socntzdes       like datksocntz.socntzdes
      ,caddat          like dbsksrvrmeprc.caddat
      ,nome            char(30)
end record

define arr_tela        array[200] of record
       viginc          like dbsksrvrmeprc.viginc
      ,vigfnl          like dbsksrvrmeprc.vigfnl
      ,srvrmevlr       like dbsksrvrmeprc.srvrmevlr
      ,srvrmedifvlr    like dbsksrvrmeprc.srvrmedifvlr
      ,srvrmedscmltvlr like dbsksrvrmeprc.srvrmedscmltvlr
      ,mobcmpvlr       like dbsksrvrmeprc.mobcmpvlr
      #,atldat          like dbsksrvrmeprc.atldat
      ,funnom          char(16)
      ,ghost           char(01)
end record

define m_opcao         char(01) ,
       m_arr           smallint ,
       l_tela          smallint ,
       m_totalarray    smallint ,
       m_sql           char(500),
       m_count         smallint ,
       m_vigfnl        date     ,
       m_resp          char(1)  ,
       m_loop          char(1)  ,
       m_trfcod        smallint ,
       m_ntzcod        smallint ,
       m_socntzcod     like datksocntz.socntzcod,
       m_flag          char(1)  ,
       m_dntzcod       like datksocntz.socntzcod,
       m_flagrel       smallint,
       w_atldat        like dbsksrvrmeprc.atldat,
       w_cadmat        like dbsksrvrmeprc.cadmat,
       w_cademp        like dbsksrvrmeprc.cademp,
       w_usrtip        like dbsksrvrmeprc.cadusrtip,
       w_soctip        like dbsktarifasocorro.soctip

################################################################################
function ctb10m10()
#------------------------------------------------------------------------------#

initialize m_tela.* to null
initialize arr_tela to null

open window w_ctb10m10 at 2, 2 with form "ctb10m10"
     attribute (border, menu line 1,prompt line last)

   menu "TABELA_PRECOS"
   before menu

      command key(S) "Seleciona" "Selecionar Tabela de precos RE"
         message ""
         clear form
         let m_opcao = "S"
         call ctb10m10_input()

      command key(P) "Proximo" "Selecionar Proximo da Tabela de precos RE"
         message ""
         if m_opcao = "C" then
            call consulta_navega(1)
         else
            if m_tela.soctrfdes is not null then
               call ctb10m10_navega(1)
            else
               error "Nenhuma linha seleciona !"
               next option "Seleciona"
            end if
         end if

      command key(A) "Anterior" "Selecionar Anterior da Tabela de precos RE"
         message ""
         if m_opcao = "C" then
            call consulta_navega(-1)
         else
            if m_tela.soctrfdes is not null then
               call ctb10m10_navega(-1)
            else
               error "Nenhuma linha seleciona !"
               next option "Seleciona"
            end if
         end if

      command key(C) "Consulta" "Consulta natureza em vigor"
         message ""
         clear form
         let m_opcao = "C"
         call ctb10m10_input()

      command key(M) "Modifica" "Modifica a linha corrente selecionada"
         message ""
         if arr_tela[1].viginc is not null then
            let m_opcao = "A"
            call ctb10m10_display_array()
            let m_tela.soctrfcod = null
         else
            error "Selecionar antes de alterar !"
            next option "Seleciona"
         end if

      command key(R) "Remove" "Remove a linha corrente selecionada"
         message ""
         if arr_tela[1].viginc is not null then
            call ctb10m10_remove()
         else
            error "Selecionar antes de remover !"
            next option "Seleciona"
         end if

      command key(I) "Inclui" "Inclui Tabela de precos RE"
         message ""
         clear form
         let m_opcao = "I"
         call ctb10m10_input()

      command key(E) "Encerra" "Retorna ao menu anterior"
         exit menu
         clear screen

   end menu

close window w_ctb10m10

end function

################################################################################
function ctb10m10_prepares()
#------------------------------------------------------------------------------#

   let m_sql = " select soctrfdes, soctip from dbsktarifasocorro ",
               " where  soctrfcod = ? "
   prepare p_ctb10m10001 from m_sql
   declare c_ctb10m10001 cursor for p_ctb10m10001


   let m_sql = " select socntzdes from datksocntz ",
               " where  socntzcod = ? "
   prepare p_ctb10m10002 from m_sql
   declare c_ctb10m10002 cursor for p_ctb10m10002


   let m_sql = " insert into dbsksrvrmeprc ",
               " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
   prepare p_ctb10m10004 from m_sql


   let m_sql = " select funnom from isskfunc ",
               " where  funmat = ? ",
               "   and  empcod = ? ",
               "   and  usrtip = ? "
   prepare p_ctb10m10005 from m_sql
   declare c_ctb10m10005 cursor for p_ctb10m10005

{
   let m_sql = "select soctrfcod, socntzcod from dbsksrvrmeprc  "
              ," where soctrfcod >= ? "
              ,"   and socntzcod >= ? "
              ,"   and viginc    <= ? "
              ,"   and vigfnl    >= ? "
              ," group by 1,2 order by 1,2 "

   prepare p_ctb10m10006 from m_sql
   declare c_ctb10m10006 scroll cursor for p_ctb10m10006
}
end function

################################################################################
function ctb10m10_input()
#------------------------------------------------------------------------------#
   define aux smallint

   call ctb10m10_prepares()

   let int_flag         = false
   let m_flagrel        = null
   initialize m_tela.* to null
   initialize arr_tela to null

   while true
   input by name m_tela.soctrfcod,
                 m_tela.socntzcod without defaults {attributes (normal)}

      before field soctrfcod
         display by name m_tela.soctrfcod
         if m_opcao = 'C'                and
            m_tela.soctrfcod is not null and
            m_tela.soctrfcod > 0         and
            m_tela.socntzcod is not null and
            m_tela.socntzcod > 0         then
            next field socntzcod
         end if

      after field soctrfcod
         display by name m_tela.soctrfcod attribute (normal)

         open  c_ctb10m10001 using m_tela.soctrfcod
         fetch c_ctb10m10001 into  m_tela.soctrfdes, w_soctip
            if sqlca.sqlcode = 100 then
               error "Tarifa nao cadastrada !"
               next field soctrfcod
            end if

            if w_soctip <> 3 then
               error "Tarifa nao pertence a servicos RE!"
               next field soctrfcod
            end if

         if fgl_lastkey() <> fgl_keyval('up') then
            display m_tela.soctrfdes to soctrfdes
         end if

      before field socntzcod
         let aux = m_tela.socntzcod
         display by name m_tela.socntzcod

      after field socntzcod
         display by name m_tela.socntzcod attribute (normal)
         if fgl_lastkey() = fgl_keyval('up')  then
            let aux = null
            let m_tela.socntzcod = null
            let m_tela.socntzdes = null
            display by name m_tela.*
            next field soctrfcod
         end if

         if m_tela.socntzcod is null and
            fgl_lastkey() <> fgl_keyval('up') then
            if m_opcao <> "C" then
               error "Informar a natureza !"
               next field socntzcod
            else
               let aux = null
            end if
         else
            let m_dntzcod = m_tela.socntzcod
            if m_opcao = "C" then
               let m_flag = "N"
            end if
         end if

         if aux is not null and aux > 0 and m_opcao = 'C' then
            call consulta_navega(1)
            next field socntzcod
         end if

         if m_tela.socntzcod is null and m_opcao = 'C' then
            let m_tela.socntzcod = 0
         end if

         let m_sql = "select soctrfcod, socntzcod from dbsksrvrmeprc  "
                    ," where soctrfcod >= ? "
                    ,"   and socntzcod >= ? "
         if m_opcao = 'C' then
            let m_sql = m_sql clipped
                      , ' and viginc <= "',today using 'dd/mm/yyyy','"'
                      , ' and vigfnl >= "',today using 'dd/mm/yyyy','"'
         end if

         let m_sql = m_sql clipped ," group by 1,2 order by 1,2 "

         prepare p_ctb10m10006 from m_sql
         declare c_ctb10m10006 scroll cursor for p_ctb10m10006

         open c_ctb10m10006 using m_tela.soctrfcod, m_tela.socntzcod

         fetch first c_ctb10m10006 into m_trfcod, m_ntzcod

         if sqlca.sqlcode <> 0 then
            if m_opcao != 'I' then
               error "Nao ha vigencia cadastrada para essa Tarifa/Natureza !"
               let m_tela.socntzcod = null
               let m_tela.socntzdes = null
               next field socntzcod
            else
               let m_trfcod      = m_tela.soctrfcod
               let m_ntzcod      = m_tela.socntzcod
            end if
         else
            if ( m_tela.soctrfcod != m_trfcod or
                 m_tela.socntzcod != m_ntzcod ) and m_opcao = 'I' then
                 let m_trfcod      = m_tela.soctrfcod
                 let m_ntzcod      = m_tela.socntzcod
            end if
         end if

         if m_tela.soctrfcod is not null and
            m_tela.soctrfcod >  0        and
            m_tela.soctrfcod != m_trfcod and
            m_opcao          != "I"      then
            let m_tela.soctrfcod = null
            let m_tela.socntzcod = null
            let m_tela.soctrfdes = null
            let m_tela.socntzdes = null
            let aux              = null
            display by name m_tela.*
            error "Nao ha vigencia cadastrada para essa Tarifa/Natureza !"
            next field soctrfcod
         end if

         if m_tela.socntzcod is not null and
            m_tela.socntzcod >  0        and
            m_tela.socntzcod != m_ntzcod and
            m_opcao          != "I"      then
            let m_tela.soctrfcod = null
            let m_tela.socntzcod = null
            let m_tela.soctrfdes = null
            let m_tela.socntzdes = null
            let aux              = null
            display by name m_tela.*
            error "Nao ha vigencia cadastrada para essa Tarifa/Natureza !"
            next field soctrfcod
         end if

         let m_tela.soctrfcod = m_trfcod
         let m_tela.socntzcod = m_ntzcod

         open  c_ctb10m10002 using m_tela.socntzcod
         fetch c_ctb10m10002 into  m_tela.socntzdes

         if sqlca.sqlcode = 100 then
            if fgl_lastkey() <> fgl_keyval('up') then
               error "Natureza nao cadastrada !"
               let aux = null
               next field socntzcod
            end if
         end if

         call ctb10m10_cadsys(m_tela.soctrfcod,m_tela.socntzcod)
            returning m_tela.nome, m_tela.caddat

         display m_tela.socntzdes to socntzdes

         if fgl_lastkey() <> fgl_keyval('up') then
            display m_tela.nome to nome
            display m_tela.caddat to caddat
         end if

   end input

   if int_flag = true  then
      clear form
      exit while
   end if

   let m_sql = " select unique(socntzcod) ",
               " from dbsksrvrmeprc  ",
               " where soctrfcod = ? ",
               "   and viginc <= 'today' ",
               "   and vigfnl >= 'today' order by 1 "

   prepare p_ctb10m10007 from m_sql
   declare c_ctb10m10007 scroll cursor for p_ctb10m10007

   let m_arr    = 1
   let int_flag = false

   initialize arr_tela to null

   if m_opcao = "S" or
      m_opcao = "I" then
      let m_sql = " select viginc, vigfnl, srvrmevlr, srvrmedifvlr, ",
                  "        srvrmedscmltvlr, mobcmpvlr, cademp, ",
                                 " cadusrtip,cadmat ",
                  " from dbsksrvrmeprc  ",
                  " where soctrfcod = ? ",
                  "   and socntzcod = ? order by 1,2"
   else
      if m_opcao = "C" then
            let m_sql = " select viginc, vigfnl, srvrmevlr, srvrmedifvlr, ",
                               " srvrmedscmltvlr, mobcmpvlr, cademp, ",
                                 " cadusrtip,cadmat ",
                        " from dbsksrvrmeprc  ",
                        " where soctrfcod = ? ",
                        "   and socntzcod = ? ",
                        "   and viginc <= 'today' ",
                        "   and vigfnl >= 'today' order by 1,2"
      end if
   end if
   prepare p_ctb10m10003 from m_sql
   declare c_ctb10m10003 cursor for p_ctb10m10003

   open  c_ctb10m10003  using m_tela.soctrfcod, m_tela.socntzcod

   display m_tela.socntzcod to socntzcod

   foreach c_ctb10m10003 into arr_tela[m_arr].viginc         ,
                              arr_tela[m_arr].vigfnl         ,
                              arr_tela[m_arr].srvrmevlr      ,
                              arr_tela[m_arr].srvrmedifvlr   ,
                              arr_tela[m_arr].srvrmedscmltvlr,
                              arr_tela[m_arr].mobcmpvlr      ,
                              #arr_tela[m_arr].atldat         ,
                              w_cademp , w_usrtip, w_cadmat

      open  c_ctb10m10005 using w_cadmat,
                                w_cademp,
                                w_usrtip
      fetch c_ctb10m10005 into arr_tela[m_arr].funnom
      close c_ctb10m10005

      if m_opcao = 'C' and m_arr < 7 then
         display arr_tela[m_arr].* to s_ctb10m10[m_arr].*
      end if

      let m_arr = m_arr + 1

      if m_arr > 200 then
         message "Numero de linhas ultrapassa o limite !"
         sleep 3
         exit foreach
      end if

   end foreach

   close c_ctb10m10003

   if m_arr   = 1   and
      m_opcao = "C" then
      error "Nao ha vigencia em vigor para essa Tarifa/Natureza !"
      exit while
   end if

   call set_count(m_arr - 1)
   let m_totalarray = m_arr + 1

   if int_flag = true  then
      exit while
   end if

   if m_opcao = "I" or
      m_opcao = "A" then
      call ctb10m10_display_array()
   else
      if m_opcao != 'C' then
         display array arr_tela to s_ctb10m10.*
            on key (interrupt,control-c,esc)
               let m_arr = arr_curr()
               exit display
         end display
      end if
   end if

   if m_opcao != 'C' then
      exit while
   end if

   end while

end function

################################################################################
function ctb10m10_display_array()
#------------------------------------------------------------------------------#

   define l_vigfnl  date

   let m_arr  = 1
   let l_tela = 1

   input array arr_tela without defaults from s_ctb10m10.*

      before row

         let l_tela  = scr_line()
         let m_arr   = arr_curr()

         let l_vigfnl = arr_tela[m_arr].vigfnl

         if arr_tela[m_arr].viginc is not null and
            m_opcao = "I" then
            next field ghost
         end if

      before insert
         let l_tela  = scr_line()
         let m_arr   = arr_curr()

      after insert
         let m_opcao = "I"

      on key (interrupt,control-c,esc)
         let m_arr   = arr_curr()
         exit input

      before field viginc
         if m_opcao = "A" then
            next field vigfnl
         end if
         display arr_tela[m_arr].viginc to
              s_ctb10m10[l_tela].viginc

      after field viginc
         display arr_tela[m_arr].viginc to
              s_ctb10m10[l_tela].viginc attribute (normal)

         if arr_tela[m_arr].viginc is null and
            m_opcao = "I"     then
            error "Informe a vigencia inicial !"
            next field viginc
         end if

         if arr_tela[m_arr].viginc <= today then
            error "Data inicio deve ser maior que data de hoje ! "
            next field viginc
         end if

         select count(*) into m_count from dbsksrvrmeprc
         where soctrfcod = m_tela.soctrfcod
           and socntzcod = m_tela.socntzcod
           and viginc   <= arr_tela[m_arr].viginc
           and vigfnl   >= arr_tela[m_arr].viginc

         if m_count is not null and
            m_count >  0        then
            error " Existe periodo vigente para essa data !"
            next field viginc
         end if

      before field vigfnl
         display arr_tela[m_arr].vigfnl to
              s_ctb10m10[l_tela].vigfnl

      after field vigfnl
         display arr_tela[m_arr].vigfnl to
              s_ctb10m10[l_tela].vigfnl attribute (normal)

         if fgl_lastkey() = fgl_keyval('left') then
            next field viginc
         end if

         if arr_tela[m_arr].vigfnl is null then
            error "Informe a vigencia final !"
            next field vigfnl
         end if

         if arr_tela[m_arr].vigfnl < arr_tela[m_arr].viginc then
            error "Data final deve ser maior que data de inicio ! "
            next field vigfnl
         end if

         if m_opcao = "A" then
            if arr_tela[m_arr].viginc <= today and
               arr_tela[m_arr].vigfnl >= today then
               if arr_tela[m_arr].vigfnl <> l_vigfnl then
                  call ctb10m10_grava()
               end if
               let l_vigfnl = arr_tela[m_arr].vigfnl
               if  m_arr < arr_count() then
                   next field ghost
               else
                   next field vigfnl
               end if
            end if

            let l_vigfnl = arr_tela[m_arr].vigfnl

            if fgl_lastkey() = fgl_keyval('down')     or
               fgl_lastkey() = fgl_keyval('nextpage') then

               if arr_tela[m_arr+1].viginc is null or
                  m_arr = arr_count() then
                  next field vigfnl
               else
                  next field ghost
               end if
            end if
         end if

      before field srvrmevlr
         display arr_tela[m_arr].srvrmevlr to
              s_ctb10m10[l_tela].srvrmevlr attribute (normal)

      after field srvrmevlr
         display arr_tela[m_arr].srvrmevlr to
              s_ctb10m10[l_tela].srvrmevlr attribute (normal)

         if fgl_lastkey() = fgl_keyval('left') then
            next field vigfnl
         end if

         if arr_tela[m_arr].srvrmevlr is null or
            arr_tela[m_arr].srvrmevlr = 0     then
            error "Informe o valor do Servico !"
            next field srvrmevlr
         end if

      before field srvrmedifvlr
         display arr_tela[m_arr].srvrmedifvlr to
              s_ctb10m10[l_tela].srvrmedifvlr attribute (normal)

      after field srvrmedifvlr
         if fgl_lastkey() = fgl_keyval('left') then
            next field srvrmevlr
         end if

         if arr_tela[m_arr].srvrmedifvlr is null then
            error "Informe o valor do Servico diferenciado !"
            next field srvrmedifvlr
         end if

         if arr_tela[m_arr].srvrmedifvlr <> 0 then
            if arr_tela[m_arr].srvrmedifvlr < arr_tela[m_arr].srvrmevlr then
               error "Valor pode ser 0 ou maior que valor do servico !"
               next field srvrmedifvlr
            end if
         end if

      before field srvrmedscmltvlr
         display arr_tela[m_arr].srvrmedscmltvlr to
              s_ctb10m10[l_tela].srvrmedscmltvlr attribute (normal)

      after field srvrmedscmltvlr
         if fgl_lastkey() = fgl_keyval('left') then
            next field srvrmedifvlr
         end if

         if arr_tela[m_arr].srvrmedscmltvlr is null then
            error "Informe o desconto Servico multiplo !"
            next field srvrmedscmltvlr
         end if

      before field mobcmpvlr
          display arr_tela[m_arr].mobcmpvlr to
              s_ctb10m10[l_tela].mobcmpvlr attribute (normal)

      after field mobcmpvlr
         if fgl_lastkey() = fgl_keyval('left') then
            next field srvrmedscmltvlr
         end if

         if arr_tela[m_arr].mobcmpvlr is null then
            error "Informe o complemento de mao de obra !"
            next field mobcmpvlr
         end if

         call ctb10m10_grava()

         if fgl_lastkey() = fgl_keyval('return')  or
            fgl_lastkey() = fgl_keyval('down')    then

            if m_opcao = "A" and
               arr_tela[m_arr+1].viginc is null then
               next field vigfnl
            end if

            next field ghost
         end if

   end input

end function

################################################################################
function ctb10m10_grava()
#------------------------------------------------------------------------------#

      if m_opcao = "I" then
         execute p_ctb10m10004 using m_tela.soctrfcod               ,
                                     m_tela.socntzcod               ,
                                     arr_tela[m_arr].viginc         ,
                                     arr_tela[m_arr].vigfnl         ,
                                     arr_tela[m_arr].srvrmevlr      ,
                                     arr_tela[m_arr].srvrmedifvlr   ,
                                     arr_tela[m_arr].srvrmedscmltvlr,
                                     "today"                        ,
                                     g_issk.empcod                  ,
                                     g_issk.funmat                  ,
                                     g_issk.usrtip                  ,
                                     "today"                        ,
                                     g_issk.empcod                  ,
                                     g_issk.funmat                  ,
                                     g_issk.usrtip                  ,
                                     arr_tela[m_arr].mobcmpvlr

         open  c_ctb10m10005 using g_issk.funmat,
                                   g_issk.empcod,
                                   g_issk.usrtip
         fetch c_ctb10m10005 into  arr_tela[m_arr].funnom
         close c_ctb10m10005

         let w_atldat = today

         display arr_tela[m_arr].funnom to
              s_ctb10m10[l_tela].funnom
         #display w_atldat to
              #s_ctb10m10[l_tela].atldat
      else
         if m_opcao = "A"  and
            arr_tela[m_arr].viginc > today then
            update dbsksrvrmeprc
               set viginc          = arr_tela[m_arr].viginc         ,
                   vigfnl          = arr_tela[m_arr].vigfnl         ,
                   srvrmevlr       = arr_tela[m_arr].srvrmevlr      ,
                   srvrmedifvlr    = arr_tela[m_arr].srvrmedifvlr   ,
                   srvrmedscmltvlr = arr_tela[m_arr].srvrmedscmltvlr,
                   mobcmpvlr       = arr_tela[m_arr].mobcmpvlr      ,
                   atldat          = w_atldat
             where soctrfcod       = m_tela.soctrfcod
               and socntzcod       = m_tela.socntzcod
               and viginc          = arr_tela[m_arr].viginc
         else
            update dbsksrvrmeprc
               set vigfnl          = arr_tela[m_arr].vigfnl
             where soctrfcod       = m_tela.soctrfcod
               and socntzcod       = m_tela.socntzcod
               and viginc          = arr_tela[m_arr].viginc
         end if

         open  c_ctb10m10005 using g_issk.funmat,
                                   g_issk.empcod,
                                   g_issk.usrtip
         fetch c_ctb10m10005 into  arr_tela[m_arr].funnom
         close c_ctb10m10005

         let w_atldat = today

         display arr_tela[m_arr].funnom to
              s_ctb10m10[l_tela].funnom
         #display arr_tela[m_arr].atldat to
              #s_ctb10m10[l_tela].atldat
      end if

end function

################################################################################
function ctb10m10_navega(pos)
#------------------------------------------------------------------------------#
define i smallint, pos smallint

    initialize arr_tela to null

    let int_flag = false
    let m_arr    = 1

    fetch relative pos c_ctb10m10006 into m_tela.soctrfcod,
                                          m_tela.socntzcod

    if sqlca.sqlcode <> 0 then
       error "Nao ha mais registros nesta direcao !"
       return
    end if

    call ctb10m10_cadsys(m_tela.soctrfcod,m_tela.socntzcod)
       returning m_tela.nome, m_tela.caddat

    clear form

    open  c_ctb10m10001 using m_tela.soctrfcod
    fetch c_ctb10m10001 into  m_tela.soctrfdes, w_soctip

    open  c_ctb10m10002 using m_tela.socntzcod
    fetch c_ctb10m10002 into  m_tela.socntzdes

    display by name m_tela.*

    open  c_ctb10m10003  using m_tela.soctrfcod,
                               m_tela.socntzcod
    foreach c_ctb10m10003 into arr_tela[m_arr].viginc         ,
                               arr_tela[m_arr].vigfnl         ,
                               arr_tela[m_arr].srvrmevlr      ,
                               arr_tela[m_arr].srvrmedifvlr   ,
                               arr_tela[m_arr].srvrmedscmltvlr,
                               arr_tela[m_arr].mobcmpvlr      ,
                               #arr_tela[m_arr].atldat         ,
                              w_cademp , w_usrtip, w_cadmat

         open  c_ctb10m10005 using w_cadmat,
                                   w_cademp,
                                   w_usrtip

         fetch c_ctb10m10005 into  arr_tela[m_arr].funnom
         close c_ctb10m10005

         if m_arr < 7 then
            display arr_tela[m_arr].* to s_ctb10m10[m_arr].*
         end if

         let m_arr = m_arr + 1

    end foreach

end function

################################################################################
function consulta_navega(pos)
#------------------------------------------------------------------------------#
define i smallint, pos smallint
define l_count smallint

    initialize arr_tela to null

    let int_flag = false
    let m_arr    = 1

    fetch relative pos c_ctb10m10006 into m_trfcod, m_ntzcod

    if sqlca.sqlcode <> 0 then
       error "Nao ha mais registros nesta direcao !"
       return
    end if

    let m_tela.soctrfcod = m_trfcod
    let m_tela.socntzcod = m_ntzcod

    clear form

    open  c_ctb10m10001 using m_tela.soctrfcod
    fetch c_ctb10m10001 into  m_tela.soctrfdes, w_soctip

    open  c_ctb10m10002 using m_tela.socntzcod
    fetch c_ctb10m10002 into  m_tela.socntzdes

    call ctb10m10_cadsys(m_tela.soctrfcod,m_tela.socntzcod)
       returning m_tela.nome, m_tela.caddat

    display by name m_tela.*

    open  c_ctb10m10003  using m_tela.soctrfcod,
                               m_tela.socntzcod
    foreach c_ctb10m10003 into arr_tela[m_arr].viginc         ,
                               arr_tela[m_arr].vigfnl         ,
                               arr_tela[m_arr].srvrmevlr      ,
                               arr_tela[m_arr].srvrmedifvlr   ,
                               arr_tela[m_arr].srvrmedscmltvlr,
                               arr_tela[m_arr].mobcmpvlr      ,
                               #arr_tela[m_arr].atldat         ,
                               w_cademp , w_usrtip, w_cadmat

         if arr_tela[m_arr].viginc is null then
            continue foreach
         end if

         open  c_ctb10m10005 using w_cadmat,
                                   w_cademp,
                                   w_usrtip
         fetch c_ctb10m10005 into  arr_tela[m_arr].funnom
         close c_ctb10m10005

         if m_arr < 7 then
            display arr_tela[m_arr].* to s_ctb10m10[m_arr].*
         end if

         let m_arr = m_arr + 1

    end foreach

end function

################################################################################
function ctb10m10_remove()
#------------------------------------------------------------------------------#
define l_resp char(1)

      while true
         prompt "CONFIRMA REMOCAO DA LINHA CORRENTE(S/N) " for l_resp
         if l_resp matches "[sSnN]" then
              exit while
         end if
      end while

      if l_resp = "S" or l_resp = "s"  then

         if arr_tela[m_arr].viginc > today then
            begin work
            delete from dbsksrvrmeprc
               where soctrfcod = m_tela.soctrfcod
                 and socntzcod = m_tela.socntzcod
                 and viginc    = arr_tela[m_arr].viginc

            if sqlca.sqlcode < 0  then
               error  " Erro na remocao !!! "
               rollback work
               sleep 1
               clear form
               return
            end if

            commit work

            message  " Dados excluidos com sucesso!!! "
            sleep 2
            clear form
            initialize arr_tela to null
            message ""
         else
            error "Registro esta em vigor !"
            return
         end if
      else
         message  " Nao houve remocao !!! "
         sleep 2
         clear form
         initialize arr_tela to null
         message ""
      end if

end function # remove

################################################################################
function ctb10m10_cadsys(l_trfcod,l_ntzcod)
#------------------------------------------------------------------------------#
define l_trfcod like dbsksrvrmeprc.soctrfcod,
       l_ntzcod like dbsksrvrmeprc.socntzcod,
       l_rowid  integer,
       l_funmat like dbsksrvrmeprc.cadmat,
       l_empcod like dbsksrvrmeprc.cademp,
       l_usrtip like dbsksrvrmeprc.cadusrtip,
       l_funnom like isskfunc.funnom,
       l_caddat date

   let l_rowid = null

   select min(rowid) into l_rowid
     from dbsksrvrmeprc
    where soctrfcod = l_trfcod
      and socntzcod = l_ntzcod

   if l_rowid is not null then

      select cadmat, cademp, cadusrtip, caddat
        into l_funmat, l_empcod, l_usrtip, l_caddat
        from dbsksrvrmeprc
       where rowid = l_rowid

      open c_ctb10m10005 using l_funmat, l_empcod, l_usrtip

      fetch c_ctb10m10005 into l_funnom

   else
      let l_caddat = today
      let l_funnom = null
   end if

   return l_funnom, l_caddat

end function
