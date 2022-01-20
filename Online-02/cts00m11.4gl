###############################################################################
# Nome do Modulo: CTS00M11                                           Marcelo  #
#                                                                    Gilberto #
# Consulta etapas de acompanhamento de servicos                      Ago/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 14/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------#
# 16/05/2001  PSI 13168-7  Wagner       Adaptacao para servicos de carro-extra#
#-----------------------------------------------------------------------------#
# 23/08/2001  PSI 13622-0  Ruiz         Adaptacao para servico enviado via    #
#                                       internet.                             #
###############################################################################
#                        * * * A L T E R A C A O * * *                        #
#  Analista Resp. : Raji Jahchan                                              #
#  PSI            : 166480 - OSF: 19372                                       #
#.............................................................................#
#  Data        Autor Fabrica  Alteracao                                       #
#  ----------  -------------  ------------------------------------------------#
#  30/05/2003  Gustavo(FSW)   Incluir tecla de funcao (F7)Execucao.           #
#  26/02/2004  Mariana(FSW)   Recupera nome da locadora e loja p/ reserva de  #
#                             veiculo                                         #
#  ----------  -------------  ------------------------------------------------#
#  07/07/2005  Adriano, Meta  Obter servico original e consistir com servico  #
#                             internet                                        #
#  07/11/2005  Ligia Mattge   PSI 195138 - Exibir motivo nao acionado         #
#                                                                             #
###############################################################################

database porto

 define m_cts00m11_prep smallint

#-------------------------#
function cts00m11_prepare()
#-------------------------#

 define l_sql char(200)

 let l_sql = "select 1 "
            ," from datmsrvint "
            ," where atdsrvnum = ? "
              ," and atdsrvano = ? "
              ," and atdetpseq = 1 "
 prepare p_cts00m11_001 from l_sql
 declare c_cts00m11_001 cursor for p_cts00m11_001

 let m_cts00m11_prep = true

end function

#-----------------------------------------------------------
 function cts00m11(param)
#-----------------------------------------------------------

 define param       record
    atdsrvnum       like datmsrvacp.atdsrvnum,
    atdsrvano       like datmsrvacp.atdsrvano
 end record

 define d_cts00m11  record
    srvnum          char (13),
    srvtipdes       like datksrvtip.srvtipdes
 end record

 define a_cts00m11  array[30] of record
    atdetpdes       like datketapa.atdetpdes,
    atdetpdat       like datmsrvacp.atdetpdat,
    atdetphor       like datmsrvacp.atdetphor,
    atdsrvseq       like datmsrvacp.atdsrvseq,
    funnom          like isskfunc.funnom    ,
    nomgrr          like dpaksocor.nomgrr,
    acionado        char(15),
    tentativa       char(18),
    motivo          char(41)
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
    lcvnom          like datklocadora.lcvnom,
    atdprscod       like datmservico.atdprscod,
    nomemp          like adikvdrrpremp.vdrrprempnom,
    srvint          dec (1,0)    # ruiz
 end record

 define m_lcvextcod like datkavislocal.lcvextcod

 define l_atdsrvnum  like datratdmltsrv.atdsrvnum
 define l_atdsrvano  like datratdmltsrv.atdsrvano
 define l_resultado  smallint
 define l_mensagem   char(100)
 define l_acnsttflg  like datmservico.acnsttflg
 define l_acntntqtd  like datmservico.acntntqtd
 define l_acnnaomtv  like datmservico.acnnaomtv
 define l_motivo     char(50),
        l_aa_parado  smallint,
        l_atdfnlflg  like datmservico.atdfnlflg,
        l_primeiro   smallint

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

        let l_acnsttflg  = null
        let l_acntntqtd  = null
        let l_acnnaomtv  = null

	for	w_pf1  =  1  to  30
		initialize  a_cts00m11[w_pf1].*  to  null
	end	for

	initialize  d_cts00m11.*  to  null

	initialize  ws.*  to  null

 initialize a_cts00m11     to null
 initialize d_cts00m11.*   to null
 initialize ws.*           to null
 let l_atdsrvnum = null
 let l_atdsrvano = null
 let l_resultado = null
 let l_mensagem  = null
 let l_motivo    = null
 let l_aa_parado = null
 let l_atdfnlflg = null

