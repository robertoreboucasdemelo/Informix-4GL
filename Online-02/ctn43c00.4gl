 ##############################################################################
 # Nome do Modulo: ctn43c00                                          Marcelo  #
 #                                                                   Gilberto #
 # Consulta mensagens enviadas para MDT's                            Ago/1999 #
 ##############################################################################
 # Alteracoes:                                                                #
 #                                                                            #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
 #----------------------------------------------------------------------------#
 # 04/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.    #
 #----------------------------------------------------------------------------#
 # 07/01/2003  PSI 163773   Raji         Chamada direta pelo acomp. Servico.  #
 # 05/05/2009  PSI 240540   Adriano      Funcao para consultar a ultima msg   #
 ##############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------#
 function ctn43c00(param)
#------------------------------------------------------------#

 define param record
    atdsrvnum         like datmmdtsrv.atdsrvnum,
    atdsrvano         like datmmdtsrv.atdsrvano
 end record

 define a_ctn43c00   array[800]   of record
    mdtmsgnum        like datmmdtmsg.mdtmsgnum,
    mdtmsgsttdes     char (26),
    atldat           like datmmdtlog.atldat,
    atlhor           like datmmdtlog.atlhor,
    mdtmsgstt        like datmmdtmsg.mdtmsgstt,
    servico          char (13)
 end record

 define d_ctn43c00    record
    atdsrvnum         like datmmdtsrv.atdsrvnum,
    atdsrvano         like datmmdtsrv.atdsrvano,
    mdttrxdat         date,
    mdttrxsit         like datmmdtmsg.mdtmsgstt
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmmdtsrv.atdsrvnum,
    atdsrvano         like datmmdtsrv.atdsrvano,
    cponom            like iddkdominio.cponom,
    comando           char (800),
    condicao          char (650),
    total             char (10)
 end record

 define arr_aux       smallint
 define scr_aux       smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  800
		initialize  a_ctn43c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn43c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn43c00 at  06,02 with form "ctn43c00"
             attribute(form line first)

 #-----------------------------------------------------------------------
 # Prepara comandos SQL
 #-----------------------------------------------------------------------
 let ws.comando = "select cpodes ",
                  "  from iddkdominio",
                  " where cponom = ? ",
                  "   and cpocod = ? "
 prepare p_ctn43c00_001 from ws.comando
 declare c_ctn43c00_001 cursor for p_ctn43c00_001

 let ws.comando = "select atldat, ",
                  "       atlhor  ",
                  "  from datmmdtlog",
                  " where mdtmsgnum = ? ",
                  "   and mdtlogseq = 1 "
 prepare p_ctn43c00_002 from ws.comando
 declare c_ctn43c00_002 cursor for p_ctn43c00_002

 let ws.comando = "select atdsrvnum, ",
                  "       atdsrvano  ",
                  "  from datmmdtsrv",
                  " where mdtmsgnum = ? "
 prepare p_ctn43c00_003 from ws.comando
 declare c_ctn43c00_003 cursor for p_ctn43c00_003

 let ws.comando = "select atdsrvorg     ",
                  "  from datmservico   ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? "
 prepare p_ctn43c00_004 from ws.comando
 declare c_ctn43c00_004 cursor for p_ctn43c00_004

 while true

   initialize ws.*          to null
   initialize a_ctn43c00    to null
   let ws.cponom  = "mdtmsgstt"
   let int_flag   = false
   let arr_aux    = 1

   if param.atdsrvnum is null then
      input by name d_ctn43c00.*

         before field atdsrvnum
            display by name d_ctn43c00.atdsrvnum  attribute (reverse)
            display by name ws.atdsrvorg

         after  field atdsrvnum
            display by name d_ctn43c00.atdsrvnum

            if d_ctn43c00.atdsrvnum is null    then
               initialize d_ctn43c00.atdsrvano  to null
               display by name d_ctn43c00.atdsrvano
               next field mdttrxdat
            end if

         before field atdsrvano
            display by name d_ctn43c00.atdsrvano  attribute (reverse)

         after  field atdsrvano
            display by name d_ctn43c00.atdsrvano

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field atdsrvnum
            end if

            if d_ctn43c00.atdsrvano   is null      and
               d_ctn43c00.atdsrvnum   is not null  then
               error " Ano do servico deve ser informado!"
               next field atdsrvano
            end if

            if d_ctn43c00.atdsrvano   is not null   and
               d_ctn43c00.atdsrvnum   is null       then
               error " Numero do servico deve ser informado!"
               next field atdsrvnum
            end if

            open  c_ctn43c00_004   using d_ctn43c00.atdsrvnum,
                                        d_ctn43c00.atdsrvano
            fetch c_ctn43c00_004   into  ws.atdsrvorg
            if sqlca.sqlcode = notfound   then
               error " Servico nao cadastrado !"
               next field atdsrvano
            end if
            close c_ctn43c00_004

            display by name ws.atdsrvorg

            exit input

         before field mdttrxdat
            display by name d_ctn43c00.mdttrxdat    attribute (reverse)

            let d_ctn43c00.mdttrxdat = today

         after  field mdttrxdat
            display by name d_ctn43c00.mdttrxdat

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               initialize d_ctn43c00.mdttrxdat  to null
               display by name d_ctn43c00.mdttrxdat
               next field atdsrvnum
            end if

            if d_ctn43c00.mdttrxdat  is null   then
               error " Data da transmissao da mensagem deve ser informada!"
               next field mdttrxdat
            end if

         before field mdttrxsit
            display by name d_ctn43c00.mdttrxsit attribute (reverse)

         after  field mdttrxsit
            display by name d_ctn43c00.mdttrxsit

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               initialize d_ctn43c00.mdttrxsit  to null
               display by name d_ctn43c00.mdttrxsit
               next field atdtrxdat
            end if

            if d_ctn43c00.mdttrxsit  is not null   then
               select cpodes
                 from iddkdominio
                where cponom  =  "mdtmsgstt"
                  and cpocod  =  d_ctn43c00.mdttrxsit

               if sqlca.sqlcode  =  notfound   then
                  error " Situacao nao cadastrada!"
                  call ctn36c00("Situacao de mensagem MDT", "mdtmsgstt")
                       returning  d_ctn43c00.mdttrxsit
                  next field mdttrxsit
               end if
            end if

         on key (interrupt)
            exit input

      end input
   else
      let d_ctn43c00.atdsrvnum = param.atdsrvnum
      let d_ctn43c00.atdsrvano = param.atdsrvano
   end if

   if int_flag   then
      exit while
   end if

   #-----------------------------------------------------------------------
   # Consulta transmissoes conforme parametro informado
   #-----------------------------------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)

   if d_ctn43c00.atdsrvnum  is not null   then
      let ws.condicao = "  from datmmdtsrv, datmmdtmsg",
                        " where datmmdtsrv.atdsrvnum = ? ",
                        "   and datmmdtsrv.atdsrvano = ? ",
                        "   and datmmdtmsg.mdtmsgnum = datmmdtsrv.mdtmsgnum",
                        " order by datmmdtmsg.mdtmsgnum "
  #end if

  #if d_ctn43c00.mdttrxdat is not null   then

   else
      if d_ctn43c00.mdttrxsit is not null then
         let ws.condicao = "  from datmmdtmsg, datmmdtlog     ",
                           " where datmmdtmsg.mdtmsgstt = ? ",
                           "   and datmmdtlog.mdtmsgnum = datmmdtmsg.mdtmsgnum",
                           "   and datmmdtlog.mdtlogseq = 1 ",
                           "   and datmmdtlog.atldat    = ? ",
                           " order by datmmdtmsg.mdtmsgnum "
      else
         let ws.condicao = "  from datmmdtlog, datmmdtmsg ",
                           " where datmmdtlog.atldat = ? ",
                           "   and datmmdtmsg.mdtmsgnum = datmmdtlog.mdtmsgnum",
                           " group by datmmdtmsg.mdtmsgnum,",
                           "          datmmdtmsg.mdtmsgstt ",
                           " order by datmmdtmsg.mdtmsgnum "
      end if

   end if

   let ws.comando = " select datmmdtmsg.mdtmsgnum, datmmdtmsg.mdtmsgstt ",
                    ws.condicao clipped
   prepare sql_select from ws.comando
   declare c_ctn43c00 cursor for sql_select

   if d_ctn43c00.atdsrvnum  is not null   then
      open c_ctn43c00  using d_ctn43c00.atdsrvnum, d_ctn43c00.atdsrvano
   else
      if d_ctn43c00.mdttrxsit  is not null   then
         open c_ctn43c00  using d_ctn43c00.mdttrxsit, d_ctn43c00.mdttrxdat
      else
         open c_ctn43c00  using d_ctn43c00.mdttrxdat
      end if
   end if

   foreach  c_ctn43c00  into  a_ctn43c00[arr_aux].mdtmsgnum ,
                              a_ctn43c00[arr_aux].mdtmsgstt

      open  c_ctn43c00_001  using  ws.cponom,
                                  a_ctn43c00[arr_aux].mdtmsgstt
      fetch c_ctn43c00_001  into   a_ctn43c00[arr_aux].mdtmsgsttdes
      close c_ctn43c00_001

      initialize a_ctn43c00[arr_aux].servico  to null
      initialize ws.atdsrvnum                 to null
      initialize ws.atdsrvano                 to null

      open  c_ctn43c00_003   using  a_ctn43c00[arr_aux].mdtmsgnum
      fetch c_ctn43c00_003   into   ws.atdsrvnum,
                                  ws.atdsrvano
      close c_ctn43c00_003

      open  c_ctn43c00_004   using ws.atdsrvnum,
                                  ws.atdsrvano
      fetch c_ctn43c00_004   into  ws.atdsrvorg
      close c_ctn43c00_004

      if ws.atdsrvnum  is not null   then
         let a_ctn43c00[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                       "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                       "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)
      end if

      open  c_ctn43c00_002   using  a_ctn43c00[arr_aux].mdtmsgnum
      fetch c_ctn43c00_002   into   a_ctn43c00[arr_aux].atldat,
                                  a_ctn43c00[arr_aux].atlhor
      close c_ctn43c00_002

      let arr_aux = arr_aux + 1
      if arr_aux > 800  then
         error " Limite excedido, pesquisa com mais de 800 transmissoes!"
         exit foreach
      end if

   end foreach

   if arr_aux  >  1   then
      let ws.total = "Total: ", arr_aux - 1 using "&&&"
      display by name ws.total  attribute (reverse)

      message " (F17)Abandona, (F8)Log, (F9)Texto"
      call set_count(arr_aux-1)

      display array  a_ctn43c00 to s_ctn43c00.*
         on key (interrupt)
            exit display

         on key (F8)    ##--- Consulta log da mensagem ---
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            call ctn43c01(a_ctn43c00[arr_aux].mdtmsgnum)

         on key (F9)    ##--- Consulta texto da mensagem ---
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            call ctn43c02(a_ctn43c00[arr_aux].mdtmsgnum)
      end display

      display " "  to  total

      for scr_aux = 1 to 11
         clear s_ctn43c00[scr_aux].*
      end for
   else
      error " Nao existem transmissoes para pesquisa!"
   end if

   if param.atdsrvnum is not null then
      exit while
   end if

 end while

 let int_flag = false
 close window  w_ctn43c00

