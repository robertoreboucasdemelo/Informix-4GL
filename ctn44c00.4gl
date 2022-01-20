 ##############################################################################
 # Nome do Modulo: ctn44c00                                          Marcelo  #
 #                                                                   Gilberto #
 # Consulta mensagens recebidas dos MDT's                            Ago/1999 #
 #----------------------------------------------------------------------------#
 # 17/01/2001   Marcus   PSI 12338-2   Numero de transmissao msgs MDTs        #
 # 05/05/2009   Adriano  PSI 240540    Funcao para calcular distancia entre as#
 #                                     msgs e coluna de distancia entre sinais#
 ##############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctn44c00(param)
#------------------------------------------------------------

 define param        record
    opentip          smallint,
    atdvclsgl        like datkveiculo.atdvclsgl,
    mdtmvttipcod     like datmmdtmvt.mdtmvttipcod
 end record

 define a_ctn44c00   array[2000]   of record
    mdtmvtseq        like datmmdtmvt.mdtmvtseq,
    mdttrxnum        like datmmdtmvt.mdttrxnum,
    cadhor           like datmmdtmvt.cadhor,
    mdtcod           like datmmdtmvt.mdtcod,
    mdtmvttipdes     char (15),
    mdtmvtsttdes     char (30),
    flag             char (2),
    dist             decimal (7,0)
 end record

 define a_ctn44c00a  array[2000]   of record
    mdterrdes        char (45)
 end record

 define d_ctn44c00    record
    caddatpsq        like datmmdtmvt.caddat,
    atdvclsgl        like datkveiculo.atdvclsgl,
    mdtmvttipcod     like datmmdtmvt.mdtmvttipcod,
    mdtmvtstt        like datmmdtmvt.mdtmvtstt
 end record

 define ws            record
    mdtcod            like datmmdtmvt.mdtcod,
    mdtmvttipcod      like datmmdtmvt.mdtmvttipcod,
    mdtmvtseqsva      like datmmdtmvt.mdtmvtseq,
    mdtmvtstt         like datmmdtmvt.mdtmvtstt,
    mdterrcod         like datmmdterr.mdterrcod,
    mdtbotprgseq      like datmmdtmvt.mdtbotprgseq,
    cponom            like iddkdominio.cponom,
    comando           char (2000),
    condicao          char (620),
    total             char (11),
    funmat            like datmmdtmvt.funmat,
    lclltt            like datmmdtmvt.lclltt,
    lcllgt            like datmmdtmvt.lcllgt
 end record

 define ws_ant        record
    mdtcod            like datmmdtmvt.mdtcod,
    lclltt            like datmmdtmvt.lclltt,
    lcllgt            like datmmdtmvt.lcllgt,
    dist              decimal (7,0)
 end record
 define arr_aux       smallint
 define scr_aux       smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  2000
		initialize  a_ctn44c00[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  2000
		initialize  a_ctn44c00a[w_pf1].*  to  null
	end	for

	initialize  d_ctn44c00.*  to  null

	initialize  ws.*  to  null

 initialize d_ctn44c00.*  to null

 if param.opentip  =  2  then
    open window w_limpa    at  04,02 with 20 rows, 78 columns
    display "CONSULTA MENSAGENS RECEBIDAS DOS MDTs" at 02,20
 end if

 #-----------------------------------------------------------------------
 # Prepara comandos SQL
 #-----------------------------------------------------------------------
 let ws.comando = "select cpodes ",
                  "  from iddkdominio",
                  " where cponom = ? ",
                  "   and cpocod = ? "
 prepare sel_iddkdominio from ws.comando
 declare c_iddkdominio cursor for sel_iddkdominio

 let ws.comando = "select mdterrcod ",
                  "  from datmmdterr",
                  " where mdtmvtseq = ? "
 prepare sel_datmmdterr from ws.comando
 declare c_datmmdterr cursor for sel_datmmdterr

 let ws.comando = "select mdtbottxt",
                  "  from datkmdt, datrmdtbotprg, datkmdtbot",
                  " where datkmdt.mdtcod = ?",
                  "   and datrmdtbotprg.mdtprgcod    =  datkmdt.mdtprgcod",
                  "   and datrmdtbotprg.mdtbotprgseq = ?",
                  "   and datkmdtbot.mdtbotcod = datrmdtbotprg.mdtbotcod"
 prepare sel_datrmdtbotprg from       ws.comando
 declare c_datrmdtbotprg   cursor for sel_datrmdtbotprg


 open window w_ctn44c00 at  06,02 with form "ctn44c00"
             attribute(form line first, comment line last - 1)

 let d_ctn44c00.atdvclsgl      =  param.atdvclsgl
 let d_ctn44c00.mdtmvttipcod   =  param.mdtmvttipcod

 while true

   initialize ws.*         to null
   initialize ws_ant.*     to null
   initialize a_ctn44c00   to null
   initialize a_ctn44c00a  to null
   let int_flag   = false
   let arr_aux    = 1

   input by name d_ctn44c00.*  without defaults

      before field caddatpsq
         display by name d_ctn44c00.caddatpsq    attribute (reverse)

         let d_ctn44c00.caddatpsq = today

      after  field caddatpsq
         display by name d_ctn44c00.caddatpsq

         if d_ctn44c00.caddatpsq  is null   then
            error " Data da transmissao da mensagem deve ser informada!"
            next field caddatpsq
         end if

      before field atdvclsgl
         display by name d_ctn44c00.atdvclsgl  attribute (reverse)

      after  field atdvclsgl
         display by name d_ctn44c00.atdvclsgl

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_ctn44c00.atdvclsgl  to null
            display by name d_ctn44c00.atdvclsgl
            next field caddatpsq
         end if

         initialize ws.mdtcod  to null

         if d_ctn44c00.atdvclsgl is not null   then
            select mdtcod
              into ws.mdtcod
              from datkveiculo
             where atdvclsgl  =  d_ctn44c00.atdvclsgl

             if sqlca.sqlcode  =  notfound   then
                error " Veiculo nao cadastrado!"
                next field atdvclsgl
             end if
         end if

      before field mdtmvttipcod
         display by name d_ctn44c00.mdtmvttipcod attribute (reverse)

      after  field mdtmvttipcod
         display by name d_ctn44c00.mdtmvttipcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_ctn44c00.mdtmvttipcod  to null
            display by name d_ctn44c00.mdtmvttipcod
            next field atdvclsgl
         end if

         if d_ctn44c00.atdvclsgl     is null   and
            d_ctn44c00.mdtmvttipcod  is null   then
            error " Veiculo ou tipo do movimento deve ser informado!"
            next field mdtmvttipcod
         end if

         if d_ctn44c00.mdtmvttipcod  is not null   then
            select cpodes
              from iddkdominio
             where cponom  =  "mdtmvttipcod"
               and cpocod  =  d_ctn44c00.mdtmvttipcod

            if sqlca.sqlcode  =  notfound   then
               error " Tipo do movimento nao cadastrado!"
               call ctn36c00("Tipo do movimento MDT", "mdtmvttipcod")
                    returning  d_ctn44c00.mdtmvttipcod
               next field mdtmvttipcod
            end if
         end if

      before field mdtmvtstt
         display by name d_ctn44c00.mdtmvtstt attribute (reverse)

      after  field mdtmvtstt
         display by name d_ctn44c00.mdtmvtstt

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_ctn44c00.mdtmvtstt  to null
            display by name d_ctn44c00.mdtmvtstt
            next field mdtmvttipcod
         end if

         if d_ctn44c00.mdtmvtstt  is not null   then
            select cpodes
              from iddkdominio
             where cponom  =  "mdtmvtstt"
               and cpocod  =  d_ctn44c00.mdtmvtstt

            if sqlca.sqlcode  =  notfound   then
               error " Situacao do movimento nao cadastrada!"
               call ctn36c00("Situacao do movimento MDT", "mdtmvtstt")
                    returning  d_ctn44c00.mdtmvtstt
               next field mdtmvtstt
            end if
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   #-----------------------------------------------------------------------
   # Consulta movimento conforme parametro informado
   #-----------------------------------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)

   if d_ctn44c00.atdvclsgl  is not null   then
      if d_ctn44c00.mdtmvttipcod  is null   then
         let ws.condicao = "  from datmmdtmvt",
                           " where caddat =  ? ",
                           "   and mdtcod =  ? ",
                           " order by mdtmvtseq desc"
      else
         let ws.condicao = "  from datmmdtmvt",
                           " where caddat =  ? ",
                           "   and mdtcod =  ? ",
                           "   and mdtmvttipcod =  ? ",
                           " order by mdtmvtseq desc"
      end if
   else
      if d_ctn44c00.mdtmvttipcod  is not null   then
         let ws.condicao = "  from datmmdtmvt",
                           " where caddat    =  ? ",
                           "   and mdtmvttipcod =  ? ",
                           " order by mdtmvtseq desc"
      else
         if d_ctn44c00.mdtmvtstt  is not null   then
            let ws.condicao = "  from datmmdtmvt",
                              " where caddat    =  ? ",
                              "   and mdtmvtstt =  ? ",
                              " order by mdtmvtseq desc"
         else
            let ws.condicao = "  from datmmdtmvt",
                              " where caddat    =  ? ",
                              " order by mdtmvtseq desc"
         end if
     end if
   end if

   let ws.comando = " select mdtmvtseq, mdttrxnum       , cadhor  ,",
                    "        mdtcod   , mdtmvttipcod, mdtmvtstt,",
                    "        mdtbotprgseq, funmat, lclltt, lcllgt ",
                    ws.condicao clipped

   prepare sql_select from ws.comando
   declare c_ctn44c00 cursor for sql_select

   if d_ctn44c00.atdvclsgl  is not null   then
      if d_ctn44c00.mdtmvttipcod  is null   then
         open c_ctn44c00  using d_ctn44c00.caddatpsq, ws.mdtcod
      else
         open c_ctn44c00  using d_ctn44c00.caddatpsq,
                                ws.mdtcod,
                                d_ctn44c00.mdtmvttipcod
      end if
   else
      if d_ctn44c00.mdtmvttipcod  is not null   then
         open c_ctn44c00  using d_ctn44c00.caddatpsq, d_ctn44c00.mdtmvttipcod
      else
         if d_ctn44c00.mdtmvtstt  is not null   then
            open c_ctn44c00  using d_ctn44c00.caddatpsq, d_ctn44c00.mdtmvtstt
         else
            open c_ctn44c00  using d_ctn44c00.caddatpsq
         end if
      end if
   end if

   foreach  c_ctn44c00  into  a_ctn44c00[arr_aux].mdtmvtseq ,
                              a_ctn44c00[arr_aux].mdttrxnum,
                              a_ctn44c00[arr_aux].cadhor,
                              a_ctn44c00[arr_aux].mdtcod,
                              ws.mdtmvttipcod,
                              ws.mdtmvtstt,
                              ws.mdtbotprgseq,
                              ws.funmat,
                              ws.lclltt,
                              ws.lcllgt

      #--------------------------------------------------------------------
      # Despreza quando situacao informada
      #--------------------------------------------------------------------
      if d_ctn44c00.mdtmvtstt  is not null   then
         if ws.mdtmvtstt  <>  d_ctn44c00.mdtmvtstt   then
            continue foreach
         end if
      end if

      #--------------------------------------------------------------------
      # Carrega dados na primeira tabela
      #--------------------------------------------------------------------
      initialize a_ctn44c00[arr_aux].mdtmvttipdes  to null
      initialize a_ctn44c00[arr_aux].mdtmvtsttdes  to null

      let ws.cponom  =  "mdtmvttipcod"
      open  c_iddkdominio  using  ws.cponom,
                                  ws.mdtmvttipcod
      fetch c_iddkdominio  into   a_ctn44c00[arr_aux].mdtmvttipdes
      close c_iddkdominio

      if ws.mdtbotprgseq  is not null   then
         open  c_datrmdtbotprg using  a_ctn44c00[arr_aux].mdtcod,
                                      ws.mdtbotprgseq
         fetch c_datrmdtbotprg into   a_ctn44c00[arr_aux].mdtmvttipdes
         close c_datrmdtbotprg
      end if

      let ws.cponom  =  "mdtmvtstt"
      open  c_iddkdominio  using  ws.cponom,
                                  ws.mdtmvtstt
      fetch c_iddkdominio  into   a_ctn44c00[arr_aux].mdtmvtsttdes
      close c_iddkdominio

      #--------------------------------------------------------------------
      # Carrega dados na segunda tabela
      #--------------------------------------------------------------------
      initialize a_ctn44c00a[arr_aux].mdterrdes  to null

      if ws.mdtmvtstt  =  3   then
         open  c_datmmdterr  using  a_ctn44c00[arr_aux].mdtmvtseq
         fetch c_datmmdterr  into   ws.mdterrcod
         close c_datmmdterr

         let ws.cponom  =  "mdterrcod"
         open  c_iddkdominio  using  ws.cponom,
                                     ws.mdterrcod
         fetch c_iddkdominio  into   a_ctn44c00a[arr_aux].mdterrdes
         close c_iddkdominio
      end if
      if   ws_ant.mdtcod is not null and
          (ws_ant.mdtcod  = a_ctn44c00[arr_aux].mdtcod) then
          call ctn44c00_dist(ws_ant.lclltt,
                             ws_ant.lcllgt,
                             ws.lclltt,
                             ws.lcllgt)
          returning ws_ant.dist
          if ws_ant.dist is not null then
             let a_ctn44c00[arr_aux - 1].dist = ws_ant.dist
          else
             let a_ctn44c00[arr_aux - 1].dist = ' '
          end if
      else
          if ws.lclltt is null or ws.lclltt = ' ' or ws.lclltt = 0 or
             ws.lcllgt is null or ws.lcllgt = ' ' or ws.lcllgt = 0 then
             let a_ctn44c00[arr_aux].dist = ' '
          else
             let a_ctn44c00[arr_aux].dist = 0
          end if
          if arr_aux > 1 then
             if ws_ant.lclltt is null or ws_ant.lclltt = ' ' or ws_ant.lclltt = 0 or
                ws_ant.lcllgt is null or ws_ant.lcllgt = ' ' or ws_ant.lcllgt = 0 then
                let a_ctn44c00[arr_aux - 1].dist = ' '
             else
                let a_ctn44c00[arr_aux - 1].dist = 0
             end if
          end if
      end if
      let ws_ant.mdtcod  = a_ctn44c00[arr_aux].mdtcod
      let ws_ant.lclltt  = ws.lclltt
      let ws_ant.lcllgt  = ws.lcllgt
      #ligia 28/12/2007 - Gestao de Frota
      let a_ctn44c00[arr_aux].flag = "S"  ## mov. realizado pelo Sistema
      if ws.funmat is not null then
         let a_ctn44c00[arr_aux].flag = "M"  ## mov. realizado manualmente
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 2000  then
         error " Limite excedido, pesquisa com mais de 2000 transmissoes!"
         exit foreach
      end if

   end foreach
   if ws.lclltt is null or ws.lclltt = ' ' or ws.lclltt = 0 or
      ws.lcllgt is null or ws.lcllgt = ' ' or ws.lcllgt = 0 then
      let a_ctn44c00[arr_aux - 1].dist = ' '
   else
      let a_ctn44c00[arr_aux - 1].dist = 0
   end if

   if arr_aux  >  1   then
      let ws.total = "Total: ", arr_aux - 1 using "&&&&"
      display by name ws.total  attribute (reverse)

      message " (F17)Abandona, (F8)Seleciona"
      call set_count(arr_aux-1)

      options insert key F40,
              delete key F45

      input array a_ctn44c00 without defaults  from  s_ctn44c00.*

         before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

            display a_ctn44c00[arr_aux].*  to
                    s_ctn44c00[scr_aux].*  attribute(reverse)

            display a_ctn44c00a[arr_aux].mdterrdes  to  mdterrdes

         after row
            display a_ctn44c00[arr_aux].*  to
                    s_ctn44c00[scr_aux].*

         before field mdtmvtseq
            display a_ctn44c00[arr_aux].mdtmvtseq  to
                    s_ctn44c00[scr_aux].mdtmvtseq  attribute (reverse)

            let ws.mdtmvtseqsva = a_ctn44c00[arr_aux].mdtmvtseq

         after  field mdtmvtseq
            let a_ctn44c00[arr_aux].mdtmvtseq = ws.mdtmvtseqsva
            display a_ctn44c00[arr_aux].mdtmvtseq  to
                    s_ctn44c00[scr_aux].mdtmvtseq

            if fgl_lastkey() = fgl_keyval("down")    or
               fgl_lastkey() = fgl_keyval("right")   or
               fgl_lastkey() = fgl_keyval("return")  then
               if arr_aux   <  2000                          and
                  a_ctn44c00[arr_aux+1].mdtmvtseq  is null   then
                  error " Nao existem mais linhas nesta direcao!"
                  next field  mdtmvtseq
               end if
            end if

         on key (F8)    ##--- Consulta dados ---
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

            display a_ctn44c00[arr_aux].mdtmvtseq  to
                    s_ctn44c00[scr_aux].mdtmvtseq

            call ctn44c01(a_ctn44c00[arr_aux].mdtmvtseq)

          on key (interrupt)
             clear form
             exit input

      end input

      options insert key F1,
              delete key F2

      display " "  to  total
      message ""

      for scr_aux = 1 to 9
         clear s_ctn44c00[scr_aux].*
      end for
   else
      message ""
      error " Nao existem transmissoes para pesquisa!"
   end if

 end while

 let int_flag = false
 close window  w_ctn44c00
 if param.opentip  =  2   then
    close window  w_limpa
 end if

end function  ##--  ctn44c00

#----------------------------------#
function ctn44c00_dist(lr_parametro)
#----------------------------------#

  define lr_parametro record
         lclltt_1     like datmmdtmvt.lclltt,
         lcllgt_1     like datmmdtmvt.lcllgt,
         lclltt_2     like datmmdtmvt.lclltt,
         lcllgt_2     like datmmdtmvt.lcllgt
  end record

  define l_distancia    decimal(8,4),
         l_distancia_2  decimal(12,4),
         l_distmetro    decimal(7,0)

  let l_distancia  = null
  let l_distmetro = null
  if  lr_parametro.lclltt_1 is null or
      lr_parametro.lcllgt_1 is null or
      lr_parametro.lclltt_2 is null or
      lr_parametro.lcllgt_2 is null or
      lr_parametro.lclltt_1 = ''    or
      lr_parametro.lcllgt_1 = ''    or
      lr_parametro.lclltt_2 = ''    or
      lr_parametro.lcllgt_2 = ''    or
      lr_parametro.lclltt_1 = 0     or
      lr_parametro.lcllgt_1 = 0     or
      lr_parametro.lclltt_2 = 0     or
      lr_parametro.lcllgt_2 = 0     then
      return l_distmetro
  end if
  call cts18g00(lr_parametro.lclltt_1,
                lr_parametro.lcllgt_1,
                lr_parametro.lclltt_2,
                lr_parametro.lcllgt_2)

       returning l_distancia
  let l_distancia_2 = l_distancia * 1000
  let l_distmetro = l_distancia_2
  return l_distmetro

end function
