#############################################################################
# Nome do Modulo: BDATA123                                         Raji     #
# Gera relatorio formato excel de assuntos F10 - 01/10/2000 ate 31/10/2000  #
#############################################################################
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance             #
#---------------------------------------------------------------------------#
# 17/08/2007  Saulo, Meta    AS146056  Substituicao de palavras             #
#                                      reservadas                           #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################
 database porto

 define g_traco        char(80)
 define ws_incdat      date
 define ws_fnldat      date
globals
   define g_ismqconn smallint
end globals

 main
    call fun_dba_abre_banco('CT24HS')
    set isolation to dirty read
    call bdata123()
 end main

#---------------------------------------------------------------
 function bdata123()
#---------------------------------------------------------------

 define d_bdata123    record
    c24astcod         like datmligacao.c24astcod,
    ligdat            like datmligacao.ligdat,
    lighorinc         like datmligacao.lighorinc,
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmligacao.atdsrvnum,
    atdsrvano         like datmligacao.atdsrvano,
    sindat            like datmservicocmp.sindat,
    sinhor            like datmservicocmp.sinhor,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    clalclcod         like abbmdoc.clalclcod
 end record

 define ws_funapol    record
    resultado         char (01),
    dctnumseq         decimal(04,00),
    vclsitatu         decimal(04,00),
    autsitatu         decimal(04,00),
    dmtsitatu         decimal(04,00),
    dpssitatu         decimal(04,00),
    appsitatu         decimal(04,00),
    vidsitatu         decimal(04,00)
 end record

 define ws            record
    auxdat            char(10),
    dirfisnom         like ibpkdirlog.dirfisnom,
    pathrel01         char (60),
    comando           char (400),
    sqlcode           integer
 end record

 define l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
 end  record
 define l_coderro  smallint
 define msg_erro   char(500)
 define l_rel      smallint

 initialize d_bdata123.*  to null
 initialize ws_funapol.*  to null
 initialize ws.*          to null
 let l_rel = false

 #--------------------------------------------------------------------
 # Define data parametro
 #--------------------------------------------------------------------
 let ws.auxdat = arg_val(1)

 if ws.auxdat is null       or
    ws.auxdat =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_fnldat       = ws.auxdat
 let ws_incdat       = ws_fnldat - 15 units day


 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

let ws.pathrel01  = ws.dirfisnom clipped, "/RDAT12301"


 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdata123 cursor for
    select datmligacao.c24astcod
         , datmligacao.ligdat
         , datmligacao.lighorinc
         , datmservico.atdsrvorg
         , datmligacao.atdsrvnum
         , datmligacao.atdsrvano
         , datmservicocmp.sindat
         , datmservicocmp.sinhor
         , datmlcl.cidnom
         , datmlcl.ufdcod
         , datrservapol.succod
         , datrservapol.ramcod
         , datrservapol.aplnumdig
         , datrservapol.itmnumdig
      from datmligacao, datmlcl, datmservicocmp, datrservapol, datmservico
     where datmligacao.ligdat between "01/10/2000" and "31/10/2000"
       and datmligacao.c24astcod = "F10"
           and datmservicocmp.atdsrvnum = datmligacao.atdsrvnum
       and datmservicocmp.atdsrvano = datmligacao.atdsrvano
       and datrservapol.atdsrvnum = datmligacao.atdsrvnum
       and datrservapol.atdsrvano = datmligacao.atdsrvano
       and datmlcl.atdsrvnum = datmligacao.atdsrvnum
       and datmlcl.atdsrvano = datmligacao.atdsrvano
       and datmservico.atdsrvnum = datmligacao.atdsrvnum
       and datmservico.atdsrvano = datmligacao.atdsrvano
       and datmlcl.c24endtip = 1

 start report bdata123_rel to ws.pathrel01

 foreach c_bdata123  into  d_bdata123.c24astcod,
                           d_bdata123.ligdat   ,
                           d_bdata123.lighorinc,
                           d_bdata123.atdsrvorg,
                           d_bdata123.atdsrvnum,
                           d_bdata123.atdsrvano,
                           d_bdata123.sindat   ,
                           d_bdata123.sinhor   ,
                           d_bdata123.cidnom   ,
                           d_bdata123.ufdcod   ,
                           d_bdata123.succod   ,
                           d_bdata123.ramcod   ,
                           d_bdata123.aplnumdig,
                           d_bdata123.itmnumdig

    if d_bdata123.succod    is null  and
       d_bdata123.aplnumdig is null  and
       d_bdata123.itmnumdig is null  then
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca ultima situacao da apolice
    #---------------------------------------------------------------
    initialize ws_funapol.*   to null

    call f_funapol_ultima_situacao
         (d_bdata123.succod, d_bdata123.aplnumdig, d_bdata123.itmnumdig)
          returning  ws_funapol.*

    select clalclcod
      into d_bdata123.clalclcod
      from abbmdoc
     where succod    = d_bdata123.succod
       and aplnumdig = d_bdata123.aplnumdig
       and itmnumdig = d_bdata123.itmnumdig
       and dctnumseq = ws_funapol.dctnumseq

    if sqlca.sqlcode <> 0  then
       continue foreach
    end if

    let l_rel = true
    output to report bdata123_rel(d_bdata123.*)

    initialize d_bdata123.* to null

 end foreach

 finish report bdata123_rel

