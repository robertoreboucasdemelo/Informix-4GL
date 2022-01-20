###############################################################################
# Nome do Modulo: cts00m25                                           Marcus   #
#                                                                    Ruiz     #
# Consulta etapas de acompanhamento de servicos via internt          Ago/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

#-----------------------------------------------------------
 function cts00m25(param)
#-----------------------------------------------------------

 define param       record
    atdsrvnum       like datmsrvacp.atdsrvnum,
    atdsrvano       like datmsrvacp.atdsrvano
 end record

 define d_cts00m25  record
    srvnum          char (13),
    srvtipdes       like datksrvtip.srvtipdes
 end record

 define a_cts00m25  array[30] of record
    atdetpdes       like datketapa.atdetpdes,
    caddat          like datmsrvint.caddat   ,
    cadhor          datetime hour to minute  ,
    atdetpseq       like datmsrvint.atdetpseq,
    origem          char (50)               ,
    nomgrr          like dpaksocor.nomgrr
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define ws          record
    sql             char (400),
    empcod          like isskfunc.empcod,
    funmat          like isskfunc.funmat,
    atdsrvorg       like datksrvtip.atdsrvorg,
    atdetpcod       like datketapa.atdetpcod,
    pstcoddig       like dpaksocor.pstcoddig,
    cadorg          like datmsrvint.cadorg
 end record

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
   define l_resultado smallint,
          l_mensagem char(70)

	define	w_pf1	integer

   let l_resultado = null
   let l_mensagem = null

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cts00m25[w_pf1].*  to  null
	end	for

	initialize  d_cts00m25.*  to  null

	initialize  ws.*  to  null

 initialize a_cts00m25     to null
 initialize d_cts00m25.*   to null
 initialize ws.*           to null

#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 let ws.sql = "select atdetpdes    ",
              "  from datksrvintetp ",
              " where atdetpcod = ?"
 prepare p_cts00m25_001 from ws.sql
 declare c_cts00m25_001 cursor for p_cts00m25_001

 let ws.sql = "select nomgrr       ",
              "  from dpaksocor    ",
              " where pstcoddig = ?"
 prepare p_cts00m25_002 from ws.sql
 declare c_cts00m25_002 cursor for p_cts00m25_002

#--------------------------------------------------------------------
# Cabecalho
#--------------------------------------------------------------------

 select atdsrvorg
   into ws.atdsrvorg
   from datmservico
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 let d_cts00m25.srvnum = ws.atdsrvorg    using "&&", "/",
                         param.atdsrvnum using "&&&&&&&", "-",
                         param.atdsrvano using "&&"

 let d_cts00m25.srvtipdes = "*** NAO CADASTRADO! ***"

 select srvtipdes
   into d_cts00m25.srvtipdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 open window cts00m25 at 05,02 with form "cts00m25"
             attribute (form line first)

 display by name d_cts00m25.*

 declare  c_cts00m25_003  cursor for
    select atdetpcod, caddat   ,
           cadhor   , cadorg   ,
           pstcoddig, atdetpseq
      from datmsrvint
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
     order by atdetpseq

 let arr_aux = 1

 foreach  c_cts00m25_003  into  ws.atdetpcod,
                            a_cts00m25[arr_aux].caddat   ,
                            a_cts00m25[arr_aux].cadhor   ,
                            ws.cadorg                    ,
                            ws.pstcoddig,
                            a_cts00m25[arr_aux].atdetpseq

      open  c_cts00m25_001 using ws.atdetpcod
      fetch c_cts00m25_001 into  a_cts00m25[arr_aux].atdetpdes
      close c_cts00m25_001

      let a_cts00m25[arr_aux].origem = "** NAO CADASTRADO **"
      select cpodes
         into  a_cts00m25[arr_aux].origem
         from  iddkdominio
        where  cponom = "orgsrvint"
          and  cpocod = ws.cadorg

      if ws.atdsrvorg = 8 then
         call ctc30g00_dados_loca (3,ws.pstcoddig)
           returning l_resultado, l_mensagem, a_cts00m25[arr_aux].nomgrr
      else
         open  c_cts00m25_002 using ws.pstcoddig
         fetch c_cts00m25_002 into  a_cts00m25[arr_aux].nomgrr
         close c_cts00m25_002
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 30  then
         error " Limite excedido. Servico possui mais de 30 etapas",
               " de acompanhamento!"
         exit foreach
      end if
 end foreach

 if arr_aux > 1  then
    message " (F17)Abandona, (F8)Mais Informacoes "
    call set_count(arr_aux-1)

    display array a_cts00m25 to s_cts00m25.*
       on key(interrupt, control-c)
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          call cts00m26(a_cts00m25[arr_aux].atdetpdes,
                        a_cts00m25[arr_aux].caddat,
                        a_cts00m25[arr_aux].cadhor,
                        a_cts00m25[arr_aux].atdetpseq,
                        a_cts00m25[arr_aux].origem,
                        a_cts00m25[arr_aux].nomgrr,
                        param.atdsrvnum,
                        param.atdsrvano)
    end display
 else
    error " Nao existem etapas cadastradas para este servico!"
 end if

 let int_flag = false
 close window cts00m25

end function  ###  cts00m25
