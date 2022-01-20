###############################################################################
# Nome do Modulo: cts00m26                                           Marcus   #
#                                                                    Ruiz     #
# Informacoes sobre a etapa do acionamento via internet              Ago/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts00m26(param)
#-----------------------------------------------------------

 define param       record
    atdetpdes       like datketapa.atdetpdes,
    caddat          like datmsrvint.caddat   ,
    cadhor          datetime hour to minute  ,
    atdetpseq       like datmsrvint.atdetpseq,
    origem          char (50)               ,
    nomgrr          like dpaksocor.nomgrr,
    atdsrvnum       like datmsrvacp.atdsrvnum,
    atdsrvano       like datmsrvacp.atdsrvano
 end record

 define d_cts00m26  record
    atdetpdes       like datketapa.atdetpdes,
    caddat          like datmsrvint.caddat   ,
    cadhor          datetime hour to minute  ,
    origem          char (50)                ,
    funnom          like isskfunc.funnom     ,
    dptsgl          like isskfunc.dptsgl     ,
    nomgrr          like dpaksocor.nomgrr,
    etpmtvdes       like datksrvintmtv.etpmtvdes,
    srvobs          like datmsrvint.srvobs
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define ws          record
    sql             char (400),
    cademp          like isskfunc.empcod,
    cadmat          like isskfunc.funmat,
    etpmtvcod       like datksrvintmtv.etpmtvcod,
    resp            char (01),
    usrcod          like isskusuario.usrcod,
    funnom          like isskfunc.funnom,
    cadusrtip       like datmsrvint.cadusrtip
 end record

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------


	let	arr_aux  =  null
	let	scr_aux  =  null

	initialize  d_cts00m26.*  to  null

	initialize  ws.*  to  null

 initialize d_cts00m26.*   to null
 initialize ws.*           to null

#--------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------

 let ws.sql = "select funnom,dptsgl    ",
              "  from isskfunc  ",
              " where empcod = ?",
              "   and funmat = ?"
 prepare p_cts00m26_001 from ws.sql
 declare c_cts00m26_001 cursor for p_cts00m26_001

 open window cts00m26 at 10,03 with form "cts00m26"
             attribute (border)

 let d_cts00m26.atdetpdes   = param.atdetpdes
 let d_cts00m26.caddat      = param.caddat
 let d_cts00m26.cadhor      = param.cadhor
 let d_cts00m26.origem      = param.origem
 let d_cts00m26.nomgrr      = param.nomgrr

 select cademp   ,cadmat,
        cadusrtip,etpmtvcod,srvobs
   into ws.cademp   , ws.cadmat,
        ws.cadusrtip, ws.etpmtvcod, d_cts00m26.srvobs
   from datmsrvint
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdetpseq = param.atdetpseq

 select etpmtvdes
      into d_cts00m26.etpmtvdes
      from datksrvintmtv
     where etpmtvcod = ws.etpmtvcod

 if ws.cademp = 0 then   # internet
    let ws.cademp = null
 end if
 call F_FUNGERAL_USR(ws.cadmat   ,
                     ws.cademp   ,
                     ws.cadusrtip,
                     "","")
          returning  d_cts00m26.dptsgl,
                     ws.usrcod,
                     ws.funnom,
                     d_cts00m26.funnom    # nome completo

#open c_cts00m26_001 using ws.cademp,ws.cadmat
#fetch c_cts00m26_001 into d_cts00m26.funnom,
#                      d_cts00m26.dptsgl
#close c_cts00m26_001

 display by name d_cts00m26.*
 prompt " Tecle algo para continuar !!! " for ws.resp

 let int_flag = false
 close window cts00m26

end function  ###  cts00m26
