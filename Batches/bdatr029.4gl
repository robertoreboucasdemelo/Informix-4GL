##############################################################################
# Nome do Modulo: BDATR029                                             Pedro #
#                                                                    Marcelo #
# Relacao mensal de servicos por convenio                           Nov/1995 #
#............................................................................#
#                                                                            #
#                  * * * Alteracoes * * *                                    #
#                                                                            #
# Data        Autor Fabrica  Origem    Alteracao                             #
# ----------  -------------- --------- --------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance              #
#----------------------------------------------------------------------------#
# 02/10/2006  Alberto         PSI202720 Saude + casa                         #
#----------------------------------------------------------------------------#
# 27/11/2006 Alberto Rodrigues PSI205206 implementado leitura campo ciaempcod#
#                                        para agrupar por empresa            #
#----------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650   Nao utilizar a 1 posicao do assunto  #
#                                       como sendo o agrupamento, buscar cod #
#                                       agrupamento.                         #
#----------------------------------------------------------------------------#
# 07/12/2010 Robert Lima  CT_2010_02912 Aumento do tamanho do arry a_bdatr029#
##############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define a_bdatr029 array[1000] of record
    ciaempcod      like datmligacao.ciaempcod ,
    ligcvntip      like datmligacao.ligcvntip ,
    ligqtd         integer
 end record

 define l_empresa    like datmligacao.ciaempcod

 define ws_data_de  date,
        ws_data_ate date,
        ws_data_aux char(10)

 define ws_traco       char(140)
 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd

 define sql_comando char(300)
 define index       smallint

 define ml_tpdocto  char(15)

 main

    call bdatr029_cria_log()
    call fun_dba_abre_banco('CT24HS')

    set isolation to dirty read
    set lock mode to wait 10

    let sql_comando = "select cpocod                ",
                      "  from iddkdominio           ",
                      " where cponom = 'ciaempcod'  "
    prepare sel_iddkdominioA from sql_comando
    declare c_iddkdominioA cursor for sel_iddkdominioA

    call bdatr029_prepare()

    let l_empresa = arg_val(2)

    if l_empresa is null or
       l_empresa =  "  " then
       whenever error continue
       open c_iddkdominioA
       whenever error stop
       foreach c_iddkdominioA  into l_empresa
       display "<75> Processando empresa : ", l_empresa
       call bdatr029(l_empresa)
       end foreach
    else
       call bdatr029(l_empresa)
    end if

##    call bdatr029()
 end main

#---------------------------------------------------------------
 function bdatr029_prepare()
#---------------------------------------------------------------

 let sql_comando = "select c24astdes, c24astagp",
                   "  from datkassunto  ",
                   " where c24astcod = ?"
 prepare sel_agrup    from sql_comando
 declare c_bdatr029a cursor for sel_agrup

 let sql_comando = "select c24astagpdes ",
                   "  from datkastagp   ",
                   " where c24astagp = ?"
 prepare sel_assunto  from sql_comando
 declare c_bdatr029b cursor for sel_assunto

 let sql_comando = "select cpodes                   ",
                   "  from datkdominio              ",
                   " where cponom = 'ligcvntip'  and",
                   "       cpocod = ?"

 prepare sel_iddkdominio from sql_comando
 declare c_iddkdominio cursor for sel_iddkdominio

 let sql_comando = " select cpodes                ",
                   "   from iddkdominio           ",
                   "  where cponom = 'ciaempcod'  ",
                   "    and cpocod = ?"
 prepare sel_iddkdominio1 from sql_comando
 declare c_iddkdominio1 cursor for sel_iddkdominio1


end function

#---------------------------------------------------------------
 function bdatr029(l_param)
