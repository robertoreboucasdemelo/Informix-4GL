#############################################################################
# Menu de Modulo: CTS10M00                                         Marcelo  #
#                                                                  Gilberto #
# Implementacao de Dados no Historico do Servico                   Jan/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 16/09/1999  PSI 9119-7   Wagner       Incluir padronizacao da gravacao do #
#                                       historico.                          #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 05/07/2002  PSI 15424-5  Ruiz         Grava historico atraves da tabela   #
#                                       temporaria criada no mudulo cta02m00#
#---------------------------------------------------------------------------#
# 25/10/2002  PSI 10763-9  Ruiz         Grava historico na base de sinistro #
#                                       quando for servico de furto/roubo.  #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 25/09/06    Ligia Mattge        PSI 202720   Chamar cta01m12              #
#---------------------------------------------------------------------------#
# 16/11/06    Ligia Mattge        PSI 205206   ciaempcod                    #
#---------------------------------------------------------------------------#
# 03/11/2010  PSI 000762 Carla Rampazzo Tratamento p/ Help Desk Casa        #
#############################################################################


globals '/homedsa/projetos/geral/globals/glct.4gl'


 define ws         record
    ligdat         like datmservico.atddat     ,
    lighor         like datmservico.atdhor     ,
    funmat         like datmservhist.c24funmat ,
    c24srvdsc      like datmservhist.c24srvdsc ,
    histerr        smallint,
    prpflg         char(1),
    srvnome        char(50),
    srvjustif      char(55),
    atdsrvorg      like datmservico.atdsrvorg,
    tabname        char(10),
    sqlcode        integer,
    ciaempcod      like datmservico.ciaempcod,
    flag_acesso    smallint
 end record

#---------------------------------------------------------------
 function cts10m00(k_cts10m00)
#---------------------------------------------------------------

 define k_cts10m00 record
    atdsrvnum      like datmservhist.atdsrvnum ,
    atdsrvano      like datmservhist.atdsrvano ,
    funmat         like datmservhist.c24funmat ,
    data           like datmservico.atddat     ,
    hora           like datmservico.atdhor
 end record

 define a_cts10m00 array[200] of record
    c24srvdsc      like datmservhist.c24srvdsc
 end record

 define w_retorno    record
        succod       like datksegsau.succod,
        ramcod       like datksegsau.ramcod,
        aplnumdig    like datksegsau.aplnumdig,
        crtsaunum    like datksegsau.crtsaunum,
        bnfnum       like datksegsau.bnfnum
 end record

 define arr_aux    smallint
 define scr_aux    smallint
 define aux_times    char(11)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	aux_times  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts10m00[w_pf1].*  to  null
	end	for

 initialize  w_retorno.* to null

 if k_cts10m00.data is null then
    let aux_times = time
    let ws.lighor = aux_times[1,5]
    let ws.ligdat = today
    let ws.funmat = g_issk.funmat
 else
    let ws.lighor = k_cts10m00.hora
    let ws.ligdat = k_cts10m00.data
    let ws.funmat = k_cts10m00.funmat
 end if

 let ws.flag_acesso = cta00m06(g_issk.dptsgl)
 let g_horario.lighorinc = ws.lighor

 if g_documento.c24astcod <> "S68" then
    call cts10m00_tab_temp(k_cts10m00.*)  # tabela criada no modulo cta02m00
 end if

 select atdsrvorg, ciaempcod
      into ws.atdsrvorg, ws.ciaempcod
      from datmservico
     where atdsrvnum = k_cts10m00.atdsrvnum
       and atdsrvano = k_cts10m00.atdsrvano

 select edsnumref
      into g_documento.edsnumref
      from datrservapol
     where atdsrvnum = k_cts10m00.atdsrvnum
       and atdsrvano = k_cts10m00.atdsrvano

 let arr_aux = 1

 call cty40g00_grava_historico_servico(k_cts10m00.atdsrvnum, k_cts10m00.atdsrvano,1)
 while true
    let int_flag = false

    call set_count(arr_aux - 1)

    options insert key F35,
            delete key F36

    input array a_cts10m00 without defaults from s_cts10m00.*
       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before insert
          initialize a_cts10m00[arr_aux].c24srvdsc  to null

          display a_cts10m00[arr_aux].c24srvdsc  to
                  s_cts10m00[scr_aux].c24srvdsc

       before field c24srvdsc
          display a_cts10m00[arr_aux].c24srvdsc to
                  s_cts10m00[scr_aux].c24srvdsc attribute (reverse)

       after field c24srvdsc
          display a_cts10m00[arr_aux].c24srvdsc to
                  s_cts10m00[scr_aux].c24srvdsc

          if fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("up")    then
             error " Alteracoes e/ou correcoes nao sao permitidas!"
             next field c24srvdsc
          else
             if a_cts10m00[arr_aux].c24srvdsc is null  or
                a_cts10m00[arr_aux].c24srvdsc =  "  "  then
                error " Complemento deve ser informado!"
                next field c24srvdsc
             end if
          end if

       on key (F1)
          if g_documento.c24astcod is not null then
             call ctc58m00_vis(g_documento.c24astcod)
          end if

       on key (F5)

