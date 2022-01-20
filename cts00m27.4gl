###############################################################################
# Nome do Modulo: cts00m27                                           Marcus   #
#                                                                    Ruiz     #
# Tela de Acompanhamento Servicos Internet                           Ago/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define l_fim smallint

#-----------------------------------------------------------
 function cts00m27()
#-----------------------------------------------------------

 define d_cts00m27  record
    atdetpcod       like datksrvintetp.atdetpcod,
    atdetpdes       like datksrvintetp.atdetpdes,
    perini          date,
    perter          date,
    atdsrvorg       like datksrvtip.atdsrvorg,
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    total           dec  (4,0)
 end record

 define a_cts00m27  array[2000] of record
    servico         char (13),
    caddat          like datmsrvint.caddat  ,
    cadhor          datetime hour to minute ,
    espera          char (06)               ,
    pstcoddig       like dpaksocor.pstcoddig,
    nomgrr          like dpaksocor.nomgrr   ,
    atdetpcod       like datksrvintetp.atdetpcod,
    atdetpdes       like datksrvintetp.atdetpdes,
    etpmtvcod       like datksrvintmtv.etpmtvcod,
    etpmtvdes       like datksrvintmtv.etpmtvdes,
    srvobs          like datmsrvint.srvobs
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define ws          record
    sql             char (800),
    atdsrvorg       like datksrvtip.atdsrvorg,
    atdetpcod       like datketapa.atdetpcod,
    atdetpseq       like datmsrvint.atdetpseq,
    pstcoddig       like dpaksocor.pstcoddig,
    atdsrvnum       dec (10,0)              ,
    atdsrvano       dec (02,0)              ,
    retflg          smallint                ,
    etpmtvcod       like datksrvintmtv.etpmtvcod,
    etpmtvdes       like datksrvintmtv.etpmtvdes,
    srvobs          like datmsrvint.srvobs,
    sqlcode         smallint
 end record