#---------------------------------------------------------------

 define l_param like datmligacao.ciaempcod

 define d_bdatr029   record
    ligdia           char (10)                  ,
    lighor           like datmligacao.lighorinc ,
    c24solnom        char (20)                  ,
    ligcvntip        like datmligacao.ligcvntip ,
    c24astcod        like datmligacao.c24astcod ,
    c24astdes        char (70)                  ,
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    atdsrvorg        like datmservico.atdsrvorg ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    crtnum           like datrligsau.crtnum     , ## psi202720
    saude            char(15)                   ,
    ciaempcod        like datmligacao.ciaempcod
 end record

 define ws           record
    ligcvntip        like datmligacao.ligcvntip ,
    c24astcod        like datmligacao.c24astcod ,
    totlig           integer                    ,
    dirfisnom        like ibpkdirlog.dirfisnom  ,
    pathrel01        char (60)                  ,
    pathrel02        char (60)                  ,
    ciaempcod        like datmligacao.ciaempcod
 end record

 ##call startlog("./bdatr029_log")

 let ws_traco  = "-------------------------------------------------------------------------------------------------------------------------------------------"

 initialize d_bdatr029.*  to null
 initialize ws.*          to null

 let ml_tpdocto  = null

 for index = 1 to 1000
     let a_bdatr029[index].ciaempcod = l_param ## index
     let a_bdatr029[index].ligcvntip = index
     let a_bdatr029[index].ligqtd    = 0000
 end for

#---------------------------------------------------------------
# Define o periodo mensal
#---------------------------------------------------------------
 let ws_data_aux = arg_val(1)

 if ws_data_aux is null       or
    ws_data_aux =  "  "       then
    let ws_data_aux = today
 else
    if ws_data_aux >= today      or
       length(ws_data_aux) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_ate = ws_data_aux
 let ws_data_ate = ws_data_ate - 1 units day

 let ws_data_aux = ws_data_ate
 let ws_data_aux = "01","/",ws_data_aux[4,5],"/",ws_data_aux[7,10]
 let ws_data_de  = ws_data_aux

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 ## PSI 205206 Selecionar a Empresa
 case l_param
      when 1
           let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT02901"
           let ws.pathrel02 = ws.dirfisnom clipped, "/RDAT02902"
      when 35
           let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT02901A"
           let ws.pathrel02 = ws.dirfisnom clipped, "/RDAT02902A"
      otherwise
           let ws.pathrel01 = ws.dirfisnom clipped, "/RDAT02901"
           let ws.pathrel02 = ws.dirfisnom clipped, "/RDAT02902"
 end case

#---------------------------------------------------------------
# Define numero de vias e account dos relatorios
#---------------------------------------------------------------
 call fgerc010("RDAT02901")
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDAT02902")
      returning  ws_cctcod02,
		 ws_relviaqtd02


#---------------------------------------------------------------
# Ligacoes e servicos por convenio
#---------------------------------------------------------------
 whenever error continue
 declare  c_bdatr029  cursor for
    select datmligacao.ligdat      ,
           datmligacao.lighorinc   ,
           datmligacao.c24solnom   ,
           datmligacao.c24astcod   ,
           datmligacao.ligcvntip   ,
           datmservico.atdsrvnum   ,
           datmservico.atdsrvano   ,
           datmservico.atdsrvorg   ,
           datrligapol.succod      ,
           datrligapol.aplnumdig   ,
           datrligapol.itmnumdig   ,
           datrligsau.crtnum       ,
           datmligacao.ciaempcod
      from datmligacao, outer datrligapol, outer datmservico,
           outer datrligsau
     where datmligacao.ligdat between ws_data_de and ws_data_ate   and
           datmligacao.ligcvntip  >  00                            and
           datrligapol.lignum     =  datmligacao.lignum            and
           datmservico.atdsrvnum  =  datmligacao.atdsrvnum         and
           datmservico.atdsrvano  =  datmligacao.atdsrvano         and
           datrligsau.lignum      =  datmligacao.lignum            and
           datmligacao.ciaempcod  =  l_param
           order by datmligacao.ciaempcod, datmligacao.ligcvntip, datmligacao.c24astcod ,
                    datmservico.atdsrvnum, datmservico.atdsrvano
 whenever error stop
 
 start report  rep_convdia  to  ws.pathrel01

 foreach c_bdatr029  into  d_bdatr029.ligdia    , d_bdatr029.lighor    ,
                           d_bdatr029.c24solnom , d_bdatr029.c24astcod ,
                           d_bdatr029.ligcvntip , d_bdatr029.atdsrvnum ,
                           d_bdatr029.atdsrvano , d_bdatr029.atdsrvorg ,
                           d_bdatr029.succod    , d_bdatr029.aplnumdig ,
                           d_bdatr029.itmnumdig , d_bdatr029.crtnum    ,
                           d_bdatr029.ciaempcod

    if d_bdatr029.ligcvntip = 12   then     ### Convenio Itamarati
       continue foreach
    end if

    if d_bdatr029.c24astcod  = "ALT"   or
       d_bdatr029.c24astcod  = "RPT"   or
       d_bdatr029.c24astcod  = "GOF"   or
       d_bdatr029.c24astcod  = "SIN"   then
       continue foreach
    end if

    ## psi202720
    ## Verifica Tipo de Documento ("APOLICE", "SAUDE", "PROPOSTA", "CONTRATO", "SEMDOCTO" )
    let ml_tpdocto = null
    let ml_tpdocto = cts20g11_identifica_tpdocto(d_bdatr029.atdsrvnum, d_bdatr029.atdsrvano)
    ## psi202720
    let d_bdatr029.saude = ml_tpdocto

    let a_bdatr029[l_param].ciaempcod = d_bdatr029.ciaempcod
    let index = d_bdatr029.ligcvntip
    let a_bdatr029[index].ligqtd = a_bdatr029[index].ligqtd + 1

    initialize d_bdatr029.c24astdes to null
    call bdatr029_assunto(d_bdatr029.c24astcod, d_bdatr029.ligcvntip)
                returning d_bdatr029.c24astdes

    output to report rep_convdia(d_bdatr029.*)

 end foreach

 finish report  rep_convdia