{
          if (g_documento.succod    is not null  and
              g_documento.ramcod    is not null  and
              g_documento.aplnumdig is not null) or
              g_documento.crtsaunum is not null  then
             if g_documento.ramcod = 31   or
                g_documento.ramcod = 531  then
                call cta01m00()
             else
                if g_documento.crtsaunum is not null then
                   call cta01m13(g_documento.crtsaunum,"","","")
                            returning w_retorno.succod,
                                      w_retorno.ramcod,
                                      w_retorno.aplnumdig,
                                      w_retorno.crtsaunum,
                                      w_retorno.bnfnum     # espelho saude
                else
                   call cta01m20()  # espelho RE
                end if
             end if
          else
             if g_documento.prporg    is not null  and
                g_documento.prpnumdig is not null  then
                call opacc149(g_documento.prporg, g_documento.prpnumdig)
                     returning ws.prpflg
             else
                if g_documento.pcacarnum is not null  and
                   g_documento.pcaprpitm is not null  then
                   call cta01m50(g_documento.pcacarnum, g_documento.pcaprpitm)
                else
                   error " Espelho so' com documento localizado!"
                end if
             end if
          end if
}

          if ws.flag_acesso <> 0 then
          let g_monitor.horaini = current ## Flexvision
          call cta01m12_espelho(g_documento.ramcod
                               ,g_documento.succod
                               ,g_documento.aplnumdig
                               ,g_documento.itmnumdig
                               ,g_documento.prporg
                               ,g_documento.prpnumdig
                               ,g_documento.fcapacorg
                               ,g_documento.fcapacnum
                               ,g_documento.pcacarnum
                               ,g_documento.pcaprpitm
                               ,g_ppt.cmnnumdig
                               ,g_documento.crtsaunum
                               ,g_documento.bnfnum
                               ,ws.ciaempcod)   #psi 205206
          else
             error "Funcao nao disponivel......"  sleep 3
          end if

       on key (interrupt)
          exit input

#      on key (up)
#         error " Alteracoes/Correcoes nao sao permitidas!"
#         next field c24srvdsc

       after row
          #--------------------------------------------------------------------
          # Grava HISTORICO do servico
          #--------------------------------------------------------------------
          call cts10g02_historico(k_cts10m00.atdsrvnum, k_cts10m00.atdsrvano,
                                  ws.ligdat           , ws.lighor           ,
                                  ws.funmat           ,
                                  a_cts10m00[arr_aux].c24srvdsc,"","","","")
                        returning ws.histerr

          if ws.histerr <> 0  then
             error "Erro (", ws.histerr, ") na inclusao do historico. ",
                   "Favor re-digitar a linha."
             next field c24srvdsc
          end if
          if ws.atdsrvorg = 11  then # aviso de furto/roubo
             call ssmatades030_ins (k_cts10m00.atdsrvnum,
                                    k_cts10m00.atdsrvano,
                                    "D",
                                    a_cts10m00[arr_aux].c24srvdsc,
                                    g_issk.funmat,
                                    arr_aux)
                     returning ws.sqlcode
          end if
          whenever error stop
          initialize g_documento.acao to null
    end input
    if int_flag  then
       exit while
    end if
 end while

 let int_flag = false

 clear form

 end function  ###  cts10m00
#---------------------------------------------------------------------------
 function cts10m00_tab_temp(param)
#---------------------------------------------------------------------------
   define param record
      atdsrvnum      like datmservhist.atdsrvnum ,
      atdsrvano      like datmservhist.atdsrvano ,
      funmat         like datmservhist.c24funmat ,
      data           like datmservico.atddat     ,
      hora           like datmservico.atdhor
   end record



   whenever error continue
   select srvnome,
          srvjustif
      into ws.srvnome,
           ws.srvjustif
      from tmp_autorizasrv
     where srvfunmat = g_issk.funmat
       and srvempcod = g_issk.empcod
       and srvmaqsgl = g_issk.maqsgl
   whenever error stop
   if sqlca.sqlcode =  0 then
      if ws.srvnome is not null then
         let ws.c24srvdsc = "Nome autorizou: ",ws.srvnome clipped
         call cts10g02_historico(param.atdsrvnum, param.atdsrvano,
                                 ws.ligdat      , ws.lighor      ,
                                 ws.funmat      ,
                                 ws.c24srvdsc   ,"","","","")
                      returning ws.histerr
      end if
      if ws.srvjustif is not null then
         let ws.c24srvdsc = "Justificativa: ",ws.srvjustif clipped
         call cts10g02_historico(param.atdsrvnum, param.atdsrvano,
                                 ws.ligdat      , ws.lighor      ,
                                 ws.funmat      ,
                                 ws.c24srvdsc   ,"","","","")
                      returning ws.histerr
      end if
   end if
 end function
