#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                                          #
#.............................................................................#
#  Sistema        : Central 24 horas                                          #
#  Modulo         : ctx26g00.4gl                                              #
#                   Preparar informacoes para consultar ligacoes de uma apolic#
#                   ou chamar um laudo quando o solicitante é uma outra area  #
#  Analista Resp. : Priscila /Ruiz                                            #
#  PSI            : 199850 - Registro de ligacoes Sinistro RE                 #
#.............................................................................#
#  Desenvolvimento:                                                           #
#  Liberacao      : Jun/2006                                                  #
#.............................................................................#
###############################################################################
# Alteracoes:                                                                 #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

function ctx26g00(l_texto)
  define l_texto   char(100)
  define lr_CHist record
    succod       like datrligapol.succod
   ,ramcod       like datrligapol.ramcod
   ,aplnumdig    like datrligapol.aplnumdig
   ,itmnumdig    like datrligapol.itmnumdig
   ,prporg       like datrligprp.prporg
   ,prpnumdig    like datrligprp.prpnumdig
   ,fcapacorg    like datrligpac.fcapacorg
   ,fcapacnum    like datrligpac.fcapacnum
   ,apoio        char(01)
   ,corsus       like datrligcor.corsus
   ,cgccpfnum    like gsakseg.cgccpfnum
   ,cgcord       like gsakseg.cgcord
   ,cgccpfdig    like gsakseg.cgccpfdig
   ,funmat       like datmligacao.c24funmat
   ,ctttel       like datmreclam.ctttel
   ,cmnnumdig    like pptmcmn.cmnnumdig
   ,solnom       char(15)
   ,c24soltipcod like datmligacao.c24soltipcod
   ,empcodatd    like datmligatd.apoemp
   ,funmatatd    like datmligatd.apomat
   ,crtsaunum    like datksegsau.crtsaunum
   ,bnfnum       like datksegsau.bnfnum
   ,ramgrpcod    like gtakram.ramgrpcod
  end record
  define lr_cta02m13 record
      prgcod              like datkassunto.prgcod
     ,atdsrvorg           like datmservico.atdsrvorg
     ,aplflg              char(01)
     ,docflg              char(01)
     ,webrlzflg           like datkassunto.webrlzflg
  end record
  define l_assunto like datkassunto.c24astcod,
         l_ret     smallint,
         l_lignum  like datmligacao.lignum,
         l_sql     char(100),
         l_auxtxt  char(50),
         l_aux     smallint,
         l_aux2    smallint
  initialize lr_CHist to null
  initialize lr_cta02m13 to null
  let l_assunto = null
  let l_ret = 0
  let l_lignum = null
  let l_auxtxt = null
  let l_aux = 0
  let l_aux2 = 0
  let l_sql = "select prgcod from datkassunto ",
              " where c24astcod = ? "
  prepare ptx26g00001 from l_sql
  declare ctx26g00001 cursor for ptx26g00001
  #PSI 199850 - sistema do RE ira chamar o programa ctg2, este ira identificar
  # que esta sendo solicitado a visualizacao de todas as ligacoes da apolice
  # (CHist) ou a solicitação de um preenchimento de laudo (Laudo)

  if l_texto[1,5] = "CHist" then
     #caso a chave de solicitação é CHist
     # exibir todas as ligacoes da apolice
     let lr_CHist.succod    =  l_texto[6,7]
     let lr_CHist.ramcod    =  l_texto[8,10]
     let lr_CHist.aplnumdig =  l_texto[11,19]
     let lr_CHist.itmnumdig =  l_texto[20,26]
     call cta02m02_consultar_ligacoes(lr_CHist.*)
  else
     #caso a chave de solicitação é "Laudo"
     # verificar o assunto e chamar função que localiza laudo
     let l_assunto = l_texto[6,8]
     if l_assunto = "P10" then
        #prepara globais utilizadas pelo laudo cts04m00
        let g_documento.atdsrvnum    = null
        let g_documento.atdsrvano    = null
        let g_documento.acao         = null
        let g_documento.soltip       = null
        let g_documento.pcacarnum    = null
        let g_documento.pcaprpitm    = null
        let g_documento.fcapacorg    = null
        let g_documento.fcapacnum    = null
        let g_documento.prporg       = null
        let g_documento.prpnumdig    = null
        let g_documento.ligcvntip    = 0      #PORTO SEGURO
        let g_documento.edsnumref    = 0
        let g_documento.c24astcod    = "P10"
        #a partir do assunto - Re passa parametros separados por ;
        let l_aux = 10    #1º posição apos ponto e virgula depois do assunto
        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo sucursal
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.succod = l_auxtxt
        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo ramo
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.ramcod = l_auxtxt
        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo apolice
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.aplnumdig = l_auxtxt

        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo item da apolice
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.itmnumdig = l_auxtxt
        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo tipo solicitante
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.c24soltipcod = l_auxtxt

        let l_aux2 = 1
        let l_auxtxt = null
        while true    #lendo nome do solicitante
           if l_texto[l_aux] <> ";" then
              let l_auxtxt[l_aux2] = l_texto[l_aux]
              let l_aux2 = l_aux2 + 1
              let l_aux = l_aux + 1
           else
              let l_aux = l_aux + 1
              exit while
           end if
        end while
        let g_documento.solnom = l_auxtxt
        #buscar prgcod em datkassunto
        open ctx26g00001 using l_assunto
        fetch ctx26g00001 into lr_cta02m13.prgcod
        if sqlca.sqlcode is null then
           #display "problema ao buscar prgcod em datkassunto"
           return
        end if

        call cta02m13_chama_laudos(lr_cta02m13.prgcod,
                                   lr_cta02m13.atdsrvorg,
                                   lr_cta02m13.aplflg,
                                   lr_cta02m13.docflg,
                                   lr_cta02m13.webrlzflg )
             returning l_ret, l_lignum
     else
        #display "assunto não preparado pelo ctx26g00!!"
     end if   #l_assunto = P10
  end if # parametro é "Laudo"
end function
