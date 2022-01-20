#############################################################################
# Nome do Modulo: CTB25M00                                         Raji     #
#                                                                           #
# Analise de adicionais de Servicos                                Mar/2003 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
#                   * * * Alteracoes * * *                                  ##
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 27/08/2004 Robson, Meta      PSI187143  Inserir filtros(situacao, prestador#
#                                         periodo, cronograma).              #
#                                                                            #
#----------------------------------------------------------------------------#
# 28/11/2006 Priscila       PSI 205206  Receber empresa como parametro e     #
#                                       permitir input de ciaempcod          #
#----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32         #
#                                                                            #
#----------------------------------------------------------------------------#
# 15/03/2012 Celso Yamahaki PSI-03847   Contagem Tempo do inicio de analise  #
#                                                                            #
# 09/01/2013 Jorge Modena PSI-2013-00430 Adicao de campos na tela e atalho   #
#                                        F9 para Liberar servico nesta tela  #
#                                                                            #
# 08/03/2016 Rafael/ElianeK              Acertos na tecla <F9> e apresentacao#
#            Porto/Fornax                dos servicos na tela                #
##############################################################################
database porto

# PSI187143 - robson - inicio
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare_sql smallint
      ,m_erro        smallint
      ,teste         char(1)

#----------------------------#
function ctb25m00_cria_temp()
#----------------------------#

 whenever error continue

 drop table tmpctb00g04

 create temp table tmpctb00g04
  (
   numlinha  integer
  ,linha     char(75)
  ) with no log

 create index idx_tmpctb00g04 on tmpctb00g04 (numlinha)

 whenever error stop

 if sqlca.sqlcode <> 0 then
    error 'Erro CREATE / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_cria_temp() ' sleep 2
    let m_erro = true
 end if

end function

#--------------------------#
function ctb25m00_prepare()
#--------------------------#
 define l_sql char(200)

   let l_sql = ' insert into tmpctb00g04 values (?,?) '
   prepare pctb25m00003 from l_sql

   let l_sql = ' delete from tmpctb00g04 '
   prepare pctb25m00007 from l_sql

   let m_prepare_sql = true

end function

# PSI187143 - robson - fim

#-----------------------------------------------------------
 function ctb25m00(param)
#-----------------------------------------------------------
 define param record
    srvtip           char(5),
    pendente         char(1)
 end record

 define a_ctb25m00   array[1501] of record
    servico          char (13),
    prsokadat        like dbsmsrvacr.prsokadat,
    prsokahor        datetime hour to minute,
    incvlr           like dbsmsrvacr.incvlr,
    fnlvlr           like dbsmsrvacr.fnlvlr,
    etapa            char (17),
    srvprsacndat     date,
    srvprsacnhor     datetime hour to minute,
    percurso         char (38)
 end record

 define k_ctb25m00   record
    atdsrvnum        like datmservico.atdsrvnum,  # Servico
    atdsrvano        like datmservico.atdsrvano,  #
    anlokaflg        like dbsmsrvacr.anlokaflg,   # situacao        - PSI187143 - robson - inicio
    pstcoddig        like dpaksocor.pstcoddig,    # prestador
    periodoini       like dbsmsrvacr.prsokadat,   # periodo inicial
    periodofim       like dbsmsrvacr.prsokadat,   # periodo final
    crnpgtcod        like dpaksocor.crnpgtcod,    # cronograma      - PSI187143 - robson - fim
    Classifica       char(1),
    ciaempcod        like datmservico.ciaempcod,  #empresa   #PSI 205206
    empsgl           like gabkemp.empsgl          #sigla da empresa   #PSI 205206
 end record

 define ws           record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    prsokadat        like dbsmsrvacr.prsokadat,
    prsokahor        like dbsmsrvacr.prsokahor,
    incvlr           like dbsmsrvacr.incvlr,
    fnlvlr           like dbsmsrvacr.fnlvlr,
    atdsrvorg        like datmservico.atdsrvorg,
    c24opemat        like datmservico.c24opemat,
    c24openom        like isskfunc.funnom,
    relogio          datetime hour to second,
    trava            char (01),
    ciaempcod        like datmservico.ciaempcod      #codigo da empresa do servico #PSI 205206
 end record

 define ws_igbkchave char(20)
 define ws_pricod    smallint
 define ws_privez    smallint
 define sql_comando  char (900)

 define arr_aux      smallint
 define scr_aux      smallint
 define w_cont       integer

	define	w_pf1	integer
#PSI187143 - robson - inicio

 define l_data      date
 define l_data2     date
 define l_sql       char(500)
 define l_saida     smallint
 define l_resposta  char(50)
 define l_lighorinc like datmservhist.lighorinc
 define l_anlokaflg like dbsmsrvacr.anlokaflg

 #PSI 205206
 define l_ret      smallint,
        l_mensagem char(80),
	n          integer

#PSI-2013-00430 - inicio
 define  ws_cnldat           date
 define  ws_atdfnlhor        datetime hour to minute
 define  ws_atdetpcod        like datmsrvacp.atdetpcod
 define  ws_atdetpdes        like datketapa.atdetpdes
 define  ws_cidnom           like datmlcl.cidnom
 define  ws_ufdcod           like datmlcl.ufdcod
 define  ws_c24endtip        like datmlcl.c24endtip
 define  ws_percurso         char (38)
 define  ws_pgtdat           date
 define  ws_socopgnum        like dbsmopg.socopgnum
#PSI-2013-00430 - fim

 define l_funmat       dec (06)
       ,l_pode_liberar char(01)
       ,l_libera       char(01)
       ,l_msg          char(80)

 let l_data              = today
 let l_data2             =  l_data - 180 units day
 let m_erro              = false
 let l_sql               = null
 let l_saida             = null
 let l_mensagem          = null
 let l_lighorinc         = null
 let l_libera            = null
 let l_msg               = null
 let l_pode_liberar      = null

#PSI187143 - robson - fim

 let	ws_igbkchave  =  null
 let	ws_pricod  =  null
 let	ws_privez  =  null
 let	sql_comando  =  null
 let	arr_aux  =  null
 let	scr_aux  =  null

 let    ws_cnldat           = null
 let    ws_atdfnlhor        = null
 let    ws_atdetpcod        = null
 let    ws_atdetpdes        = null
 let    ws_cidnom           = null
 let    ws_ufdcod           = null
 let    ws_c24endtip        = null
 let    ws_percurso         = null
 let    ws_pgtdat           = null
 let    ws_socopgnum        = null




	for	w_pf1  =  1  to  600
		initialize  a_ctb25m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null
	initialize  g_ppt.cmnnumdig to null
    initialize  w_cont to null

 let ws_privez = true

  #--------------------------------------------------------------------
  # Cursor para obter descricao do TIPO DE SERVICO / ASSISTENCIA
  #--------------------------------------------------------------------
  let sql_comando = "select srvtipabvdes",
                    "  from datksrvtip  ",
                    " where atdsrvorg = ?  "
  prepare sel_datksrvtip from sql_comando
  declare c_datksrvtip cursor for sel_datksrvtip

  #--------------------------------------------------------------------
  # Cursor para verificar se veiculo e' caminhao
  #--------------------------------------------------------------------
  let sql_comando = "select vclcamtip",
                    "  from datmservicocmp",
                    " where atdsrvnum = ? and ",
                    "       atdsrvano = ?     "
  prepare sel_datmservicocmp from sql_comando
  declare c_datmservicocmp cursor for sel_datmservicocmp

  #--------------------------------------------------------------------
  # Prepare para 'LOCAR' o servico enquanto esta' sendo acionado
  #--------------------------------------------------------------------
  let sql_comando = "update datmservico   ",
                    "   set c24opemat = ? ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? "
  prepare update_lock  from sql_comando

   let l_sql = ' select prsvlr, fnlvlr from dbsmsrvacr '
	      ,'  where atdsrvnum = ? '
	      ,'    and atdsrvano = ? '
   prepare pctb25m0008 from l_sql
   declare cctb25m0008 cursor for pctb25m0008

   let l_sql = " select cpodes[1,6], cpodes[8,19], cpodes[21,26] ",
	       " from datkdominio ",
               " where  cponom = 'ALCADA' "
   prepare pctb25m0009 from l_sql
   declare cctb25m0009 cursor for pctb25m0009

   let l_sql = " select cpodes[1,6] ",
              " from datkdominio ",
	      " where  cponom = 'ALCADA' "
   prepare pctb25m0010 from l_sql
   declare cctb25m0010 cursor for pctb25m0010


  open window w_ctb25m00 at 03,02 with form "ctb25m00" attribute(form line 1)
  # PSI187143 - robson

 #--------------------------------------------------------------------
 # Exibe servicos a serem passados para os prestadores
 #--------------------------------------------------------------------
 while true

   initialize a_ctb25m00    to null
   initialize ws.*          to null
   initialize g_documento.* to null

 # PSI187143 - robson - inicio
   let int_flag = false

   input by name k_ctb25m00.atdsrvnum
                ,k_ctb25m00.atdsrvano
                ,k_ctb25m00.anlokaflg
                ,k_ctb25m00.periodoini
                ,k_ctb25m00.periodofim
                ,k_ctb25m00.pstcoddig
                ,k_ctb25m00.crnpgtcod
                ,k_ctb25m00.classifica
                ,k_ctb25m00.ciaempcod          #PSI 205206

      before input
             next field pstcoddig


      before field atdsrvano

	      if fgl_lastkey() = fgl_keyval("up")   or
	         fgl_lastkey() = fgl_keyval("left") then
                 next field atdsrvnum
	     end if

             if k_ctb25m00.atdsrvnum  is null then
                next field anlokaflg
	     end if

      After  field atdsrvano

             if k_ctb25m00.atdsrvano is not null and
                k_ctb25m00.atdsrvnum is not null then
                initialize k_ctb25m00.anlokaflg   to null
                initialize k_ctb25m00.periodoini  to null
                initialize k_ctb25m00.periodofim  to null
                initialize k_ctb25m00.pstcoddig   to null
                initialize k_ctb25m00.crnpgtcod   to null
                initialize k_ctb25m00.classifica  to null
                initialize k_ctb25m00.ciaempcod   to null
                let int_flag = false

		select ciaempcod   into k_ctb25m00.ciaempcod
                  from datmservico
                  where atdsrvnum = k_ctb25m00.atdsrvnum
                   and atdsrvano  = k_ctb25m00.atdsrvano

                call cty14g00_empresa(1, k_ctb25m00.ciaempcod)
		returning l_ret,
		          l_mensagem,
		          k_ctb25m00.empsgl

		if l_ret <> 1 then
		   let k_ctb25m00.ciaempcod = null
		   let k_ctb25m00.empsgl    = null
		end if
		display by name k_ctb25m00.empsgl
                exit input
              else
	       let  k_ctb25m00.atdsrvnum = null
	       let  k_ctb25m00.atdsrvano = null
               display by name k_ctb25m00.atdsrvnum
               display by name k_ctb25m00.atdsrvano
             end if

      before field anlokaflg
             if k_ctb25m00.anlokaflg is null or
                k_ctb25m00.anlokaflg = ' ' then
                let k_ctb25m00.anlokaflg = 'N'
             end if
             display by name k_ctb25m00.anlokaflg attribute (reverse)

       after field anlokaflg
             display by name k_ctb25m00.anlokaflg
                if k_ctb25m00.anlokaflg <> 'N' and
                   k_ctb25m00.anlokaflg <> 'P' and
                   k_ctb25m00.anlokaflg <> 'S' and
                   k_ctb25m00.anlokaflg <> 'L' then
                   error ' Situacao invalida ' sleep 2
                   next field anlokaflg
                end if


      before field periodoini
             if k_ctb25m00.periodoini is null then
                let k_ctb25m00.periodoini = l_data2
             end if
             display by name k_ctb25m00.periodoini attribute (reverse)

       after field periodoini
             display by name k_ctb25m00.periodoini

      before field periodofim
             if k_ctb25m00.periodofim is null then
                let k_ctb25m00.periodofim = l_data
             end if
             display by name k_ctb25m00.periodofim attribute (reverse)

       after field periodofim
             display by name k_ctb25m00.periodofim

      before field pstcoddig
             display by name k_ctb25m00.pstcoddig attribute (reverse)
             if k_ctb25m00.periodoini is null then
                let k_ctb25m00.periodoini = l_data2
                display by name k_ctb25m00.periodoini
             end if

             if k_ctb25m00.periodofim is null then
                let k_ctb25m00.periodofim = l_data
                display by name k_ctb25m00.periodofim
             end if

             if k_ctb25m00.anlokaflg is null or
                k_ctb25m00.anlokaflg = ' ' then
                let k_ctb25m00.anlokaflg = 'N'
                display by name k_ctb25m00.anlokaflg
             end if

       after field pstcoddig
             display by name k_ctb25m00.pstcoddig
             if k_ctb25m00.pstcoddig is not null then
                if k_ctb25m00.pstcoddig < 0 or
                   k_ctb25m00.pstcoddig > 999999 then
                   error ' Valor invalido ' sleep 2
                   next field pstcoddig
                end if

             end if

      before field crnpgtcod
             display by name k_ctb25m00.crnpgtcod attribute (reverse)

       after field crnpgtcod
             display by name k_ctb25m00.crnpgtcod
             if k_ctb25m00.crnpgtcod is not null then
                if k_ctb25m00.crnpgtcod < 0 or
                   k_ctb25m00.crnpgtcod > 99 then
                   error ' Valor invalido ' sleep 2
                   next field crnpgtcod
                end if
             end if

      before field classifica

             if k_ctb25m00.classifica is null then
                let k_ctb25m00.classifica = "D"
             end if
             display by name k_ctb25m00.classifica attribute (reverse)

      after field classifica

             display by name k_ctb25m00.classifica
             if k_ctb25m00.classifica <> "D" and
                k_ctb25m00.classifica <> "S" and
                k_ctb25m00.classifica <> "V" then
                error 'Classificacao Invalida ' sleep 2
                next field classifica
             end if

      #PSI 205206
      before field ciaempcod
             display by name k_ctb25m00.ciaempcod attribute (reverse)

      after field ciaempcod
             display by name k_ctb25m00.ciaempcod
             if k_ctb25m00.ciaempcod is not null then
                call cty14g00_empresa(1, k_ctb25m00.ciaempcod)
                     returning l_ret,
                               l_mensagem,
                               k_ctb25m00.empsgl
                if l_ret <> 1 then
                   error l_mensagem
                   let k_ctb25m00.ciaempcod = null
                   next field ciaempcod
                end if
             else
                #let k_ctb25m00.empsgl = "TODAS"
                #se nao informei empresa - obrigar a informar empresa
                call cty14g00_popup_empresa()
                     returning l_ret,
                               k_ctb25m00.ciaempcod,
                               k_ctb25m00.empsgl
                if k_ctb25m00.ciaempcod is null then
                   next field ciaempcod
                end if
             end if
             display by name k_ctb25m00.empsgl

      on key (interrupt, control-c, f17)
         let int_flag = true
         exit input

   end input

   if int_flag then
      let int_flag = false
      exit while
   end if

  if k_ctb25m00.atdsrvnum is null then
     #--------------------------------------------------------------------
     # Cursor PRINCIPAL da tela
     #--------------------------------------------------------------------
     let sql_comando = " select a.atdsrvnum "
                            ," ,a.atdsrvano "
                            ," ,a.prsokadat "
                            ," ,a.prsokahor "
                            ," ,a.incvlr "
                            ," ,a.fnlvlr "
                        ," from dbsmsrvacr a "
                            ," ,dpaksocor b "
                       ," where a.prsokaflg = 'S' "
                         ," and b.pstcoddig = a.pstcoddig "
                         ," and a.prsokadat >= ? "
                         ," and a.prsokadat <= ? "
                         ," and a.anlokaflg = ?  "

     #-- Codigo do prestador --#
     if k_ctb25m00.pstcoddig is not null then
        let sql_comando = sql_comando clipped,
                           " and a.pstcoddig = ",k_ctb25m00.pstcoddig
     end if

     #-- Codigo do cronograma --#
     if k_ctb25m00.crnpgtcod is not null then
        let sql_comando = sql_comando clipped,
                        " and b.crnpgtcod = ",k_ctb25m00.crnpgtcod
     end if

     if k_ctb25m00.classifica = "D" then
        let sql_comando = sql_comando clipped,
                     " order by a.prsokadat "
                               ," ,a.prsokahor "
     end if

     if k_ctb25m00.classifica = "S" then
        let sql_comando = sql_comando clipped,
                        " order by a.atdsrvano "
                               ," ,a.atdsrvnum "
     end if

     if k_ctb25m00.classifica = "V" then
        let sql_comando = sql_comando clipped,
                        " order by a.fnlvlr    "
     end if

   else
     #--------------------------------------------------------------------
     # Cursor PRINCIPAL da tela
     #--------------------------------------------------------------------
     let sql_comando = " select a.atdsrvnum "
                            ," ,a.atdsrvano "
                            ," ,a.prsokadat "
                            ," ,a.prsokahor "
                            ," ,a.incvlr "
                            ," ,a.fnlvlr "
                        ," from dbsmsrvacr a "
                            ," ,dpaksocor b "
                         ," where b.pstcoddig = a.pstcoddig "
                         ," and a.atdsrvnum = ? "
                         ," and a.atdsrvano = ? "

   end if

   prepare sel_datmservico from sql_comando
   declare c_ctb25m00 cursor for sel_datmservico


 # PSI187143 - robson - fim

   let int_flag    =  false
   let ws.relogio  =  current hour to second
   display ws.relogio to relogio

   while true    # PSI187143 - robson

      message " Aguarde, pesquisando..."  attribute(reverse)

      let arr_aux = 1

 # PSI187143 - robson - inicio

      if k_ctb25m00.atdsrvnum is null then
          open c_ctb25m00 using k_ctb25m00.periodoini
                              ,k_ctb25m00.periodofim
                              ,k_ctb25m00.anlokaflg
      else
          open c_ctb25m00 using k_ctb25m00.atdsrvnum,
                               k_ctb25m00.atdsrvano
      end if

 # PSI187143 - robson - fim

      foreach c_ctb25m00 into ws.atdsrvnum     ,
                              ws.atdsrvano     ,
                              ws.prsokadat     ,
                              ws.prsokahor     ,
                              ws.incvlr        ,
                              ws.fnlvlr        # PSI187143 - robson

         if ws.c24opemat  is null   then
            let ws.trava  = "-"      #--->  Nao esta' sendo acionado
         else
            let ws.trava  = "*"      #--->  Ja esta' sendo acionado
         end if

         select atdsrvorg, ciaempcod, atdetpcod, cnldat, atdfnlhor,pgtdat       #PSI 205206
           into  ws.atdsrvorg, ws.ciaempcod, ws_atdetpcod, ws_cnldat, ws_atdfnlhor, ws_pgtdat   #PSI 205206
           from datmservico
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano


         #PSI 205206
         if ws.ciaempcod <> k_ctb25m00.ciaempcod then
            #se empresa do servico diferente da empresa solicitada
            continue foreach
         end if

         if ws.atdsrvorg = 9 or ws.atdsrvorg = 13 then
            if param.srvtip <> "RE" then
               continue foreach
            end if
         else
            if param.srvtip <> "AUTO" then
               continue foreach
            end if
         end if

         # consultar enderecos cadastrados no laudo

         let l_sql = 'select cidnom,ufdcod,c24endtip ',
                       'from datmlcl      ',
                      'where atdsrvnum = ?',
                      ' and atdsrvano  = ? '

         prepare pctb25m00012 from l_sql
         declare cctb25m00012 cursor for pctb25m00012

         open cctb25m00012 using ws.atdsrvnum
                                ,ws.atdsrvano

         foreach cctb25m00012 into ws_cidnom
                                  ,ws_ufdcod
                                  ,ws_c24endtip

         if (ws_c24endtip == 1) then
         let ws_percurso =  ws_cidnom[1,15] clipped, "/", ws_ufdcod clipped
         end if

         if (ws_c24endtip == 2) then
             let ws_percurso = ws_percurso clipped,  " -> " , ws_cidnom[1,15] clipped , "/", ws_ufdcod clipped
         end if

         end foreach

         select atdetpdes
           into  ws_atdetpdes
           from datketapa
          where atdetpcod = ws_atdetpcod

         let a_ctb25m00[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                 "/"     ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                 ws.trava ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

         let a_ctb25m00[arr_aux].prsokadat         = ws.prsokadat using "dd/mm/yy"
         let a_ctb25m00[arr_aux].prsokahor         = ws.prsokahor
         let a_ctb25m00[arr_aux].incvlr            = ws.incvlr using "<<<<<<<<<<<<&.&&"
         let a_ctb25m00[arr_aux].fnlvlr            = ws.fnlvlr using "<<<<<<<<<<<<&.&&"
         let a_ctb25m00[arr_aux].etapa             = ws_atdetpcod using "<<<<<<<<<<<&" , "-", ws_atdetpdes clipped
         let a_ctb25m00[arr_aux].srvprsacndat      = ws_cnldat
         let a_ctb25m00[arr_aux].srvprsacnhor      = ws_atdfnlhor
         let a_ctb25m00[arr_aux].percurso          = ws_percurso

         #open  c_datksrvtip using ws.atdsrvorg
         #fetch c_datksrvtip into  a_ctb25m00[arr_aux].srvtipabvdes
         #close c_datksrvtip

         let arr_aux = arr_aux + 1
         if arr_aux  >  1500   then
            error " Limite excedido, tabela de servicos c/ mais de 1500 itens!"
            exit foreach
         end if

      end foreach

      if arr_aux = 1   then
         error " Nao existem servicos pendentes!"
      else
         let w_cont = arr_aux -1
         error " Total de pendencias:", w_cont
      end if

      #-------------------------------------------------------------------
      # Exibe tela com os servicos
      #-------------------------------------------------------------------
      call set_count(arr_aux-1)

      message "(F6)Atualiza (F7)Totais (F8)Seleciona (F9)Libera (CTR-C/F17)Nova Consulta"  #PSI187142 - robson
      display array a_ctb25m00 to s_ctb25m00.*

         on key (interrupt,control-c)
            let int_flag = true
            display " control-c - int_flag: ", int_flag
            exit display

         #-------------------------------------------------------------------
         # Nova consulta
         #-------------------------------------------------------------------
         on key (F6)
            exit display

         #-------------------------------------------------------------------
         # A pagar
         #-------------------------------------------------------------------
         on key (F7)

# PSI187143 - robson - inicio

            call ctb25m00_totais(k_ctb25m00.anlokaflg
                                ,k_ctb25m00.pstcoddig
                                ,k_ctb25m00.periodoini
                                ,k_ctb25m00.periodofim
                                ,k_ctb25m00.crnpgtcod
                                ,param.srvtip)
            exit display

# PSI187143 - robson - fim

         #-------------------------------------------------------------------
         # Seleciona
         #-------------------------------------------------------------------
         on key (F8)
            #PSI 03847 - Inicio
            let l_sql = ' update dbsmsrvacr ',
                        '    set anlinidat = current ',
                        '  where atdsrvnum = ? ',
                        '    and atdsrvano = ? '
            prepare pctb25m0010 from l_sql
            #PSI 03847 - Fim
	          let l_anlokaflg = null
            let arr_aux = arr_curr()
            let g_documento.atdsrvorg = a_ctb25m00[arr_aux].servico[1,2]
            let g_documento.atdsrvnum = a_ctb25m00[arr_aux].servico[4,10]
            let g_documento.atdsrvano = a_ctb25m00[arr_aux].servico[12,13]
            whenever error continue
            execute pctb25m0010 using g_documento.atdsrvnum, g_documento.atdsrvano

	             select anlokaflg
	              into l_anlokaflg
	              from dbsmsrvacr
	           where atdsrvnum = g_documento.atdsrvnum
	                 and atdsrvano = g_documento.atdsrvano

            if sqlca.sqlcode <> 0 then
	             message "Erro anlokaflg sql : ", sqlca.sqlcode
	             exit display
	          end if

            whenever error stop
            call ctb25m01(g_documento.atdsrvnum, g_documento.atdsrvano, l_anlokaflg)
            clear form
            exit display

         #PSI-2013-00430/EV - inicio
         #-------------------------------------------------------------------
         # Libera
         #-------------------------------------------------------------------
    on key (F9)

       let arr_aux = arr_curr()
       let g_documento.atdsrvorg = a_ctb25m00[arr_aux].servico[1,2]
       let g_documento.atdsrvnum = a_ctb25m00[arr_aux].servico[4,10]
       let g_documento.atdsrvano = a_ctb25m00[arr_aux].servico[12,13]
       let ws_pgtdat = null
       let ws_socopgnum = null

            #verificar se ja existe pagamento para servico
       select dbsmopg.socopgnum
	       into ws_socopgnum
	       from dbsmopgitm, dbsmopg
	      where dbsmopgitm.atdsrvnum = g_documento.atdsrvnum
	        and dbsmopgitm.atdsrvano = g_documento.atdsrvano
	        and dbsmopgitm.socopgnum = dbsmopg.socopgnum
	        and dbsmopg.socopgsitcod <> 8

	     if sqlca.sqlcode <> 0     and
	        sqlca.sqlcode <> 100   then
	        error " Erro (", sqlca.sqlcode, ") na leitura da O.P. AVISE A INFORMATICA!"
	     end if

	     if ws_pgtdat     is not null   or
	        ws_socopgnum  is not null   then
	        error " Nao e' possivel fazer a liberacao para servico ja' pago!" sleep 2
	        exit display
	     end if

	     whenever error continue

	     let l_anlokaflg = null

	     select anlokaflg
	       into l_anlokaflg
	       from dbsmsrvacr
	      where atdsrvnum = g_documento.atdsrvnum
	        and atdsrvano = g_documento.atdsrvano

        if sqlca.sqlcode <> 0 then
           message "Erro anlokaflg sql : ", sqlca.sqlcode
           exit display
	      end if


	     whenever error stop

       #fornax jan/2016 - Liberacao por alcada
       let l_pode_liberar = null
	     if l_anlokaflg <> "L" then
	        call ctb25m00_alcada( l_anlokaflg ) returning l_libera, l_msg
       else
          let l_libera = l_anlokaflg

	        if l_anlokaflg = 'L' then
		         let l_pode_liberar = "N"
		            open cctb25m0010
		         foreach cctb25m0010 into l_funmat

		            if l_funmat = g_issk.funmat then
			             let l_pode_liberar = "S"
		               exit foreach
		            end if
		         end foreach

		         if l_pode_liberar = "N" then
		            error 'Voce nao tem alcada para liberar servicos'
		            #clear form
		            #exit display
             else
		            if l_pode_liberar = "S" then
	                 let l_libera = "S"
                   let l_msg = "SERVICO ANALISADO E LIBERADO PARA PAGAMENTO"
                end if
             end if
          end if
       end if

       let l_sql = ' update dbsmsrvacr '
                     ,' set (anlinidat, anlokaflg, anlokadat, anlokahor, '
                          ,' anlusrtip, anlemp, anlmat) '
                       ,' = (current, ?, today, current,?,?,?) '
                   ,' where atdsrvnum = ? '
                     ,' and atdsrvano = ? '

       prepare pctb25m0011 from l_sql

       whenever error continue
       execute pctb25m0011 using l_libera
				                        ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,g_documento.atdsrvnum
                                ,g_documento.atdsrvano
       whenever error stop

       if sqlca.sqlcode <> 0 then
          error 'Erro UPDATE pctb25m0011 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error 'ctb25m00_Libera ' sleep 2
       else
	        #grava quem liberou servico no historico
	        let l_lighorinc = current
	        call ctd07g01_ins_datmservhist(g_documento.atdsrvnum,
	                                       g_documento.atdsrvano,
	                                       g_issk.funmat,
                                         l_msg,
	                                       today,
	                                       l_lighorinc,
	                                       g_issk.empcod,
	                                       g_issk.usrtip)
	             returning l_saida,
	                       l_resposta

	        if l_saida <> 1 then
	           error l_resposta
	        end if

		     if l_pode_liberar = "N" then
		     else
	          error l_msg
	          sleep 1
		     end if
       end if

      exit display

      end display

       if int_flag then
         let int_flag = false
         initialize a_ctb25m00 to null
	       clear form
         exit while
      end if

   end while
 end while

 initialize g_documento.* to null
 close window  w_ctb25m00
 let int_flag = false

end function

#---------------------------------#
function ctb25m00_totais(lr_param)
#---------------------------------#
 define lr_param record
    situacao       like dbsmsrvacr.anlokaflg
   ,pstcoddig      like dpaksocor.pstcoddig
   ,periodoinicial like dbsmsrvacr.prsokadat
   ,periodofinal   like dbsmsrvacr.prsokadat
   ,crnpgtcod      like dpaksocor.crnpgtcod
   ,srvtip         char(05)
 end record

 define lr_aux record
    prsokadat  like dbsmsrvacr.prsokadat
   ,pstcoddig  like dpaksocor.pstcoddig
   ,crnpgtcod  like dpaksocor.crnpgtcod
   ,quantidade integer
 end record

 define l_cont smallint
   ,l_texto    char(75)
   ,l_sql      char(1000)
   ,l_sql_aux  char(300)
   ,l_erro     smallint

 #inicializa variaveis
 initialize lr_aux to null
 let l_cont  = 0
 let l_texto = null
 let l_sql   = null
 let l_erro  = false
 let l_sql_aux = null

 #cria tabela temporaria e index da tabela temporaria

 if m_prepare_sql is null or
    m_prepare_sql <> true then
    call ctb25m00_cria_temp()
    if m_erro = true then
       return
    end if
    call ctb25m00_prepare()
 end if

 #-- Limpa temporaria --#

 whenever error continue
    execute pctb25m00007
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro DELETE pctb25m00007 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais ' sleep 2
 end if

 if lr_param.srvtip = 'RE' then
    let l_sql = l_sql clipped,
                ' and datmservico.atdsrvorg in (9 ,13) '
 else
    let l_sql = l_sql clipped,
                ' and datmservico.atdsrvorg not in (9 ,13) '
 end if
 if lr_param.pstcoddig is not null then
    let l_sql = l_sql clipped,
                ' and dbsmsrvacr.pstcoddig = ', lr_param.pstcoddig ,' '
 end if
 if lr_param.crnpgtcod is not null then
    let l_sql = l_sql clipped,
                ' and dpaksocor.crnpgtcod = ', lr_param.crnpgtcod ,' '
 end if
 let l_sql = l_sql clipped,
             ' group by 1 order by 2 desc '

 let l_sql_aux = l_sql clipped
 let l_sql = null

#Sql principal do total de servicos por data
 let l_sql = ' select prsokadat, count(*) quantidade '
              ,' from dbsmsrvacr '
                  ,' ,dpaksocor '
                  ,' ,datmservico '
             ,' where dpaksocor.pstcoddig = dbsmsrvacr.pstcoddig '
               ,' and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum '
               ,' and dbsmsrvacr.atdsrvano = datmservico.atdsrvano '
               ,' and prsokaflg = "S" '
               ,' and dbsmsrvacr.prsokadat >= ? '
               ,' and dbsmsrvacr.prsokadat <= ? '
               ,' and dbsmsrvacr.anlokaflg  = ? '

 let l_sql = l_sql clipped,
             l_sql_aux clipped

 prepare pctb25m00004 from l_sql
 declare cctb25m00004 cursor for pctb25m00004

 let l_cont = l_cont + 1
 let l_texto = 'Servicos por Data:'

 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 else
    let l_cont = l_cont + 1
    let l_texto = 'Data            Quantidade '
    whenever error continue
       execute pctb25m00003 using l_cont
                                 ,l_texto
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'ctb25m00_totais() ', l_cont, '/'
                                 , l_texto sleep 2
       return
    end if
 end if

 open cctb25m00004 using lr_param.periodoinicial
                        ,lr_param.periodofinal
                        ,lr_param.situacao

 foreach cctb25m00004 into lr_aux.prsokadat
                          ,lr_aux.quantidade
    let l_cont  = l_cont + 1
    let l_texto = lr_aux.prsokadat, '      ',
                  lr_aux.quantidade using '&&&&'
    whenever error continue
       execute pctb25m00003 using l_cont
                                 ,l_texto
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'ctb25m00_totais() ', l_cont, '/'
                                 , l_texto sleep 2
       let l_erro = true
       exit foreach
    end if
 end foreach
 if l_erro then
    return
 end if

 #linha em branco
 let l_cont  = l_cont + 1
 let l_texto = null
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if

#Sql principal do total de servicos por cronograma
 let l_sql = null

 let l_sql = ' select dpaksocor.crnpgtcod, count(*) quantidade '
              ,' from dbsmsrvacr '
                  ,' ,dpaksocor '
                  ,' ,datmservico '
             ,' where dpaksocor.pstcoddig = dbsmsrvacr.pstcoddig '
               ,' and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum '
               ,' and dbsmsrvacr.atdsrvano = datmservico.atdsrvano '
               ,' and prsokaflg = "S" '
               ,' and dbsmsrvacr.prsokadat >= ? '
               ,' and dbsmsrvacr.prsokadat <= ? '
               ,' and dbsmsrvacr.anlokaflg  = ? '

 let l_sql = l_sql clipped,
             l_sql_aux clipped

 prepare pctb25m00005 from l_sql
 declare cctb25m00005 cursor for pctb25m00005

 let l_cont = l_cont + 1
 let l_texto = 'Servicos por Cronograma:'
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if
 let l_cont = l_cont + 1
 let l_texto = 'Cronograma      Quantidade '
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if

 open cctb25m00005 using lr_param.periodoinicial
                        ,lr_param.periodofinal
                        ,lr_param.situacao

 foreach cctb25m00005 into lr_aux.crnpgtcod
                          ,lr_aux.quantidade
    let l_cont  = l_cont + 1
    let l_texto = lr_aux.crnpgtcod  using '&&', '              '
                 ,lr_aux.quantidade using '&&&&'
    whenever error continue
       execute pctb25m00003 using l_cont
                                 ,l_texto
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'ctb25m00_totais() ', l_cont, '/'
                                 , l_texto sleep 2
       let l_erro = true
       exit foreach
    end if
 end foreach
 if l_erro = true then
    return
 end if

 #linha em branco
 let l_cont  = l_cont + 1
 let l_texto = null
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if

#Sql principal do total de servicos por prestador

 let l_sql = null

 let l_sql = ' select dbsmsrvacr.pstcoddig, count(*) quantidade '
              ,' from dbsmsrvacr '
                  ,' ,dpaksocor '
                  ,' ,datmservico '
             ,' where dpaksocor.pstcoddig = dbsmsrvacr.pstcoddig '
               ,' and dbsmsrvacr.atdsrvnum = datmservico.atdsrvnum '
               ,' and dbsmsrvacr.atdsrvano = datmservico.atdsrvano '
               ,' and prsokaflg = "S" '
               ,' and dbsmsrvacr.prsokadat >= ? '
               ,' and dbsmsrvacr.prsokadat <= ? '
               ,' and dbsmsrvacr.anlokaflg  = ? '

 let l_sql = l_sql clipped,
             l_sql_aux clipped

 prepare pctb25m00006 from l_sql
 declare cctb25m00006 cursor for pctb25m00006

 let l_cont = l_cont + 1
 let l_texto = 'Servicos por Prestador:'
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if
 let l_cont = l_cont + 1
 let l_texto = 'Prestador       Quantidade'
 whenever error continue
    execute pctb25m00003 using l_cont
                              ,l_texto
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'ctb25m00_totais() ', l_cont, '/'
                              , l_texto sleep 2
    return
 end if

 open cctb25m00006 using lr_param.periodoinicial
                        ,lr_param.periodofinal
                        ,lr_param.situacao

 foreach cctb25m00006 into lr_aux.pstcoddig
                          ,lr_aux.quantidade
    let l_cont  = l_cont + 1
    let l_texto = lr_aux.pstcoddig  using '&&&&&&', '          '
                 ,lr_aux.quantidade using '&&&&'
    whenever error continue
       execute pctb25m00003 using l_cont
                                 ,l_texto
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error 'Erro INSERT pctb25m00003 / ', sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'ctb25m00_totais() ', l_cont, '/'
                                 , l_texto sleep 2
       let l_erro = true
       exit foreach
    end if
 end foreach
 if l_erro = true then
    return
 end if

 call ctb00g04()

end function

# PSI187143 - robson - fim

#---------------------------
function ctb25m00_alcada( param_anlokaflg )
#---------------------------

   define param_anlokaflg like dbsmsrvacr.anlokaflg

   define l_libera    char(01),
	  l_msg       char(80),
	  l_funmat    dec(6),
	  l_valor_inf dec(12,2),
	  l_valor_srv dec(12,2),
	  l_valor_alc dec(12,2),
	  l_valor_max dec(12,2),
	  l_perc_alc  dec(5,2),
	  l_cod       integer,
	  l_erro      char(80)

   define lr_ret         record
	  result         smallint,
	  mailgicod      like grhkmai.mailgicod,
	  endereco       char(86)
	  end record

   define lr_mail            record
	  de                 char(50)   # De
         ,para               char(800)  # Para
         ,cc                 char(250)   # cc
         ,cco                char(250)   # cco
         ,assunto            char(150)   # Assunto do e-mail
         ,mensagem           char(3200) # Nome do Anexo
         ,id_remetente       char(20)
         ,tipo               char(4)
         end record

   initialize lr_ret.* to null
   initialize lr_mail.* to null

   #let l_libera = "S"
   #let l_msg = "SERVICO ANALISADO E LIBERADO PARA PAGAMENTO"

   let l_libera = param_anlokaflg
   let l_msg = null

   let l_valor_inf = 0
   let l_valor_srv = 0
   let l_valor_alc = 0
   let l_valor_max = 0
   let l_perc_alc = 0

   open cctb25m0008 using g_documento.atdsrvnum, g_documento.atdsrvano
   fetch cctb25m0008 into l_valor_inf, l_valor_srv
   close cctb25m0008

   open cctb25m0009
   foreach cctb25m0009 into l_funmat, l_valor_alc, l_perc_alc

	   let l_valor_max = l_valor_inf + (l_valor_inf * (l_perc_alc/100))

	   if l_valor_srv > l_valor_alc or l_valor_srv > l_valor_max then
	      let l_libera = "L"
	      let l_msg = "VALOR ULTRAPASSOU O LIMITE. LIBERAR POR ALCADA"
	      exit foreach
           end if

   end foreach

   if l_libera = "L" then
      call fgrhc001_mailgicod(g_issk.usrtip, g_issk.empcod, l_funmat)
	   returning lr_ret.*

      let lr_mail.de = "portosocorro@portoseguro.com.br"
      let lr_mail.para =  lr_ret.endereco
      let lr_mail.assunto = "Liberar servico por alcada ",
			   g_documento.atdsrvorg using "&&","-",
			   g_documento.atdsrvnum using "<<<<<<<<<<","/",
			   g_documento.atdsrvano using "&&"
      let lr_mail.mensagem = "A analise do servico no valor de ",
              l_valor_srv using "<<<<<<<<&.&&"," ultrapassou o limite de ",
              l_valor_alc using "<<<<<<<<&.&&"," ou o limite do percentual de ",
              l_perc_alc using "<<&.&&", "%."
      let lr_mail.id_remetente = "PORTOSOCORRO"
      let lr_mail.tipo = "text"

      call figrc009_mail_send1(lr_mail.*)
	   returning l_cod, l_erro

      if l_cod = 0 then
	 error 'Solicitacao de liberacao por alcada com sucesso'
      else
	 error 'Erro no envio do email ', l_cod,' ', l_erro
      end if
   else
       let l_libera = "S"
       let l_msg = "SERVICO ANALISADO E LIBERADO PARA PAGAMENTO"
   end if

   return l_libera, l_msg

end function