----------------[ inicio ]-----------------------------

	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  2000
		initialize  a_cts00m27[w_pf1].*  to  null
	end	for

	initialize  d_cts00m27.*  to  null

	initialize  ws.*  to  null

 open window w_cts00m27 at 04,02 with form "cts00m27"
                        attribute(form line first)

 while true
   clear form
   initialize a_cts00m27     to null
   initialize d_cts00m27.*   to null
   initialize ws.*           to null
   let int_flag = false
   let arr_aux  = 1
   let d_cts00m27.perini = today
   let d_cts00m27.perter = today

   input by name d_cts00m27.atdetpcod,
                 d_cts00m27.atdsrvnum,
                 d_cts00m27.atdsrvano,
                 d_cts00m27.perini,
                 d_cts00m27.perter without defaults

       before field atdetpcod
          display  by name d_cts00m27.atdetpcod attribute (reverse)

       after field atdetpcod
          display by name d_cts00m27.atdetpcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdetpcod
          end if
          if d_cts00m27.atdetpcod is null then
             next field atdsrvnum
          else
             select atdetpdes
                into d_cts00m27.atdetpdes
                from datksrvintetp
               where atdetpcod = d_cts00m27.atdetpcod
          end if

       before field atdsrvnum
         display by name d_cts00m27.atdsrvnum  attribute (reverse)

       after  field atdsrvnum
         display by name d_cts00m27.atdsrvnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdetpcod
         end if

         if d_cts00m27.atdsrvnum is null    then
            next field atdsrvano
         end if

      before field atdsrvano
         display by name d_cts00m27.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name d_cts00m27.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if d_cts00m27.atdsrvano   is null      and
            d_cts00m27.atdsrvnum   is not null  then
            error " Informe o ano do servico!"
            next field atdsrvano
         end if

         if d_cts00m27.atdsrvano   is not null   and
            d_cts00m27.atdsrvnum   is null       then
            error " Informe o numero do servico!"
            next field atdsrvnum
         end if
         select atdsrvorg
           into d_cts00m27.atdsrvorg
           from datmservico
          where atdsrvnum = d_cts00m27.atdsrvnum  and
                atdsrvano = d_cts00m27.atdsrvano

         display "-" at 02,45
         display "/" at 02,53
         display by name d_cts00m27.atdsrvorg

         if d_cts00m27.atdsrvnum  is not null   and
            d_cts00m27.atdsrvano  is not null   then
            exit input
         end if

       before field perini
          display  by name d_cts00m27.perini attribute (reverse)

       after field perini
          display by name d_cts00m27.perini

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdetpcod
          end if
          if d_cts00m27.perini is null then
             next field atdsrvnum
          end if

       before field perter
          display  by name d_cts00m27.perter attribute (reverse)

       after field perter
          display by name d_cts00m27.perter

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field perini
          end if
          if d_cts00m27.perter is null then
             next field perini
          end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   display by name d_cts00m27.*

   if d_cts00m27.atdetpcod is not null then
      let ws.sql = "select datmsrvintseqult.atdsrvnum ,",
                   "       datmsrvintseqult.atdsrvano ,",
                   "       datmsrvintseqult.atdetpseq ,",
                   "       datmsrvintseqult.atdetpcod  ",
                   "  from datmsrvintseqult, datmsrvint ",
                   " where datmsrvintseqult.atdetpcod = ?",
                   "   and datmsrvint.caddat >= ? ",
                   "   and datmsrvint.caddat <= ? ",
                   "   and datmsrvintseqult.atdsrvnum = datmsrvint.atdsrvnum",
                   "   and datmsrvintseqult.atdsrvano = datmsrvint.atdsrvano",
                   "   and datmsrvintseqult.atdetpseq = datmsrvint.atdetpseq"
   else
     if d_cts00m27.atdsrvnum is not null then
        let ws.sql = "select atdsrvnum ,",
                     "       atdsrvano ,",
                     "       atdetpseq ,",
                     "       atdetpcod  ",
                     "  from datmsrvintseqult ",
                     " where atdsrvnum = ?",
                     "   and atdsrvano = ?"
     end if
   end if
   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare p_cts00m27_001  from ws.sql
   declare c_cts00m27_001 cursor for p_cts00m27_001

   if d_cts00m27.atdetpcod is not null then
      open c_cts00m27_001 using d_cts00m27.atdetpcod,
                            d_cts00m27.perini,
                            d_cts00m27.perter
   else
      if d_cts00m27.atdsrvnum is not null then
         open c_cts00m27_001 using d_cts00m27.atdsrvnum,
                               d_cts00m27.atdsrvano
      end if
   end if
   foreach c_cts00m27_001 into ws.atdsrvnum,
                           ws.atdsrvano,
                           ws.atdetpseq,
                           ws.atdetpcod
       let d_cts00m27.atdetpcod          = ws.atdetpcod
       let a_cts00m27[arr_aux].atdetpcod = ws.atdetpcod
       select caddat,
              cadhor,
              pstcoddig,
              etpmtvcod,
              srvobs
         into a_cts00m27[arr_aux].caddat,
              a_cts00m27[arr_aux].cadhor,
              a_cts00m27[arr_aux].pstcoddig,
              a_cts00m27[arr_aux].etpmtvcod,
              a_cts00m27[arr_aux].srvobs
         from datmsrvint
        where atdsrvnum = ws.atdsrvnum
          and atdsrvano = ws.atdsrvano
          and atdetpseq = ws.atdetpseq

         select atdsrvorg
           into ws.atdsrvorg
           from datmservico
          where atdsrvnum = ws.atdsrvnum  and
                atdsrvano = ws.atdsrvano

         let a_cts00m27[arr_aux].servico =
                         ws.atdsrvorg using "&&", "/",
                         ws.atdsrvnum using "&&&&&&&", "-",
                         ws.atdsrvano using "&&"

         call cts00m27_espera (a_cts00m27[arr_aux].caddat,
                               a_cts00m27[arr_aux].cadhor)
              returning a_cts00m27[arr_aux].espera

         select nomgrr
           into a_cts00m27[arr_aux].nomgrr
           from dpaksocor
          where pstcoddig = a_cts00m27[arr_aux].pstcoddig

         select atdetpdes
           into a_cts00m27[arr_aux].atdetpdes
           from datksrvintetp
          where atdetpcod = a_cts00m27[arr_aux].atdetpcod

         select etpmtvdes
           into a_cts00m27[arr_aux].etpmtvdes
           from datksrvintmtv
          where etpmtvcod = a_cts00m27[arr_aux].etpmtvcod

         let arr_aux = arr_aux + 1
         if arr_aux > 2000 then
            error " Limite excedido. Acompanhamento possui mais de 2000",
                  " servicos na Internet!"
            exit foreach
         end if

   end foreach

   if arr_aux > 1  then
      let d_cts00m27.total = arr_aux - 1 using "&&&&"
      display by name d_cts00m27.total

      if d_cts00m27.atdetpcod = 2  or     # recusado
         d_cts00m27.atdetpcod = 3  or     # cancelado
         d_cts00m27.atdetpcod = 4  then   # tempo excedido

         message " (F5)Desconclui, (F8)Seleciona, (F9)Complemento "
      else
         message " (F5)Cancela, (F8)Seleciona, (F9)Complemento "
      end if

      call set_count(arr_aux-1)
      display array a_cts00m27 to s_cts00m27.*
         on key(interrupt, control-c)
            exit display

         on key (F5)
            let arr_aux       =  arr_curr()
            let scr_aux       =  scr_line()
            let ws.atdsrvnum  =  a_cts00m27[arr_aux].servico[04,10]
            let ws.atdsrvano  =  a_cts00m27[arr_aux].servico[12,13]
            if d_cts00m27.atdetpcod = 2  or
               d_cts00m27.atdetpcod = 3  or
               d_cts00m27.atdetpcod = 4  then
               let g_documento.atdsrvnum = ws.atdsrvnum
               let g_documento.atdsrvano = ws.atdsrvano
               call cts10g04_insere_etapa (ws.atdsrvnum,
                                           ws.atdsrvano,
                                           5,"","","","")
                      returning ws.sqlcode
               display a_cts00m27[arr_aux].servico  to
                       s_cts00m27[scr_aux].servico  attribute(reverse)

               call cts04g00('cts00m27') returning ws.retflg

               display a_cts00m27[arr_aux].servico  to
                       s_cts00m27[scr_aux].servico
               exit display
            end if
            select atdetpcod
                 into ws.atdetpcod
                 from datmsrvintseqult
                where atdsrvnum = ws.atdsrvnum
                  and atdsrvano = ws.atdsrvano
            if ws.atdetpcod  =  3  then
               error "servico ja esta cancelado"
               exit display
            end if

            call cts00m28() returning ws.etpmtvcod,  # pop_up motivos
                                      ws.etpmtvdes
            if ws.etpmtvcod is not null then
               call cts00m27_mtvcanc() returning ws.srvobs
               let ws.atdetpseq = null
               select max (atdetpseq)
                   into ws.atdetpseq
                   from datmsrvint
                  where atdsrvnum = ws.atdsrvnum
                    and atdsrvano = ws.atdsrvano

               if ws.atdetpseq is null then
                  let ws.atdetpseq = 0
               end if
               let ws.atdetpseq  =  ws.atdetpseq + 1

               begin work
               insert into datmsrvint (atdsrvnum,
                                       atdsrvano,
                                       atdetpseq,
                                       atdetpcod,
                                       cadorg   ,
                                       pstcoddig,
                                       cademp   ,
                                       cadusrtip,
                                       cadmat   ,
                                       caddat   ,
                                       cadhor   ,
                                       etpmtvcod,
                                       srvobs   ,
                                       atlemp   ,
                                       atlmat   ,
                                       atlusrtip,
                                       atldat   ,
                                       atlhor)
                              values  (ws.atdsrvnum,
                                       ws.atdsrvano,
                                       ws.atdetpseq,
                                       3,             # etapa de cancelamento
                                       "0",           # origem porto
                                       a_cts00m27[arr_aux].pstcoddig,
                                       g_issk.empcod,
                                       g_issk.usrtip,
                                       g_issk.funmat,
                                       today,
                                       current hour to second,
                                       ws.etpmtvcod,
                                       ws.srvobs, "","","","","" )
               if sqlca.sqlcode <> 0 then
                  error "Erro (",sqlca.sqlcode, ") na desconclusao do servico.",
                        "AVISE A INFORMATICA!"
                   rollback work
                   exit display
               end if
               update datmsrvintseqult
                   set (atdetpcod,
                        atdetpseq)
                     = (3,
                        ws.atdetpseq) # atualiza ultima seq. do servico
                   where atdsrvnum = ws.atdsrvnum
                     and atdsrvano = ws.atdsrvano
               if sqlca.sqlcode <> 0 then
                  error "Erro (",sqlca.sqlcode, ") na desconclusao do servico.",
                        "AVISE A INFORMATICA! - upd"
                   rollback work
                   exit display
               end if
               commit work
            end if

         on key (F8)
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            let g_documento.atdsrvnum = a_cts00m27[arr_aux].servico[04,10]
            let g_documento.atdsrvano = a_cts00m27[arr_aux].servico[12,13]

            display a_cts00m27[arr_aux].servico  to
                    s_cts00m27[scr_aux].servico  attribute(reverse)

            call cts04g00('cts00m27') returning ws.retflg

            display a_cts00m27[arr_aux].servico  to
                    s_cts00m27[scr_aux].servico

         on key (F9)
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            let ws.atdsrvnum  =  a_cts00m27[arr_aux].servico[04,10]
            let ws.atdsrvano  =  a_cts00m27[arr_aux].servico[12,13]
            call cts00m30(ws.atdsrvnum,ws.atdsrvano)

      end display
   else
      error " Nao existem etapas cadastradas para este servico!"
   end if
 end while

 let int_flag = false
 close window w_cts00m27

