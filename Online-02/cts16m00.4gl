#############################################################################
# Nome do Modulo: CTS16M00                                            Pedro #
#                                                                   Marcelo #
# Localiza Laudo de Servico                                        Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI        Alteracao                             #
# ---------- ------------- ---------  --------------------------------------#
# 18/09/2003 Julianna,Meta PSI175552  Na chamada da funcao cts16m01 passar  #
#                          OSF26077   como parametro a variavel glogbal     #
#                                     g_documento.c24astcod                 #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts16m00()
#------------------------------------------------------------

 define d_cts16m00    record
    atdorigem         like datmservico.atdsrvorg  ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atddat            like datmservico.atddat     ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    vcllicnum         like datmservico.vcllicnum  ,
    nome              char (30)
 end record

 define a_cts16m00 array[400] of record
    servico2          char (13)                   ,
    nom               like datmservico.nom        ,
    sitdes            char (14)                   ,
    srvtipdes         like datksrvtip.srvtipabvdes,
    vcldes            like datmservico.vcldes     ,
    vcllicnum2        like datmservico.vcllicnum
 end record

 define arr_aux       smallint
 define scr_aux       smallint

 define ws            record
    acao              char (03)                 ,
    nome              char (15)                 ,
    total             char (10)                 ,
    comando1          char (800)                ,
    comando2          char (200)                ,
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdfnlflg         like datmservico.atdfnlflg,
    atdetpcod         like datmsrvacp.atdetpcod
 end record

 define l_acesso smallint
 define l_query  char(50)


