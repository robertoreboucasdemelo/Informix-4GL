################################################################################
# Nome do Modulo: bdbsa067                                            Marcelo  #
#                                                                     Gilberto #
#                                                                     Wagner   #
# Relacao dos servicos excluidos 24/48horas                           Ago/1999 #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL     DESCRICAO                           #
#------------------------------------------------------------------------------#
# 20/09/1999  PSI 9358-0   Wagner          Alteracao da exclusao/listagem que  #
#                                          de 24/48 horas passou para 6 horas. #
#------------------------------------------------------------------------------#
# 21/09/1999  *Correio*    Wagner          Alteracao no endereco do e-mail.    #
#------------------------------------------------------------------------------#
# 18/02/2000  MUDANCA      Wagner          Alterar envio uuencode para mailx   #
#------------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio            Substituicao do atdtip p/ atdsrvorg #
#                                          Exibicao do atdsrvnum (dec 10,0)    #
#------------------------------------------------------------------------------#
# 14/08/2000  PSI 11437-5  Wagner          Reter servico para analise sem      #
#                                          excluir                             #
#------------------------------------------------------------------------------#
# 04/04/2003  PSI          Raji            Alteracao da exclusao/listagem que  #
#                                          de 6 horas para 2 horas             #
#------------------------------------------------------------------------------#
# 06/05/2003  OSF          Adriana         Criacao da funcao bdbsa067_espera   #
#                          Schneider       e validacoes sobre a diferenca de   #
#                                          servico de apoio e grupo de problema#
################################################################################
#                                                                              #
#                          * * * Alteracoes * * *                              #
#                                                                              #
# Data        Autor Fabrica     Origem    Alteracao                            #
# ----------  --------------    --------- ------------------------------------ #
# 07/10/2003  Meta,Bruno        PSI176656 Faz bloqueio de servico para o mesmo #
#                               OSF27090  segurado com criterio tempo.         #
# ----------  --------------    --------- ------------------------------------ #
# 26/06/2004  Meta, Bruno       PSI185035  Padronizar o processamento Batch    #
#                               OSF036870  do Porto Socorro.                   #
# ---------------------------------------------------------------------------- #
# 05/10/2004 Lucas, Meta        PSI188255  Alteracoes:                         #
#                                          Alterar a leitura do parametro de   #
#                                          tempo p/ ficar antes do foreach     #
#                                          principal.                          #
#                                          Alterar o cabecalho do e-mail.      #
#                                          Alterar o cabecalho do relatorio.   #
################################################################################
#                   * * *  A L T E R A C O E S  * * *                          #
#                                                                              #
# Data       Autor Fabrica        PSI    Alteracoes                            #
# ---------- -------------------- ------ --------------------------------------#
# 10/09/2005 JUNIOR (Meta)        Melhorias incluida funcao fun_dba_abre_banco.#
################################################################################

 database porto
 
 globals
  define g_servicoanterior char(20),
         g_isbigchar       smallint
 end globals

 define g_traco        char(80)
 define m_prep_sql     smallint  ## PSI 176656
 define m_path         char(100) ## PSI 185035
 define m_aux          char(05)  ## PSI 188255 - Lucas Scheid

 main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, '/'

    let m_path = m_path clipped, "bdbsa067.log"
    display 'm_path: ', m_path clipped
    call startlog(m_path)
    # PSI 185035 - Final

   call bdbsa067()
 end main

#---------------------------------------------------------------
 function bdbsa067_prepara()  ## PSI 176656 Inicio
#---------------------------------------------------------------

 define cmd_sql        char(100)

      let cmd_sql = "select grlinf from datkgeral ",
                    " where grlchv = 'BLQSRVTMP' "
      prepare pbdbsa06701    from cmd_sql
      declare cbdbsa06701    cursor for pbdbsa06701

      let cmd_sql = "select cpodes              ",
                    "  from iddkdominio         ",
                    " where cponom = 'ciaempcod'",
                    "   and cpocod = ?          "
      prepare sel_iddkdominio from cmd_sql
      declare c_iddkdominio cursor for sel_iddkdominio

 let m_prep_sql = true

 end function                 ## PSI 176656 Final

#---------------------------------------------------------------
 function bdbsa067()