end function  ###  cts00m27

#-----------------------------------------------------------------------------
 function cts00m27_espera(param)
#-----------------------------------------------------------------------------
    define param   record
       caddat      like datmsrvint.caddat,
       cadhor      like datmsrvint.cadhor
    end record

    define hora        record
       atual           datetime hour to second,
       h24             datetime hour to second,
       espera          char (09)
    end record



	initialize  hora.*  to  null

    initialize hora.*  to null
    let hora.atual = time

    if param.caddat = today  then
       let hora.espera = hora.atual - param.cadhor
    else
       let hora.h24    = "23:59:59"
       let hora.espera = hora.h24 - param.cadhor
       let hora.h24    = "00:00:00"
       let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
    end if

    return hora.espera

 end function   ###--- cts00m27_espera

#------------------------------------------------------------------------------
 function cts00m27_mtvcanc()
#------------------------------------------------------------------------------

   define cts00m29 record
        srvobs     like datmsrvint.srvobs
   end record



	initialize  cts00m29.*  to  null

   open window cts00m29 at 09,10 with form "cts00m29"
                   attribute(border)

   input by name cts00m29.srvobs

      before field srvobs
         call cts00m29_wrap('I',cts00m29.srvobs)
              returning l_fim,cts00m29.srvobs

         if l_fim != 1 then
            exit input
         end if

         clear srvobs[1]
         clear srvobs[2]

         call cts00m29_wrap('C',cts00m29.srvobs)
              returning l_fim,cts00m29.srvobs
              exit input

         on key (interrupt)
           exit input

   end input
   let int_flag = false
   close window cts00m29
   return cts00m29.srvobs

 end function   #  cts00m27_mtvcanc