#---------------------------------------------------------------
# Totais por convenio
#---------------------------------------------------------------
whenever error continue
 declare  c_bdatr029t  cursor for
    select datmligacao.ligcvntip, datmligacao.c24astcod,
           datmligacao.ciaempcod, count(*)
      from datmligacao
     where datmligacao.ligdat  between  ws_data_de  and  ws_data_ate   and
           datmligacao.ligcvntip > 00 and
           datmligacao.ciaempcod = l_param
     group by c24astcod, ligcvntip, ciaempcod
     order by ciaempcod
whenever error stop
 start report  rep_totais  to  ws.pathrel02

 foreach c_bdatr029t  into  ws.ligcvntip,
                            ws.c24astcod,
                            ws.ciaempcod,
                            ws.totlig

#---------------------------------------------------------------
# Descarta os convenios abaixo do relatorio de totais
#---------------------------------------------------------------

    if ws.ligcvntip = 80  or     ##  Porto Card
       ws.ligcvntip = 86  or     ##  Porto Seguro Uruguai
       ws.ligcvntip = 88  or     ##  Panamericano
       ws.ligcvntip = 89  or     ##  Avis Assistance
       ws.ligcvntip = 90  or     ##  Mega Assistance
       ws.ligcvntip = 91  or     ##  Segcar
       ws.ligcvntip = 92  or     ##  Repar
       ws.ligcvntip = 12  then   ##  Itamarati
       continue foreach
    end if

    if ws.c24astcod  = "ALT"   or
       ws.c24astcod  = "RPT"   or
       ws.c24astcod  = "GOF"   or
       ws.c24astcod  = "SIN"   then
       continue foreach
    end if

    ##output to report rep_totais(ws.ligcvntip thru ws.totlig)
    output to report rep_totais(ws.ligcvntip, ws.c24astcod, ws.totlig, ws.ciaempcod )

 end foreach

 finish report  rep_totais

end function   ###  bdatr029

#---------------------------------------------------------------
 report rep_convdia(r_bdatr029)