#PSI-2013-23297 - Inicio
let l_mail.de = "CT24H"
let l_mail.para =  "jahchan_raji/spaulo_info_sistemas@u23"
let l_mail.cc = ""
let l_mail.cco = ""
let l_mail.assunto = "Relatorio Oficinas indicadas - ",ws_fnldat
let l_mail.mensagem = "<html><body><font face = Times New Roman>Relatorio Oficinas indicadas - ",ws_fnldat,
                      "<br><br></font></body></html>"
let l_mail.id_remetente = "CT24H"
let l_mail.tipo = "html"
if l_rel = true then
     call figrc009_attach_file(ws.pathrel01)

else
     let l_mail.mensagem = "Nao existem registros a serem processados."
end if
call figrc009_mail_send1 (l_mail.*)
 returning l_coderro,msg_erro
#PSI-2013-23297 - Fim

end function #  bdata123


#----------------------------------------------------------------------------#
 report bdata123_rel(r_bdata123)
#----------------------------------------------------------------------------#

 define r_bdata123    record
    c24astcod         like datmligacao.c24astcod,
    ligdat            like datmligacao.ligdat,
    lighorinc         like datmligacao.lighorinc,
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmligacao.atdsrvnum,
    atdsrvano         like datmligacao.atdsrvano,
    sindat            like datmservicocmp.sindat,
    sinhor            like datmservicocmp.sinhor,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    clalclcod         like abbmdoc.clalclcod
 end record

 define ws            record
    linha            char(3000),
    tab              char(1)
 end record

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by r_bdata123.ligdat,
            r_bdata123.lighorinc
   format
      first page header
              let ws.tab = "	"
              print "ASSUNTO", "	",
                    "DATA ATD" , "	",
                    "HORA ATD", "	",
                    "NUMERO SERVICO" , "	",
                    "DATA SIN" , "	",
                    "HORA SIN", "	",
                    "CIDADE","	",
                    "UF","	",
                    "CLASSE LOC.APOL."
      on every row
           let ws.linha = r_bdata123.c24astcod clipped,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.ligdat,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.lighorinc,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.atdsrvorg  using "&&",
                 "/", r_bdata123.atdsrvnum  using "&&&&&&&",
                 "-", r_bdata123.atdsrvano  using "&&",
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.sindat,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.sinhor,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.cidnom,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.ufdcod,
                 ws.tab
           let ws.linha = ws.linha clipped,
                 r_bdata123.clalclcod

           # IMPRIME LINHA
           print ws.linha

end report  ###  bdata123_rel