#-----------------------------------------------------------------------------
function cts00m29_wrap(l_tipo, l_texto)
#-----------------------------------------------------------------------------

     define

     l_tipo                  char (001),
     l_texto                 char(100),
     l_fimtxt                smallint,
     l_incpos                integer,
     l_string                char (50),
     l_null                  char (001),
     l_i                     smallint



	let	l_fimtxt  =  null
	let	l_incpos  =  null
	let	l_string  =  null
	let	l_null  =  null
	let	l_i  =  null

     if   l_tipo = 'C' then
          let  l_incpos = 01
          let  l_fimtxt = false
          let  l_string = " "
          let  l_i      = 01

          while l_fimtxt = false
               call     figrc001_wraptxt_jst
                      ( l_texto                   # Texto
                      , 50
                      , l_incpos
                      , ascii(10)
                      , 002
                      , 00
                      , "" , "" , "" , "" )
              returning l_fimtxt
                      , l_string
                      , l_incpos
                      , l_null , l_null

              display l_string to srvobs[l_i]

              let  l_i = l_i + 01

              if   l_i > 02
              then
                   exit while
              end  if
          end  while
     end  if

     if   l_tipo = "I" then
          call      figrc002_wraptxt_var      # PARAMETROS ENVIADOS:
                  ( 15                        #  1. Linha   de inicio do txt
                  , 11                        #  2. Coluna  de inicio do txt
                  , 02                        #  3. Linhas  na tela
                  , 50                        #  4. Colunas na tela
                  , "N"                       #  5. Flag exibir NomeTexto e
                                              #     Situacao
                  , "NN"                      #  6. Flag exibir Cab./Regua
                  , "N"                       #  7. Opcao de acentuacao
                  , 050                       #  8. Tamanho max. da linha
                  , 002                       #  9. Tamanho max. do texto
                  , 001                       # 10. Tamanho scroll
                  , ASCII(10)                 # 11. Caracter de Fim de Linha
                  , l_texto                   # 12. Texto Separado pelo #11
                  , " "                       # 13. Cabecalho do texto
                  , ""                        # 14. Cabecalho Identificacao de
                                              #     colunas.
                  , "S"                       # 15. Flag.Edicao Automatica
                                              #     S-im / N-ao / B-loqueio
                  , 002                       # 16. Flag.Maiusculo/Minusculo
                  , ""                        # 17. Sequencia de Caracteres
                                              #     NAO computados
                  , " "                       # 18. Empresa do Funcionario
                  , " "                       # 19. Matricula Ult. Alteracao
                  , today                     # 20. Data da Ultima Alteracao
                  , " "                       # 21. Tipo de usuario
                  , "N"                       # 22. Exibir Borda (S/N)
                  , "N"                       # 23. Manter window aberta
                  , "S"                       # 24. NAO Utilizado
                  , " "                       # 25. NAO Utilizado
                  , " "                       # 26. NAO Utilizado
                  , " "                       # 27. NAO Utilizado
                  , " "                       # 28. NAO Utilizado
                  , " "                       # 29. NAO Utilizado
                  , " " )                     # 30. NAO Utilizado
          returning l_fimtxt
                  , l_texto

          if   l_fimtxt =  false
          then
               error "CANCELADO !"
               sleep 01
          end  if
     end  if

     return l_fimtxt, l_texto

end function #-->
#-----------------------------------------------------   fim.