#---------------------------------------------------------------

 define r_bdatr029    record
    ligdia            char (10)                  ,
    lighor            like datmligacao.lighorinc ,
    c24solnom         char (20)                  ,
    ligcvntip         like datmligacao.ligcvntip ,
    c24astcod         like datmligacao.c24astcod ,
    c24astdes         char (70)                  ,
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    atdsrvorg         like datmservico.atdsrvorg ,
    succod            like datrservapol.succod   ,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    crtnum            like datrligsau.crtnum     ,  ## psi202720
    saude             char(15)                   ,
    ciaempcod         like datmligacao.ciaempcod
 end record

 define ws            record
    totlig            integer  ,
    medlig            dec (6,3),
    cvnnom            char (30),
    diasem            char (03),
    dianum            smallint ,
    fimflg            smallint
 end record

 define l_apol_saude char(21)
 define l_convdia_empresa char(50)

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by r_bdatr029.ciaempcod,
            r_bdatr029.ligcvntip,
            r_bdatr029.ligdia   ,
            r_bdatr029.lighor

   format
      page header
           if pageno = 1  then
              print "OUTPUT JOBNAME=DAT02901 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - SERVICOS POR CONVENIO "
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"
              print ascii(12)

              let ws.fimflg = false
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 099, "RDAT029-01",
                 column 113, "PAGINA : ", pageno using "##,###,##&"
           print column 113, "DATA   : ", today
           print column 026, "LIGACOES/SERVICOS SOLICITADOS POR CONVENIO/DIA DE ",
                 ws_data_de, " A ", ws_data_ate,
                 column 113, "HORA   :   ", time
                 
           whenever error continue
           open  c_iddkdominio1 using r_bdatr029.ciaempcod
           fetch c_iddkdominio1 into  l_convdia_empresa
           close c_iddkdominio1
           whenever error stop

           skip 1 lines
           print column 001, l_convdia_empresa
           skip 1 lines

           initialize ws.cvnnom  to null
           
           whenever error continue
           select cpodes into ws.cvnnom
             from datkdominio
            where cponom = "ligcvntip"  and
                  cpocod = r_bdatr029.ligcvntip
           whenever error stop

           if ws.fimflg = false then
              print column 001, "CONVENIO: ", r_bdatr029.ligcvntip  using "<<&"
                                clipped, " - ", ws.cvnnom
              print column 001, ws_traco

              print column 002, "DIA"                  ,
                    column 009, "HORA"                 ,
                    column 017, "DOCUMENTO"            ,
                    column 042, "SOLICITANTE"          ,
                    column 063, "TIPO"                 ,
                    column 069, "No.SERVICO"           ,
                    column 083, "ASSUNTO"

              print column 001, ws_traco
              skip 1 line
           else

              skip 1 line
              print column 001, ws_traco
              print column 045, "TOTAL DE LIGACOES/SERVICOS"
              print column 001, ws_traco
              skip 1 line
           end if

      before group of r_bdatr029.ligcvntip
           skip to top of page

      on every row
           let ws.dianum = weekday(r_bdatr029.ligdia)
           case ws.dianum
              when 0  let ws.diasem = "DOM"
              when 1  let ws.diasem = "SEG"
              when 2  let ws.diasem = "TER"
              when 3  let ws.diasem = "QUA"
              when 4  let ws.diasem = "QUI"
              when 5  let ws.diasem = "SEX"
              when 6  let ws.diasem = "SAB"
           end case

           let l_apol_saude = null
           if r_bdatr029.saude = "SAUDE" then
              let l_apol_saude = cts20g16_formata_cartao(r_bdatr029.crtnum)
           else
              let l_apol_saude = r_bdatr029.succod     using "&&" , " ",
                                 r_bdatr029.aplnumdig  using "&&&&&&&&&", " ",
                                 r_bdatr029.itmnumdig  using "&&&&&&&" , " "
           end if

           print column 002, r_bdatr029.ligdia[1,2] using "&&"      ,
                 column 005, ws.diasem                              ,
                 column 009, r_bdatr029.lighor                      ,
                 ## column 018, r_bdatr029.succod     using "&&"       ,
                 ## column 021, r_bdatr029.aplnumdig  using "&&&&&&&&&",
                 ## column 031, r_bdatr029.itmnumdig  using "&&&&&&&"  ,
                 column 018, l_apol_saude                           ,
                 column 042, r_bdatr029.c24solnom                   ;

           if r_bdatr029.atdsrvnum is not null  then
              print column 069, r_bdatr029.atdsrvorg using "&&"    , "/",
                                r_bdatr029.atdsrvnum using "&&&&&&&","-",
                                r_bdatr029.atdsrvano using "&&"    ;
           end if
           print column 083, r_bdatr029.c24astdes