#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 let ws.sql = "select funnom    ",
              "  from isskfunc  ",
              " where empcod = ?",
              "   and funmat = ?"
 prepare p_cts00m11_002 from ws.sql
 declare c_cts00m11_002 cursor for p_cts00m11_002

 let ws.sql = "select atdetpdes     ",
              "  from datketapa     ",
              " where atdetpcod = ? "
 prepare p_cts00m11_003 from ws.sql
 declare c_cts00m11_003 cursor for p_cts00m11_003

 let ws.sql = "select nomgrr        ",
              "  from dpaksocor     ",
              " where pstcoddig = ? "
 prepare p_cts00m11_004 from ws.sql
 declare c_cts00m11_004 cursor for p_cts00m11_004

 ## PSI193690 Laudo de Vidros - apresentar Empresas Prestadoras com
 ##           respectivas etapas
 let ws.sql = " select p.vdrrprempnom ",
              " from   adikvdrrpremp p, datmservico o, datmsrvacp c " ,
              " where  o.atdsrvnum    = ? ",
              " and    o.atdsrvano    = ? ",
              " and    o.atdsrvnum    = c.atdsrvnum ",
              " and    o.atdsrvano    = c.atdsrvano ",
              " and    p.vdrrprempcod = c.srrcoddig ",
              " and    c.atdsrvseq    = ?  "

 prepare p_cts00m11_005 from ws.sql
 declare c_cts00m11_005 cursor for p_cts00m11_005
 ## PSI193690

 let ws.sql = " select a.lcvnom,",
              "        b.lcvextcod ",
              "   from datklocadora a,datkavislocal b,datmsrvacp c ",
              "  where a.lcvcod    = c.pstcoddig " ,
              "    and b.lcvcod    = a.lcvcod    " ,
              "    and b.aviestcod = c.srrcoddig " ,
              "    and c.atdsrvnum = ? ",
              "    and c.atdsrvano = ? ",
              "    and c.atdsrvseq = ? "

 prepare p_cts00m11_006 from ws.sql
 declare c_cts00m11_006 cursor for p_cts00m11_006