#---------------------------------------------------------------

 define d_bdbsa067   record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    atdetpdat        like datmsrvacp.atdetpdat  ,
    atdetphor        like datmsrvacp.atdetphor  ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    c24pbmcod        like datrsrvpbm.c24pbmcod  ,
    c24pbmgrpcod     like datkpbm.c24pbmgrpcod  ,
    atdhorprg        like datmservico.atdhorprg ,
    ciaempcod        like datmservico.ciaempcod
 end record

 define ws           record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    nom              like datmservico.nom       ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    atdetpcod        like datmsrvacp.atdetpcod  ,
    atdsrvseq        like datmsrvacp.atdsrvseq  ,
    atdetpdat        like datmsrvacp.atdetpdat  ,
    atdetphor        like datmsrvacp.atdetphor  ,
    datatd           like datmservico.atddat    ,
    auxdat           char (10)                  ,
    hoje             date                       ,
    agora            char (05)                  ,
    hora             char (06)                  ,
    horadif          integer                    ,
    c24txtseq        like datmservhist.c24txtseq,
    c24srvdsc        like datmservhist.c24srvdsc,
    comando          char (400)                 ,
    dirfisnom        like ibpkdirlog.dirfisnom  ,
    pathrel01        char (60),
    reshor           interval hour(06) to minute,
    c24pbmcod        like datrsrvpbm.c24pbmcod,
    c24pbmgrpcod     like datkpbm.c24pbmgrpcod
 end record

 define sql_comando  char (550),
        w_servapoio,w_grupoprob char(01)

 define l_retorno    smallint

 ## PSI 176656 Inicio

 define l_grlinf       char(30)
 define l_erro         smallint

 ## psi205206

 define l_empresa    char(50),
        l_ret        smallint,
        l_mensagem   char(50)

 let l_erro   = false

 if m_prep_sql is null or m_prep_sql = false then
    call bdbsa067_prepara()
 end if

 ## PSI 176656 Final

 #--------------------------------------------------------------------
 # Inicializacao das variaveis
 #--------------------------------------------------------------------
 let g_traco = "--------------------------------------------------------------------------------"
 let l_empresa = "PORTO SEGURO"
 initialize d_bdbsa067.*  to null
 initialize ws.*          to null

 let ws.hoje  = today
 let ws.agora = time

 #--------------------------------------------------------------------
 # Preparando SQL ETAPAS
 #--------------------------------------------------------------------
 let sql_comando = "select max(atdsrvseq)",
                   "  from datmsrvacp    ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "

 prepare sel_datmsrvacp from sql_comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let sql_comando = "select atdetpcod, ",
                   "       atdetpdat, ",
                   "       atdetphor  ",
                   "  from datmsrvacp",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = ?"

 prepare sel_srvultetp from sql_comando
 declare c_srvultetp cursor for sel_srvultetp

 #--------------------------------------------------------------------
 # Preparando SQL leitura servicos/apolice
 #--------------------------------------------------------------------
 let sql_comando = "select datmservico.atdsrvnum, ",
                   "       datmservico.atdsrvano, ",
                   "       datmservico.nom      , ",
                   "       datmservico.atdsrvorg, ",
                   "       datmservico.atddat   , ",
                   "       datmservico.atdhor     ",
                   "  from datrservapol, datmservico ",
                   " where datrservapol.succod    = ? ",
                   "   and datrservapol.ramcod    = ? ",
                   "   and datrservapol.aplnumdig = ? ",
                   "   and datrservapol.itmnumdig = ? ",
                   "   and datmservico.atdsrvnum  = datrservapol.atdsrvnum ",
                   "   and datmservico.atdsrvano  = datrservapol.atdsrvano ",
                   "   and datmservico.atddat     <= ? ",
                   "   and datmservico.atdhorprg is null"

 prepare sel_datrservapol from sql_comando
 declare c_datrservapol cursor with hold for sel_datrservapol

 #--------------------------------------------------------------------
 # Cursor DESCRICAO TIPO SERVICO
 #--------------------------------------------------------------------
 let sql_comando = "select srvtipabvdes",
                   "  from datksrvtip  ",
                   " where atdsrvorg = ?  "

 prepare sel_datksrvtip from sql_comando
 declare c_datksrvtip cursor for sel_datksrvtip

 #--------------------------------------------------------------------
 # Cursor HISTORICO
 #--------------------------------------------------------------------
 let sql_comando = " select max(c24txtseq) ",
                   "   from datmservhist   ",
                   "  where atdsrvnum = ?  ",
                   "    and atdsrvano = ?  "

 prepare sel_datmservhist from sql_comando
 declare c_datmservhist cursor for sel_datmservhist

 #--------------------------------------------------------------------
 # Insert HISTORICO
 #--------------------------------------------------------------------
 let sql_comando = " insert into datmservhist",
                   " (atdsrvnum , atdsrvano, ",
                   "  c24txtseq , c24funmat, ",
                   "  c24srvdsc , ligdat   , ",
                   "  lighorinc ) values     ",
                   " (?, ?, ?, ?, ?, ?, ?)   "

 prepare ins_datmservhist from sql_comando

 #--------------------------------------------------------------------
 # Cursor COD.PROBLEMA E GRUPO DE PROBLEMA
 #--------------------------------------------------------------------
 let sql_comando = " select a.c24pbmcod,c24pbmgrpcod ",
                   "   from datrsrvpbm a , outer datkpbm  b  ",
               ##    "  where atdsrvnum > ?  ",
                   "  where atdsrvnum = ?  ",
                   "    and atdsrvano = ?  ",
                   "    and c24pbmseq = 1  ",
                   "    and a.c24pbmcod = b.c24pbmcod "

 prepare sel_datrsrvpbm from sql_comando
 declare c_datrsrvpbm cursor for sel_datrsrvpbm


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

 let ws.datatd = ws.auxdat

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "ARQUIVO")
      returning ws.dirfisnom

 if ws.dirfisnom is null or
    ws.dirfisnom = " " then
    let ws.dirfisnom = "."
 end if

 let ws.dirfisnom = ws.dirfisnom clipped, '/'

 let ws.pathrel01  =  ws.dirfisnom clipped, "RDBS06701"
 display 'ws.pathrel01: ', ws.pathrel01 clipped
  ### Inicio PSI188255 - Lucas Scheid
  open  cbdbsa06701
  whenever error continue
  fetch cbdbsa06701   into  l_grlinf
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        display 'Registro nao encontrado. Avise a Informatica !!!'
     else
        display 'Erro SELECT datkgeral ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
        display 'bdbsa067()'
     end if
     exit program(1)
  end if

  ###  verificar se e uma hora valida
  if l_grlinf[1,2] >= "00" and l_grlinf[1,2] <= "23" and
     l_grlinf[4,5] >= "00" and l_grlinf[4,5] <= "59" then
     let m_aux = l_grlinf
  else
     display 'Conteudo invalido. Avise a Informatica !!!'
     exit program(1)
  end if
  ### Fim PSI188255 - Lucas Scheid

 #--------------------------------------------------------------------
 # Cursor principal - VERIFICACAO SERVICOS DIARIOS
 #--------------------------------------------------------------------
 declare  c_datmservico  cursor with hold for
     select datmservico.atdsrvnum  , datmservico.atdsrvano  ,
            datmservico.atdsrvorg  , datmservico.atddat     ,
            datmservico.atdhor     , datrservapol.ramcod    ,
            datrservapol.succod    , datrservapol.aplnumdig ,
            datrservapol.itmnumdig , datmservico.atdhorprg  ,
            datmservico.ciaempcod
       from datmservico, datrservapol
      where datmservico.atddat = ws.datatd
        and datmservico.atdsrvorg in ( 6 , 1 )
        and datrservapol.atdsrvnum = datmservico.atdsrvnum
        and datrservapol.atdsrvano = datmservico.atdsrvano
        order by datmservico.ciaempcod desc

 start report bdbsa067_rel to ws.pathrel01

 foreach c_datmservico into d_bdbsa067.atdsrvnum, d_bdbsa067.atdsrvano,
                            d_bdbsa067.atdsrvorg, d_bdbsa067.atddat   ,
                            d_bdbsa067.atdhor   , d_bdbsa067.ramcod   ,
                            d_bdbsa067.succod   , d_bdbsa067.aplnumdig,
                            d_bdbsa067.itmnumdig, d_bdbsa067.atdhorprg,
                            d_bdbsa067.ciaempcod

    #------------------------------
    # Azul ou Porto seguro
    #------------------------------
    open  c_iddkdominio using d_bdbsa067.ciaempcod
    fetch c_iddkdominio into  l_empresa
    close c_iddkdominio

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using d_bdbsa067.atdsrvnum, d_bdbsa067.atdsrvano
    fetch c_datmsrvacp into  ws.atdsrvseq
    close c_datmsrvacp

    open  c_srvultetp  using d_bdbsa067.atdsrvnum,
                             d_bdbsa067.atdsrvano,
                             ws.atdsrvseq
    fetch c_srvultetp  into  ws.atdetpcod,
                             d_bdbsa067.atdetpdat,
                             d_bdbsa067.atdetphor
    close c_srvultetp

    if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
       continue foreach
    end if

    #------------------------------------------------------------
    # Ignorar servico programado
    #------------------------------------------------------------
    if d_bdbsa067.atdhorprg is not null then
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica outros servicos
    #------------------------------------------------------------
    open  c_datrservapol  using d_bdbsa067.succod   , d_bdbsa067.ramcod   ,
                                d_bdbsa067.aplnumdig, d_bdbsa067.itmnumdig,
                                d_bdbsa067.atddat

    foreach  c_datrservapol  into  ws.atdsrvnum, ws.atdsrvano, ws.nom,
                                   ws.atdsrvorg, ws.atddat   , ws.atdhor

       if ws.atdsrvorg <> 6    and     # DAF
          ws.atdsrvorg <> 1    then    # Socorro
          continue foreach
       end if

       if ws.atdsrvnum >= d_bdbsa067.atdsrvnum  and
          ws.atdsrvano = d_bdbsa067.atdsrvano then
          continue foreach
       end if

       #------------------------------------------------------------
       # Verifica etapa dos servicos
       #------------------------------------------------------------
       open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano
       fetch c_datmsrvacp into  ws.atdsrvseq
       close c_datmsrvacp

       open  c_srvultetp using ws.atdsrvnum, ws.atdsrvano, ws.atdsrvseq
       fetch c_srvultetp into  ws.atdetpcod,
                               ws.atdetpdat,
                               ws.atdetphor
       close c_srvultetp

       if ws.atdetpcod = 5  or    ### Servico CANCELADO
          ws.atdetpcod = 6  then  ### Servico EXCLUIDO
          continue foreach
       end if


       ##-----------------------##
       ## Calculo da data + hora
       ##-----------------------##
       call bdbsa067_espera(ws.atdetpdat, ws.atdetphor,
                            d_bdbsa067.atdetpdat,d_bdbsa067.atdetphor)
                            returning ws.reshor

       let w_servapoio = "N"
       let w_grupoprob = "N"

          ## PSI 176656 Inicio

       if ws.reshor < m_aux then  ### PSI188255 - Lucas Scheid

          ## PSI 176656 Final
          ##----------------------##
          ## Verif.GRUPO DE PROBLEMA
          ##----------------------##
          initialize d_bdbsa067.c24pbmcod    to null
          initialize d_bdbsa067.c24pbmgrpcod to null

          open  c_datrsrvpbm using d_bdbsa067.atdsrvnum,
                                   d_bdbsa067.atdsrvano
          fetch c_datrsrvpbm into  d_bdbsa067.c24pbmcod,
                                   d_bdbsa067.c24pbmgrpcod
          if status = 0 then

             initialize ws.c24pbmcod    to null
             initialize ws.c24pbmgrpcod to null

             open  c_datrsrvpbm using ws.atdsrvnum,
                                      ws.atdsrvano
             fetch c_datrsrvpbm into  ws.c24pbmcod,
                                      ws.c24pbmgrpcod
             if status = 0 then
                if d_bdbsa067.c24pbmgrpcod = ws.c24pbmgrpcod then
                   let w_grupoprob = "S"
                end if
             end if
             close c_datrsrvpbm

             ##----------------------##
             ## Verif.GRUPO DE APOIO
             ##----------------------##

             if d_bdbsa067.c24pbmcod = 113 or
                d_bdbsa067.c24pbmcod = 115 then
                let w_servapoio = "S"
             end if
          end if
          close c_datrsrvpbm

          if d_bdbsa067.c24pbmcod = 999 or
             ws.c24pbmcod         = 999 then
              let w_grupoprob = "S"
          end if

          if  w_servapoio = "N" and
              w_grupoprob = "N" then
              continue foreach
          end if

          #BURINI# open  c_datmservhist using ws.atdsrvnum, ws.atdsrvano
          #BURINI# fetch c_datmservhist into  ws.c24txtseq
          #BURINI# close c_datmservhist
          #BURINI# 
          #BURINI# if ws.c24txtseq is null  then
          #BURINI#    let ws.c24txtseq = 0
          #BURINI# end if
          #BURINI# 
          #BURINI# let ws.c24txtseq = ws.c24txtseq + 1
          #BURINI# 
          #BURINI# if w_servapoio = "S" then
          #BURINI#    let ws.c24srvdsc = "SERV ENVIADO P/ANALISE POR OUTRA SOLIC. EM ", m_aux, "H APOIO" ### PSI188255 - Lucas Scheid
          #BURINI# else
          #BURINI#    if w_grupoprob = "S" then
          #BURINI#       let ws.c24srvdsc = "SERV RETIDO P/ANALISE POR OUTRA SOLIC. EM ", m_aux, "H"  ### PSI188255 - Lucas Scheid
          #BURINI#    end if
          #BURINI# end if
          #BURINI# 
          #BURINI# begin work
          #BURINI# 
          #BURINI# execute ins_datmservhist using ws.atdsrvnum ,
          #BURINI#                                ws.atdsrvano ,
          #BURINI#                                ws.c24txtseq, "999999" ,
          #BURINI#                                ws.c24srvdsc, ws.hoje       ,
          #BURINI#                                ws.agora

          call ctd07g01_ins_datmservhist(ws.atdsrvnum,
                                         ws.atdsrvano,
                                         "999999",
                                         ws.c24srvdsc,
                                         ws.hoje,
                                         ws.agora,
                                         '1',
                                         'F')
               returning l_ret,
                         l_mensagem               
          
          
          
          if l_ret <> 1  then
             display l_mensagem, " - BDBSA067 - AVISE A INFORMATICA!"
             #rollback work
          else
            #commit work

            if w_servapoio = "S" then
               ### RETER P/ANALISE SERVICO COM OUTRA SOLIC.2:00hs
               call ctb00g01_anlsrv( 33 ,
                                     "",
                                     ws.atdsrvnum,
                                     ws.atdsrvano,
                                     999999 )
            else
               if w_grupoprob = "S" then
                  ### RETER P/ANALISE SERVICO COM OUTRA SOLIC.2:00hs
                  call ctb00g01_anlsrv( 1 ,
                                        "",
                                        ws.atdsrvnum,
                                        ws.atdsrvano,
                                        999999 )
               end if
            end if

            output to report bdbsa067_rel(d_bdbsa067.ciaempcod,
                                        l_empresa,
                                        ws.auxdat   ,
                                        ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.nom,
                                        ws.atdsrvorg,
                                        ws.atddat,
                                        ws.atdhor,
                                        d_bdbsa067.ramcod,
                                        d_bdbsa067.succod,
                                        d_bdbsa067.aplnumdig,
                                        d_bdbsa067.itmnumdig)
             let  w_grupoprob = "N"
             let w_servapoio = "N"
          end if

       end if

    end foreach

    if l_erro then    ## PSI176656
       exit foreach   ## PSI176656
    end if            ## PSI176656

 end foreach

 if l_erro then      ## PSI176656
    exit program(1)  ## PSI176656
 end if              ## PSI176656

 finish report bdbsa067_rel

 let ws.comando = "Serv p/analise outra solic ", m_aux, "h dia ",ws.datatd clipped," DBS06701" ### PSI188255 - Lucas Scheid

 let l_retorno = ctx22g00_envia_email("BDBSA067",
                                      ws.comando,
                                      ws.pathrel01)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro ao enviar email(ctx22g00) - ",ws.pathrel01
    else
       display "Nao foi encontrado email para o modulo - BDBSA067 "
    end if
 end if

 #let ws.comando = "mailx -s 'Servicos Ret.outra solic.2:00h de ",ws.datatd," DAT06701' ",
 #                 "Ct24hs_Relatorios/spaulo_ct24hs_teleatendimento@u55 < ",
 #                 ws.pathrel01 clipped
 #run ws.comando