#---------------------------------------------------------------
# Descarta os convenios abaixo da totalizacao final
#---------------------------------------------------------------

           if r_bdatr029.ligcvntip <> 80  and    ##  Porto Card
              r_bdatr029.ligcvntip <> 86  and    ##  Porto Seguro Uruguai
              r_bdatr029.ligcvntip <> 88  and    ##  Panamericano
              r_bdatr029.ligcvntip <> 89  and    ##  Avis Assistance
              r_bdatr029.ligcvntip <> 90  and    ##  Mega Assistance
              r_bdatr029.ligcvntip <> 91  and    ##  Segcar
              r_bdatr029.ligcvntip <> 92  then   ##  Repar
              let ws.totlig = ws.totlig + 1
           end if

      on last row
           let ws.fimflg = true
           skip to top of page

#---------------------------------------------------------------
# Descarta os convenios abaixo da impressao do resumo de totais
#---------------------------------------------------------------

           for index = 01 to 99
              if a_bdatr029[index].ligcvntip <> 80  and   ##  Porto Card
                 a_bdatr029[index].ligcvntip <> 86  and   ##  Porto Uruguai
                 a_bdatr029[index].ligcvntip <> 88  and   ##  Panamericano
                 a_bdatr029[index].ligcvntip <> 89  and   ##  Avis Assistance
                 a_bdatr029[index].ligcvntip <> 90  and   ##  Mega Assistance
                 a_bdatr029[index].ligcvntip <> 91  and   ##  Segcar
                 a_bdatr029[index].ligcvntip <> 92  then  ##  Repar
                 if a_bdatr029[index].ligqtd  >  0  then
                    initialize ws.cvnnom  to null
                    
                    whenever error continue
                    open  c_iddkdominio using index
                    fetch c_iddkdominio into  ws.cvnnom
                    close c_iddkdominio
                    whenever error stop

                    skip 1 line
                    print column 029, ws.cvnnom,
                          column 059, a_bdatr029[index].ligqtd using "###,##&";

                    let ws.medlig = 000.0
                    let ws.medlig = a_bdatr029[index].ligqtd / ws.totlig
                    let ws.medlig = ws.medlig * 100

                    print column 075, ws.medlig using "##&.&%"
                 end if
              end if
           end for
           print column 059, "-------"
           print column 059, ws.totlig  using "###,##&"

           print "$FIMREL$"

end report  ###  rep_convdia

#-----------------------------------------------------------------------------#
 report rep_totais(r_bdatr029)
#-----------------------------------------------------------------------------#

 define r_bdatr029    record
    ligcvntip         like datmligacao.ligcvntip ,
    c24astcod         like datmligacao.c24astcod ,
    totlig            integer                    ,
    ciaempcod         like datmligacao.ciaempcod
 end record

 define ws            record
    cvnnom            char (30),
    assunto           char (80),
    totlig            integer
 end record

 define l_totais_empresa char(50)

   output
      left   margin  000
      right  margin  132
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdatr029.ciaempcod,
             r_bdatr029.ligcvntip,
             r_bdatr029.c24astcod

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DAT02902 FORMNAME=BRANCO"
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - TOTAIS POR CONVENIO/ASSUNTO "
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"
              print ascii(12)
           else
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, ;"
             print "$DJDE$ C LIXOLIXO, END ;"
             print ascii(12)
           end if
           print column 099, "RDAT029-02",
                 column 113, "PAGINA : ", pageno using "##,###,##&"
           print column 113, "DATA   : ", today
           print column 030, "TOTAL DE LIGACOES POR CONVENIO/ASSUNTO DE ",
                             ws_data_de, " A ", ws_data_ate,
                 column 113, "HORA   :   ", time
           
           whenever error continue
           open  c_iddkdominio1 using r_bdatr029.ciaempcod
           fetch c_iddkdominio1 into  l_totais_empresa
           close c_iddkdominio1
           whenever error stop

           skip 1 lines
           print column 001, l_totais_empresa
           skip 1 lines

           initialize ws.cvnnom to null
           
           whenever error continue
           open  c_iddkdominio using r_bdatr029.ligcvntip
           fetch c_iddkdominio into  ws.cvnnom
           close c_iddkdominio
           whenever error stop

           print column 001, "CONVENIO: ", r_bdatr029.ligcvntip  using "##&"
                             clipped, " - ", ws.cvnnom
           print column 001, ws_traco

           print column 011, "ASSUNTO"  ,
                 column 098, "QTDE"

           print column 001, ws_traco
           skip 1 line

      before group of r_bdatr029.ligcvntip
           skip to top of page

      after group of r_bdatr029.ligcvntip
           print column 095, "-------"
           print column 095, ws.totlig   using  "###,##&"

           let ws.totlig = 0

      on every row
           call bdatr029_assunto(r_bdatr029.c24astcod, r_bdatr029.ligcvntip)
                       returning ws.assunto
           print column 011, ws.assunto                               ,
                 column 095, r_bdatr029.totlig using "###,##&"

           let ws.totlig = ws.totlig + r_bdatr029.totlig

      on last row
           print "$FIMREL$"