#--------------------------------------------------------------------
# Cabecalho
#--------------------------------------------------------------------

 if m_cts00m11_prep is null or
    m_cts00m11_prep <> true then
    call cts00m11_prepare()
 end if

 ## psi 195138 - Obter as informacoes do servico
 select atdsrvorg, atdprscod, acnsttflg, acntntqtd, acnnaomtv, atdfnlflg
   into ws.atdsrvorg, ws.atdprscod, l_acnsttflg, l_acntntqtd, l_acnnaomtv,
        l_atdfnlflg
   from datmservico
  where atdsrvnum = param.atdsrvnum  and
        atdsrvano = param.atdsrvano

 let d_cts00m11.srvnum = ws.atdsrvorg    using "&&", "/",
                         param.atdsrvnum using "&&&&&&&", "-",
                         param.atdsrvano using "&&"

 let d_cts00m11.srvtipdes = "*** NAO CADASTRADO! ***"

 select srvtipdes
   into d_cts00m11.srvtipdes
   from datksrvtip
  where atdsrvorg = ws.atdsrvorg

 select atdsrvnum   # ruiz
   from datmsrvint
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdetpseq = 1
 if sqlca.sqlcode =  0  then
    let ws.srvint =  1
 else
    if ws.atdsrvorg = 9 then
       call cts29g00_consistir_multiplo(param.atdsrvnum, param.atdsrvano)
          returning l_resultado
                   ,l_mensagem
                   ,l_atdsrvnum
                   ,l_atdsrvano
       if l_resultado = 3 then
          error l_mensagem
       end if
       if l_resultado = 1 then
          #let param.atdsrvnum = l_atdsrvnum
          #let param.atdsrvano = l_atdsrvano
          open c_cts00m11_001 using l_atdsrvnum
                                 ,l_atdsrvano
          whenever error continue
          fetch c_cts00m11_001
          whenever error stop
          if sqlca.sqlcode = 0 then
             let ws.srvint = 1
          else
             if sqlca.sqlcode < 0 then
                error 'Erro SELECT c_cts00m11_001 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
                return
             end if
          end if
       end if
    end if
 end if

 call cts40g12_ver_aa(ws.atdsrvorg)
       returning l_aa_parado, l_motivo

 if l_atdfnlflg = "A" and l_aa_parado = true then ##Se estiver parado
    let a_cts00m11[1].motivo= l_motivo
 end if

 open window cts00m11 at 05,02 with form "cts00m11"
             attribute (form line first)

 display by name d_cts00m11.*

 if ws.atdsrvorg = 8 then  # servicos carro-extra
    select datklocadora.lcvnom
      into ws.lcvnom
      from datmavisrent, datklocadora
     where datmavisrent.atdsrvnum = param.atdsrvnum
       and datmavisrent.atdsrvano = param.atdsrvano
       and datklocadora.lcvcod    = datmavisrent.lcvcod
 end if

 if ws.atdsrvorg = 14 then
    select vdrrprgrpnom
      into ws.nomemp
      from adikvdrrprgrp
     where vdrrprgrpcod = ws.atdprscod
 end if

 declare  c_cts00m11  cursor for
    select atdetpcod, atdetpdat,
           atdetphor, empcod   ,
           funmat   , pstcoddig,
           atdsrvseq
      from datmsrvacp
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
     order by atdsrvseq

 let arr_aux = 1
 let l_primeiro = true

 foreach  c_cts00m11  into  ws.atdetpcod,
                            a_cts00m11[arr_aux].atdetpdat,
                            a_cts00m11[arr_aux].atdetphor,
                            ws.empcod, ws.funmat,
                            ws.pstcoddig,
                            a_cts00m11[arr_aux].atdsrvseq

      if ws.funmat = 999999 then
         let a_cts00m11[arr_aux].funnom = "PROCESSO AUTOMATICO"
      else
         if ws.funmat = 999998 then
            let a_cts00m11[arr_aux].funnom = "PRESTADOR INTERNET"
         else
            let a_cts00m11[arr_aux].funnom = "** NAO CADASTRADO **"

            open  c_cts00m11_002 using ws.empcod, ws.funmat
            fetch c_cts00m11_002 into  a_cts00m11[arr_aux].funnom
            close c_cts00m11_002
            let a_cts00m11[arr_aux].funnom = upshift(a_cts00m11[arr_aux].funnom)
         end if

      end if

      let a_cts00m11[arr_aux].atdetpdes = "NAO CADASTRADA"

      open  c_cts00m11_003 using ws.atdetpcod
      fetch c_cts00m11_003 into  a_cts00m11[arr_aux].atdetpdes
      close c_cts00m11_003

      if ws.atdsrvorg = 8 then  # servicos carro-extra
         let ws.lcvnom = null
         let m_lcvextcod = null
         whenever error continue
         open c_cts00m11_006 using param.atdsrvnum
                                ,param.atdsrvano
                                ,a_cts00m11[arr_aux].atdsrvseq
         fetch c_cts00m11_006 into ws.lcvnom
                                ,m_lcvextcod
         whenever error stop

         if sqlca.sqlcode < 0 then
            error "Problemas de acesso a tabela DATKLOCADORA", sqlca.sqlcode
            sleep 1
            exit foreach
         end if
         let a_cts00m11[arr_aux].nomgrr = ws.lcvnom[1,13], '/',
                                          m_lcvextcod

      else
         if ws.atdsrvorg = 14 then # servicos de vidros
               open  c_cts00m11_005 using param.atdsrvnum,
                                           param.atdsrvano,
                                           a_cts00m11[arr_aux].atdsrvseq
               fetch c_cts00m11_005 into  ws.nomemp    ##a_cts00m11[arr_aux].nomgrr
               close c_cts00m11_005
            let a_cts00m11[arr_aux].nomgrr = ws.nomemp
         else
            open  c_cts00m11_004 using ws.pstcoddig
            fetch c_cts00m11_004 into  a_cts00m11[arr_aux].nomgrr
            close c_cts00m11_004
         end if
      end if

      ##psi 195138 - Exibir informacoes do nao acionado automatico
      if l_primeiro and ws.atdetpcod = 1 and
         (l_acnsttflg = 'S' or l_acnsttflg = 'N') then
         let a_cts00m11[arr_aux].acionado = 'Acio.Auto: ', l_acnsttflg
         ##let a_cts00m11[arr_aux].tentativa= 'Qtd.Tent: ',l_acntntqtd using "<<<" ##ligia 27/12/06
         let l_primeiro = false
         if l_acnnaomtv is not null and a_cts00m11[arr_aux].motivo is null then
            let a_cts00m11[arr_aux].motivo= 'Mot: ',l_acnnaomtv clipped
         end if
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 30  then
         error " Limite excedido. Servico possui mais de 30 etapas",
               " de acompanhamento!"
         exit foreach
      end if
 end foreach

 if arr_aux > 1  then
    if ws.atdsrvorg = 8  or    # servicos carro-extra
       ws.atdsrvorg = 14 then
       message " (F17)Abandona, (F8)Prestador, (F9)Internet"
    else
       if ws.srvint = 1  then    #ruiz  # servico acionado via internet
          message " (F17)Abandona, (F7)Execucao, (F8)Prestador, (F9)Internet, (F10)Transmissoes"
       else
          message " (F17)Abandona, (F7)Execucao, (F8)Prestador, (F10)Transmissoes"
       end if
    end if
    call set_count(arr_aux-1)

    let arr_aux = arr_curr()
    let scr_aux = scr_line()
    display array a_cts00m11 to s_cts00m11.*
       on key(interrupt, control-c)
          exit display

       on key (F10)
          call ctn43c00(param.atdsrvnum, param.atdsrvano)

       on key (F8)
          let arr_aux = arr_curr()
          if ws.atdsrvorg <> 14 then
             call cts00m12(param.atdsrvnum, param.atdsrvano,
                           a_cts00m11[arr_aux].atdsrvseq)
          end if

       on key (F9)   # ruiz
          call cts00m25(param.atdsrvnum, param.atdsrvano)

       on key (F7)
          call cts00m35(param.atdsrvnum, param.atdsrvano)

    end display
 else
    error " Nao existem etapas cadastradas para este servico!"
 end if

 let int_flag = false
 close window cts00m11

end function  ###  cts00m11