end function  #  ctn43c00

#####################################################################################

#------------------------------------------------------------#
 function ctn43c00_alt_msg(param)
#------------------------------------------------------------#

 define param record
    atdsrvnum         like datmmdtsrv.atdsrvnum,
    atdsrvano         like datmmdtsrv.atdsrvano
 end record

 define ws record
    mdtmsgnum         like datmmdtsrv.mdtmsgnum,
    mdtmsgstt         like datmmdtmsg.mdtmsgstt,
    mdtmsgsttdes      char (26),
    atldat            like datmmdtlog.atldat,
    atlhor            like datmmdtlog.atlhor,
    cponom            like iddkdominio.cponom,
    mdtmsgtxt         like datmmdtmsgtxt.mdtmsgtxt
 end record
 define l_sql       char(1000),
        l_status    smallint  ,
        l_atdvclsgl char(5)
 initialize ws.* to null
 let ws.cponom = "mdtmsgstt"
 let l_sql = " select 1                         "
            ,"  from datmmdtsrv                 "
            ," where datmmdtsrv.atdsrvnum = ?   "
            ,"   and datmmdtsrv.atdsrvano = ?   "
 prepare sel_msg from l_sql
 declare c_sel_msg cursor for sel_msg
 let l_sql = " select max(datmmdtsrv.mdtmsgnum) "
            ,"  from datmmdtsrv                 "
            ," where datmmdtsrv.atdsrvnum = ?   "
            ,"   and datmmdtsrv.atdsrvano = ?   "
 prepare sel_max_msg from l_sql
 declare c_sel_max_msg cursor for sel_max_msg
 let l_sql = "select cpodes ",
                  "  from iddkdominio",
                  " where cponom = ? ",
                  "   and cpocod = ? "
 prepare sel_iddkdominio_2 from l_sql
 declare c_iddkdominio_2 cursor for sel_iddkdominio_2
 let l_sql = "select datmmdtmsg.mdtmsgstt,                       "
            ,"       datmmdtlog.atldat, datmmdtlog.atlhor        "
            ,"from datmmdtmsg, datmmdtlog                        "
            ,"where datmmdtmsg.mdtmsgnum = ?                     "
            ,"  and datmmdtmsg.mdtmsgnum = datmmdtlog.mdtmsgnum  "
            ,"  and datmmdtlog.mdtlogseq = 1                     "
 prepare sel_datmmdtlog_2 from l_sql
 declare c_datmmdtlog_2 cursor for sel_datmmdtlog_2
 let l_sql = "select mdtmsgtxt        "
            ,"  from datmmdtmsgtxt    "
            ," where mdtmsgnum    = ? "
            ,"   and mdtmsgtxtseq = 1 "
 prepare sel_datmmdtmsgtxt from l_sql
 declare c_datmmdtmsgtxt cursor for sel_datmmdtmsgtxt
 open  c_sel_msg  using  param.atdsrvnum,
                         param.atdsrvano
 fetch c_sel_msg  into   l_status
 if sqlca.sqlcode <> 0 then
     let ws.mdtmsgsttdes = null
     let ws.atldat       = null
     let ws.atlhor       = null
     let l_atdvclsgl     = null
     close c_sel_msg
     return ws.mdtmsgsttdes
           ,ws.atldat
           ,ws.atlhor
           ,l_atdvclsgl
 end if
 close c_sel_msg
 open  c_sel_max_msg  using  param.atdsrvnum,
                             param.atdsrvano
 fetch c_sel_max_msg  into   ws.mdtmsgnum
 close c_sel_max_msg
 open  c_datmmdtlog_2   using  ws.mdtmsgnum
 fetch c_datmmdtlog_2   into   ws.mdtmsgstt,
                               ws.atldat,
                               ws.atlhor
 close c_datmmdtlog_2
 open  c_iddkdominio_2  using  ws.cponom,
                               ws.mdtmsgstt
 fetch c_iddkdominio_2  into   ws.mdtmsgsttdes
 close c_iddkdominio_2
 open  c_datmmdtmsgtxt  using  ws.mdtmsgnum
 fetch c_datmmdtmsgtxt  into   ws.mdtmsgtxt
 close c_datmmdtmsgtxt
 let l_atdvclsgl = ws.mdtmsgtxt[1,5]
 return ws.mdtmsgsttdes
       ,ws.atldat
       ,ws.atlhor
       ,l_atdvclsgl
end function  #  ctn43c00_alt_msg