end report  ###  rep_totais

#-----------------------------------------------------------------------------
 function bdatr029_assunto(param)
#-----------------------------------------------------------------------------

 define param       record
    c24astcod       like datkassunto.c24astcod,
    cvnnum          like datmligacao.ligcvntip
 end record

 define ws          record
    c24astcod       like datkassunto.c24astcod,
    c24astagp       like datkassunto.c24astagp,
    c24agpdes       like datkastagp.c24astagpdes,
    c24astdes       like datkassunto.c24astdes,
    assunto         char(72)
 end record

 initialize ws.*  to null

 whenever error continue
 open  c_bdatr029a  using param.c24astcod
 fetch c_bdatr029a  into  ws.c24astdes, ws.c24astagp

 if sqlca.sqlcode <> 0  then
    let ws.assunto = "ASSUNTO NAO CADASTRADO"
 else
    #if param.c24astcod[1,1] = "S"  then
    if ws.c24astagp = "S"  then       ## psi230650
       case param.cvnnum
          when 02   let ws.c24agpdes = "RURAL SOCORRO -"
          when 03   let ws.c24agpdes = "SAFRA SOCORRO -"
          when 07   let ws.c24agpdes = "B C N  SOCORRO -"
          when 08   let ws.c24agpdes = "JM HELP -"
          when 09   let ws.c24agpdes = "BMC SOCORRO -"
          when 10   let ws.c24agpdes = "ITACOLOMI SOCORRO -"
          when 11   let ws.c24agpdes = "BBM AUTO ASSISTENCIA -"
          when 13   let ws.c24agpdes = "CENTAURO AUTO ASSISTENCIA -"
          when 14   let ws.c24agpdes = "CITIAUTO ASSISTENCE -"
          otherwise let ws.c24agpdes = "PORTO SOCORRO -"
       end case
       let ws.assunto = ws.c24agpdes clipped, " ",  ws.c24astdes
    else
       open  c_bdatr029b   using ws.c24astagp
       fetch c_bdatr029b   into  ws.c24agpdes

       if sqlca.sqlcode = 0   then
          let ws.assunto = ws.c24agpdes clipped, " ",  ws.c24astdes
       end if
       close c_bdatr029b
    end if
 end if
 whenever error stop
 close c_bdatr029a

 return ws.assunto

end function  ###  bdatr029_assunto

#-------------------------------------------#
function bdatr029_formata_cartao(l_crtsaunum)
#-------------------------------------------#

  # -> FUNCAO PARA FORMATAR A EXIBICAO DO CARTAO NO FOMATO xxx.xxxx.xxxx.xxxx

  define l_crtsaunum    like datksegsau.crtsaunum,
         l_novo_formato char(19)

  let l_novo_formato = l_crtsaunum[1,4]   clipped, ".",
                       l_crtsaunum[5,8]   clipped, ".",
                       l_crtsaunum[9,12]  clipped, ".",
                       l_crtsaunum[13,16]

  return l_novo_formato

end function

#--------------------------#
function bdatr029_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdatr029.log"

  call startlog(l_path)

end function