#----------------------------------------
# PREPARA COMANDO SQL
#----------------------------------------

	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let     l_acesso =  null
	let     l_query  =  null

	for	w_pf1  =  1  to  400
		initialize  a_cts16m00[w_pf1].*  to  null
	end	for

	initialize  d_cts16m00.*  to  null

	initialize  ws.*  to  null

 let ws.comando1 = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare p_cts16m00_001 from ws.comando1
 declare c_cts16m00_001 cursor for p_cts16m00_001

 let ws.comando1 = "select atdetpdes    ",
                   "  from datketapa    ",
                   " where atdetpcod = ?"
 prepare p_cts16m00_002 from ws.comando1
 declare c_cts16m00_002 cursor for p_cts16m00_002


 open window w_cts16m00 at 06,02 with form "cts16m00"
                        attribute(form line first)

 display "/" at 02,13
 display "-" at 02,21

 while true

    initialize ws.*          to null
    initialize a_cts16m00    to null
    let int_flag = false
    let arr_aux  = 1

    input by name d_cts16m00.*


       before field atdsrvnum
              call ctc62m00_recupera_empresa(g_issk.funmat,
                                             g_issk.empcod)
              returning l_acesso, l_query
              if l_acesso = false then
                 next field atddat
              end if
              display by name d_cts16m00.atdsrvnum  attribute (reverse)

       after  field atdsrvnum
              display by name d_cts16m00.atdsrvnum

              if  fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field atdsrvnum
              end if

       before field atdsrvano
              display by name d_cts16m00.atdsrvano  attribute (reverse)

       after  field atdsrvano
              display by name d_cts16m00.atdsrvano

              if  fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field atdsrvnum
              end if

              if d_cts16m00.atdsrvnum  is not null   and
                 d_cts16m00.atdsrvano  is not null   then
                 select atdsrvorg
                   into ws.atdsrvorg
                   from DATMSERVICO
                        where atdsrvnum = d_cts16m00.atdsrvnum
                          and atdsrvano = d_cts16m00.atdsrvano
                 let d_cts16m00.atdorigem = ws.atdsrvorg
                 display by name d_cts16m00.atdorigem
                 exit input
              end if

       before field atddat
              display by name d_cts16m00.atddat    attribute (reverse)

              let d_cts16m00.atddat = today

       after  field atddat
              display by name d_cts16m00.atddat

              if d_cts16m00.atddat  is null   then
                 error " Data de atendimento do servico deve ser informada!"
                 next field atddat
              end if

       before field atdsrvorg
              initialize d_cts16m00.srvtipabvdes to null
              display by name d_cts16m00.srvtipabvdes
              display by name d_cts16m00.atdsrvorg  attribute (reverse)

       after  field atdsrvorg
              display by name d_cts16m00.atdsrvorg

              if d_cts16m00.atdsrvorg  is null  then
                 let d_cts16m00.srvtipabvdes = "TODOS"
              else
                 select srvtipabvdes
                   into d_cts16m00.srvtipabvdes
                   from datksrvtip
                  where atdsrvorg = d_cts16m00.atdsrvorg

                 if sqlca.sqlcode = notfound  then
                    error " Tipo de servico invalido!"
                    call cts00m09() returning d_cts16m00.atdsrvorg
                    next field atdsrvorg
                 end if
              end if

              display by name d_cts16m00.srvtipabvdes

       before field vcllicnum
              display by name d_cts16m00.vcllicnum attribute (reverse)

       after  field vcllicnum
              display by name d_cts16m00.vcllicnum

              if fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 if not srp1415(d_cts16m00.vcllicnum)  then
                    error " Placa invalida!"
                    next field vcllicnum
                 end if
              end if

              if d_cts16m00.vcllicnum  is not null   then
                 initialize d_cts16m00.nome   to null
                 exit input
              end if

       before field nome
              display by name d_cts16m00.nome    attribute (reverse)

       after field nome
              display by name d_cts16m00.nome

              initialize ws.nome  to null
              if d_cts16m00.nome  is not null   then
                 let ws.nome = d_cts16m00.nome clipped, "*"
              end if

       on key (interrupt)
              exit input

    end input

    if int_flag   then
       exit while
    end if

    if d_cts16m00.atdsrvnum is not null   then
          let ws.comando2 = "  from datmservico ",
                            " where datmservico.atdsrvnum = ? and ",
                            "       datmservico.atdsrvano = ?     "
    else
       if d_cts16m00.nome   is not null   then
          if d_cts16m00.atdsrvorg is not null   then
                let ws.comando2 = "  from datmservico ",
                                  " where datmservico.atddat = ?    and ",
                                  "       datmservico.atdsrvorg = ? and ",
                                  "       datmservico.nom matches '", ws.nome, "'"
          else
                let ws.comando2 = "  from datmservico ",
                                  " where datmservico.atddat = ?    and ",
                                  "       datmservico.atdsrvorg <> 10 and ",
                                  "       datmservico.atdsrvorg <> 12 and ",
                                  "       datmservico.nom matches '", ws.nome, "'"
          end if
       else
          if d_cts16m00.vcllicnum  is not null   then
             if d_cts16m00.atdsrvorg is not null   then
                   let ws.comando2 = "  from datmservico ",
                                     " where datmservico.atddat = ?    and ",
                                     "       datmservico.atdsrvorg = ? and ",
                                     "       datmservico.vcllicnum = ?     "
             else
                   let ws.comando2 = "  from datmservico ",
                                     " where datmservico.atddat = ?    and ",
                                     "       datmservico.atdsrvorg <> 10 and ",
                                     "       datmservico.atdsrvorg <> 12 and ",
                                     "       datmservico.vcllicnum = ?     "
             end if
          else
             if d_cts16m00.atdsrvorg is not null   then
                   let ws.comando2 = "  from datmservico ",
                                     " where datmservico.atddat = ?    and ",
                                     "       datmservico.atdsrvorg = ?     "
             else
                   let ws.comando2 = "  from datmservico ",
                                     " where datmservico.atddat = ?    and ",
                                     "       datmservico.atdsrvorg <> 10 and ",
                                     "       datmservico.atdsrvorg <> 12     "
             end if
          end if
       end if
    end if

    let ws.comando1 = " select                 ",
                      " datmservico.atdsrvorg, ",
                      " datmservico.atdsrvnum, ",
                      " datmservico.atdsrvano, ",
                      " datmservico.nom      , ",
                      " datmservico.vcldes   , ",
                      " datmservico.vcllicnum, ",
                      " datmservico.atdfnlflg  ",
                      ws.comando2 clipped
      call ctc62m00_recupera_empresa(g_issk.funmat,
                                     g_issk.empcod)
      returning l_acesso, l_query
      if l_acesso = true then
        let ws.comando1 = ws.comando1 clipped,
                          " and datmservico.ciaempcod in ", l_query clipped
      end if

    message " Aguarde, pesquisando..."  attribute(reverse)
    prepare comando_aux from ws.comando1
    declare c_cts16m00 cursor for comando_aux

    let ws.comando1 = "select srvtipabvdes",
                      "  from datksrvtip  ",
                      " where atdsrvorg = ?  "

    prepare sel_datksrvtip from ws.comando1
    declare c_datksrvtip cursor for sel_datksrvtip

    if d_cts16m00.atdsrvnum  is not null   then
          open c_cts16m00  using d_cts16m00.atdsrvnum,
                                 d_cts16m00.atdsrvano
    else
       if d_cts16m00.vcllicnum  is not null   then
          if d_cts16m00.atdsrvorg  is not null   then
                open c_cts16m00  using d_cts16m00.atddat   ,
                                       d_cts16m00.atdsrvorg,
                                       d_cts16m00.vcllicnum
          else
                open c_cts16m00  using d_cts16m00.atddat,
                                       d_cts16m00.vcllicnum
          end if
       else
          if d_cts16m00.nome  is not null   then
             if d_cts16m00.atdsrvorg  is not null   then
                   open c_cts16m00  using d_cts16m00.atddat   ,
                                          d_cts16m00.atdsrvorg
             else
                   open c_cts16m00  using d_cts16m00.atddat
             end if
          else
             if d_cts16m00.atdsrvorg  is not null   then
                 open c_cts16m00  using d_cts16m00.atddat,
                                        d_cts16m00.atdsrvorg
             else
                 open c_cts16m00  using d_cts16m00.atddat
             end if
          end if
       end if
    end if

    foreach  c_cts16m00  into  ws.atdsrvorg                  ,
                               ws.atdsrvnum                  ,
                               ws.atdsrvano                  ,
                               a_cts16m00[arr_aux].nom       ,
                               a_cts16m00[arr_aux].vcldes    ,
                               a_cts16m00[arr_aux].vcllicnum2,
                               ws.atdfnlflg

       let a_cts16m00[arr_aux].servico2 =  ws.atdsrvorg using "&&",
                                      "/", ws.atdsrvnum using "&&&&&&&",
                                      "-", ws.atdsrvano using "&&"

       open  c_cts16m00_001 using ws.atdsrvnum, ws.atdsrvano,
                                ws.atdsrvnum, ws.atdsrvano
       fetch c_cts16m00_001 into  ws.atdetpcod
       close c_cts16m00_001

       if sqlca.sqlcode = 0  then
          open  c_cts16m00_002 using ws.atdetpcod
          fetch c_cts16m00_002 into  a_cts16m00[arr_aux].sitdes
          close c_cts16m00_002
         else
          let a_cts16m00[arr_aux].sitdes = "N/PREVISTO"
       end if

       let a_cts16m00[arr_aux].srvtipdes = "NAO PREV."

       open  c_datksrvtip using ws.atdsrvorg
       fetch c_datksrvtip into a_cts16m00[arr_aux].srvtipdes
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

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)

    message " (F17)Abandona, (F8)ALT, REC, CAN, RET, CON, IND"

    call set_count(arr_aux-1)

    display array  a_cts16m00 to s_cts16m00.*
       on key (interrupt)
          initialize ws.total to null
          display by name ws.total
          exit display

       on key (F8)    ###  Alteracao,Reclamacao,Cancelamento,Retorno,
                      ###  Consuta e Indicacao oficina
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

          let ws.atdsrvnum = a_cts16m00[arr_aux].servico2[04,10]
          let ws.atdsrvano = a_cts16m00[arr_aux].servico2[12,13]

          display a_cts16m00[arr_aux].servico2  to
                  s_cts16m00[scr_aux].servico2  attribute(reverse)

          call cts16m01("", "", ws.atdsrvnum, ws.atdsrvano, g_documento.c24astcod)  ## PSI 175552

          display a_cts16m00[arr_aux].servico2  to
                  s_cts16m00[scr_aux].servico2

    end display

    for scr_aux = 1 to 4
       clear s_cts16m00[scr_aux].servico2
       clear s_cts16m00[scr_aux].srvtipdes
       clear s_cts16m00[scr_aux].nom
       clear s_cts16m00[scr_aux].sitdes
       clear s_cts16m00[scr_aux].vcldes
       clear s_cts16m00[scr_aux].vcllicnum2
    end for

 end while

 let int_flag = false
 close window w_cts16m00

end function  ###  cts16m00