end function #  bdbsa067
##-------------------------------##
function bdbsa067_espera(l_param)
##-------------------------------##

define l_param record
   dataini date,
   horaini datetime hour to minute,
   datafim date,
   horafim datetime hour to minute
end record

define ls record
    resdat integer,
    reshor interval hour(06) to minute,
    chrhor char(07)
end record

initialize ls.* to null

let ls.resdat = (l_param.datafim - l_param.dataini) * 24
let ls.reshor = (l_param.horafim - l_param.horaini)

let ls.chrhor = ls.resdat using "###&", ":00"
let ls.reshor = ls.reshor + ls.chrhor

return ls.reshor

end function

#----------------------------------------------------------------------------#
 report bdbsa067_rel( param_ciaempcod, param_empresa, param_data, r_bdbsa067 )
#----------------------------------------------------------------------------#

 define param_ciaempcod like datmservico.ciaempcod
 define param_empresa   char(50)
 define param_data      date

 define r_bdbsa067   record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    nom              like datmservico.nom       ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atddat           like datmservico.atddat    ,
    atdhor           like datmservico.atdhor    ,
    ramcod           like datrservapol.ramcod   ,
    succod           like datrservapol.succod   ,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig
 end record

 define ws1           record
    tottipsrv        array[2] of integer,
    srvtipabvdes     like datksrvtip.srvtipabvdes
 end record


   output
      left   margin  000
      top    margin  000
      bottom margin  000

   order by  param_ciaempcod

   format

    ## first page header
    ##
    ##      print column 072, "DBS067-01" # PSI 185035
    ##      print column 062, "DATA   : ", today
    ##      print column 062, "HORA   :   ", time
    ##      print column 002, "SERVICOS RETIDOS P/ANALISE OUTRA SOLIC.NO PERIODO DE ", m_aux, "H :", param_data ### PSI188255 - Lucas Scheid
    ##      skip 1 lines
    ##      print column 002, param_empresa
    ##      skip 1 lines
    ##      print column 001, g_traco
    ##      skip 1 line

    ## page header
    ##
    ##      print column 072, "DBS067-01" # PSI 185035
    ##      print column 062, "DATA   : ", today
    ##      print column 062, "HORA   :   ", time
    ##      print column 002, "SERVICOS RETIDOS P/ANALISE OUTRA SOLIC.NO PERIODO DE ", m_aux, "H :", param_data ### PSI188255 - Lucas Scheid
    ##      skip 1 lines
    ##      print column 002, param_empresa
    ##      skip 1 lines
    ##      print column 001, g_traco
    ##      skip 1 line

    before group of param_ciaempcod
           print column 072, "DBS067-01" # PSI 185035
           print column 062, "DATA   : ", today
           print column 062, "HORA   :   ", time
           print column 002, "SERVICOS RETIDOS P/ANALISE OUTRA SOLIC.NO PERIODO DE ", m_aux, "H :", param_data ### PSI188255 - Lucas Scheid
           skip 1 lines
           print column 002, param_empresa
           skip 1 lines
           print column 001, g_traco
           skip 1 line


    after group of param_ciaempcod
       skip to top of page

      on every row

           let ws1.srvtipabvdes = "NAO PREV."
           open  c_datksrvtip using r_bdbsa067.atdsrvorg
           fetch c_datksrvtip into  ws1.srvtipabvdes
           close c_datksrvtip

           print column 001, "SERVICO......: ",
                             r_bdbsa067.atdsrvorg  using "&&",
                             "/", r_bdbsa067.atdsrvnum  using "&&&&&&&",
                             "-", r_bdbsa067.atdsrvano  using "&&"
           print column 001, "DOCUMENTO....: ";
           if r_bdbsa067.succod    is null  and
              r_bdbsa067.aplnumdig is null  and
              r_bdbsa067.itmnumdig is null  then
              print column 016, "**NAO INFORMADO**"
           else
              print column 016, r_bdbsa067.ramcod     using "&&&&"      ,
                           "/", r_bdbsa067.succod     using "&&"        ,
                           "/", r_bdbsa067.aplnumdig  using "<<<<<<<& &",
                           "/", r_bdbsa067.itmnumdig  using "<<<<<& &"
           end if
           print column 001, "SEGURADO.....: ", r_bdbsa067.nom
           print column 001, "TIPO SERVICO.: ", r_bdbsa067.atdsrvorg using "&&",
                                         " - ", ws1.srvtipabvdes
           print column 001, "DATA / HORA..: ", r_bdbsa067.atddat,
                             " ", r_bdbsa067.atdhor
           skip 1 lines


end report  ###  bdbsa067_rel
 
function fonetica2()
end function