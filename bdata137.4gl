#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : bdata137                                                   #
# Analista Resp : Roberto Reboucas                                           #
#                 Carga das Apolices para a tabela de movimentação           #
#............................................................................#
# Desenvolvimento: Amilton Pinto                                             #
#                  Marcos Goes                                               #
# Liberacao      : 30/11/2010                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 22/07/2015 Alberto/Roberto           Impeditivas Itau
#----------------------------------------------------------------------------#
database porto

define m_bdata137_prep     smallint

globals
   define g_ismqconn smallint
end globals
define m_path_origem     char(100)
define m_path_processado char(100)
define m_path_log        char(100)
define m_emails          char(10000)
define m_emails_cc       char(10000)
define m_emails_erro     char(1000)
define m_qtd_impeditivas integer

define l_retorno         smallint


#========================================================================
main
#========================================================================

   # Funcao responsavel por preparar o programa para a execucao
   # - Prepara as instrucoes SQL
   # - Obtem os caminhos de processamento
   # - Cria o arquivo de log
   #

   call fun_dba_abre_banco("CT24HS")

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")
   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if
   display 'Diretorio: ',m_path_log
   let m_path_log = m_path_log clipped, "/bdata137.log"
   display 'Criando Log em: ',m_path_log
   call startlog(m_path_log)
   display 'LOG STARTADO'
   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata137_prep = false

   let l_retorno = 0
   call bdata137_prepare()

   call bdata137_obtem_caminhos()
   {call bdata137_cria_log()}

   call bdata137()
     returning l_retorno

#========================================================================
end main  # fim do Main
#========================================================================


#========================================================================
function bdata137_prepare()
#========================================================================

   define l_sql char(2000)

   let l_sql = "INSERT INTO datmdetitaasiarq",
               "(itaasiarqvrsnum,itaasiarqlnhnum,itaciacod,itaramcod,",
               "itaaplnum,itaaplitmnum,itaaplvigincdat,itaaplvigfnldat,",
               "itaprpnum,itaprdcod,itasgrplncod,itaempasicod,itaasisrvcod,",
               "rsrcaogrtcod,segnom,pestipcod,segcgccpfnum,seglgdnom,",
               "seglgdnum,segendcmpdes,segbrrnom,segcidnom,segufdsgl,",
               "segcepnum,segresteldddnum,segrestelnum,autchsnum,autplcnum,",
               "autfbrnom,autlnhnom,autmodnom,autfbrano,autmodano,autcmbnom,",
               "autcornom,autpintipdes,itavclcrgtipcod,mvtsttcod,adniclhordat,",
               "itapcshordat,asiincdat,okmflg,impautflg,itacorsuscod,",
               "rsclclcepnum,itacliscocod,itaaplcanmtvcod,itarsrcaosrvcod,",
               "itaclisgmcod,casfrqvlr,ubbcod,porvclcod,frtmdlnom,plndes,",
               "vndcnldes,bldflg,vcltipnom) ",
               " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,",
               "         ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
   prepare p_bdata137_001 from l_sql



   let l_sql = "SELECT itaasiarqvrsnum,itaasiarqlnhnum,itaciacod,itaramcod,",
               " itaaplnum,itaaplitmnum,itaaplvigincdat,itaaplvigfnldat,itaprpnum,",
               " itaprdcod,itasgrplncod,itaempasicod,itaasisrvcod,rsrcaogrtcod,",
               " segnom,pestipcod,segcgccpfnum,seglgdnom,seglgdnum,segendcmpdes,",
               " segbrrnom,segcidnom,segufdsgl,segcepnum,segresteldddnum,",
               " segrestelnum,autchsnum,autplcnum,autfbrnom,autlnhnom,autmodnom,",
               " autfbrano,autmodano,autcmbnom,autcornom,autpintipdes,",
               " itavclcrgtipcod,mvtsttcod,adniclhordat,itapcshordat,asiincdat,",
               " okmflg,impautflg,itacorsuscod,rsclclcepnum,itacliscocod,",
               " itaaplcanmtvcod,itarsrcaosrvcod,itaclisgmcod,casfrqvlr,",
               " ubbcod,porvclcod,frtmdlnom,plndes,vndcnldes,bldflg,vcltipnom  ",
               "FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   itaasiarqlnhnum > ? ",
               "ORDER BY itaasiarqlnhnum  "
   prepare p_bdata137_002 from l_sql
   declare c_bdata137_002 cursor with hold for p_bdata137_002

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? "
   prepare p_bdata137_003 from l_sql
   declare c_bdata137_003 cursor with hold for p_bdata137_003

   let l_sql = "SELECT NVL(MAX(crgarqremnum),0)+1, NVL(MAX(itaasiarqvrsnum),0)+1 ",
               "FROM datmhdritaasiarq"
   prepare p_bdata137_004 from l_sql
   declare c_bdata137_004 cursor with hold for p_bdata137_004

   let l_sql = "INSERT INTO datmhdritaasiarq ",
               "(itaasiarqvrsnum, mvtdat, arqgerinchordat, prsnom, arqnom, ",
               " arqgerfnlhordat, lnhtotqtd, crglnhqtd, fnzimpflg, crgarqremnum) ",
               "VALUES (?, ?, current, ?, ?, NULL, ?, ?, ?, ?) "
   prepare p_bdata137_005 from l_sql

   let l_sql = "SELECT itaasiarqvrsnum, mvtdat, prsnom, arqnom,      ",
               "       lnhtotqtd, crglnhqtd, fnzimpflg, crgarqremnum ",
               "FROM datmhdritaasiarq ",
               "WHERE itaasiarqvrsnum = ? "
   prepare p_bdata137_006 from l_sql
   declare c_bdata137_006 cursor with hold for p_bdata137_006

   let l_sql = "UPDATE datmhdritaasiarq ",
               "SET mvtdat          = ? ",
               "   ,prsnom          = ? ",
               "   ,arqnom          = ? ",
               "   ,arqgerfnlhordat = current ",
               "   ,lnhtotqtd       = ? ",
               "   ,crglnhqtd       = ? ",
               "   ,fnzimpflg       = ? ",
               "   ,crgarqremnum    = ? ",
               "WHERE itaasiarqvrsnum = ? "
   prepare p_bdata137_007 from l_sql

   create temp table t_arquivos(arquivo char(200)) with no log

   let l_sql = "SELECT arquivo from t_arquivos "
   prepare p_bdata137_008 from l_sql
   declare c_bdata137_008 cursor with hold for p_bdata137_008

   let l_sql = "SELECT itaasiarqvrsnum, crglnhqtd ",
               "FROM datmhdritaasiarq ",
               "WHERE itaasiarqvrsnum IN ",
               "  (SELECT NVL(MAX(itaasiarqvrsnum),0) + 1 ",
               "   FROM datmitaarqpcshst ",
               "   WHERE fnzpcsflg = 'S') ",
               "AND fnzimpflg = 'S' "
   prepare p_bdata137_009 from l_sql
   declare c_bdata137_009 cursor with hold for p_bdata137_009

   let l_sql = "SELECT itaasiarqvrsnum, pcsseqnum, lnhtotqtd, NVL(pcslnhqtd,0) ",
               "FROM datmitaarqpcshst ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   fnzpcsflg = 'N' ",
               "ORDER BY pcsseqnum "
   prepare p_bdata137_010 from l_sql
   declare c_bdata137_010 cursor with hold for p_bdata137_010

   let l_sql = 'SELECT cgccpfnum     '
             , '     , cgccpford     '
             , '     , cgccpfdig     '
             , '     , pestipcod     '
             , '     , atvflg        '
             , '  FROM datkitavippes '
             , ' WHERE atvflg = "S"  '
   prepare p_bdata137_011 from l_sql
   declare c_bdata137_011 cursor with hold for p_bdata137_011

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "S"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "N"  '
   prepare p_bdata137_012 from l_sql

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "S"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgcordnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "N"  '
   prepare p_bdata137_013 from l_sql

   let l_sql = 'SELECT cgccpfnum     '
             , '     , cgccpford     '
             , '     , cgccpfdig     '
             , '     , pestipcod     '
             , '     , atvflg        '
             , '  FROM datkitavippes '
             , ' WHERE atvflg = "N"  '
   prepare p_bdata137_014 from l_sql
   declare c_bdata137_014 cursor with hold for p_bdata137_014

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "N"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "S"  '
   prepare p_bdata137_015 from l_sql

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "N"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgcordnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "S"  '
   prepare p_bdata137_016 from l_sql

   let l_sql = "SELECT HDR.arqgerinchordat, HDR.arqgerfnlhordat, HDR.arqnom, HDR.crgarqremnum, ",
               "       PCS.arqpcsinchordat, PCS.arqpcsfnlhordat, PCS.lnhtotqtd ",
               "FROM datmitaarqpcshst PCS ",
               "INNER JOIN datmhdritaasiarq HDR ",
               "   ON HDR.itaasiarqvrsnum = PCS.itaasiarqvrsnum ",
               "WHERE PCS.itaasiarqvrsnum = ? ",
               "AND   PCS.pcsseqnum       = ? "
   prepare p_bdata137_017 from l_sql
   declare c_bdata137_017 cursor with hold for p_bdata137_017

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaapl APL ",
               "INNER JOIN datmitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.itaaplnum = ITM.itaaplnum ",
               "WHERE APL.itaasiarqvrsnum = ? "
   prepare p_bdata137_018 from l_sql
   declare c_bdata137_018 cursor with hold for p_bdata137_018

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaapl ",
               "WHERE itaasiarqvrsnum = ? "
   prepare p_bdata137_019 from l_sql
   declare c_bdata137_019 cursor with hold for p_bdata137_019

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaasiarqico ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   impicoflg = 'S' "
   prepare p_bdata137_020 from l_sql
   declare c_bdata137_020 cursor with hold for p_bdata137_020

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaasiarqico ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   impicoflg = 'N' "
   prepare p_bdata137_021 from l_sql
   declare c_bdata137_021 cursor with hold for p_bdata137_021

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaapl APL ",
               "INNER JOIN datmitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.itaaplnum = ITM.itaaplnum ",
               "WHERE APL.itaasiarqvrsnum = ? ",
               "AND   ITM.itaaplitmsttcod = 'I' "
   prepare p_bdata137_022 from l_sql
   declare c_bdata137_022 cursor with hold for p_bdata137_022

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaapl APL ",
               "INNER JOIN datmitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.itaaplnum = ITM.itaaplnum ",
               "WHERE APL.itaasiarqvrsnum = ? ",
               "AND   ITM.itaaplitmsttcod = 'C' "
   prepare p_bdata137_023 from l_sql
   declare c_bdata137_023 cursor with hold for p_bdata137_023

   let l_sql = "SELECT cpodes ",
               "FROM datkdominio ",
               "WHERE cponom = 'itau_caminhos' ",
               "AND   cpocod = ? "
   prepare p_bdata137_024 from l_sql
   declare c_bdata137_024 cursor with hold for p_bdata137_024

   let l_sql = "SELECT cpodes    ",
               "FROM datkdominio ",
               "WHERE cponom = 'itau_email_carga' ",
               "ORDER BY cpocod "
   prepare p_bdata137_025 from l_sql
   declare c_bdata137_025 cursor with hold for p_bdata137_025

   let l_sql = "SELECT count(*) ",
               "FROM datmitaasiarqico INCON ",
               "INNER JOIN datmitaarqpcshst HIST ",
               "   ON HIST.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND HIST.pcsseqnum = INCON.pcsseqnum ",
               "INNER JOIN datmdetitaasiarq DETALHE ",
               "   ON DETALHE.itaasiarqvrsnum = INCON.itaasiarqvrsnum ",
               "  AND DETALHE.itaasiarqlnhnum = INCON.itaasiarqlnhnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.libicoflg = 'N' "
               
   prepare p_bdata137_026 from l_sql
   declare c_bdata137_026 cursor with hold for p_bdata137_026

   let m_bdata137_prep = true

#========================================================================
end function # Fim da função bdata137_prepare
#========================================================================

#========================================================================
function bdata137()
#========================================================================
   define lr_erro record
          sqlcode  smallint
         ,mens     char(80)
   end record

   define l_resposta smallint
   let l_resposta = 0
   initialize lr_erro.* to null

   #call bdata137_prepare()
   
   let m_qtd_impeditivas = 0
   whenever error continue
   open c_bdata137_026
   fetch c_bdata137_026 into m_qtd_impeditivas   
   whenever error stop
   close c_bdata137_026

   call bdata137_exibe_inicio()


   # RECUPERA ARQUIVO
   call bdata137_recupera_arquivos()
      returning lr_erro.*
   call bdata137_trata_erro(lr_erro.*)
       returning l_resposta

     if l_resposta = 1 then
       return l_resposta
     end if

   # IMPORTA ARQUIVO
   call bdata137_processa_importacao()
      returning lr_erro.*
   call bdata137_trata_erro(lr_erro.*)
      returning l_resposta

     if l_resposta = 1 then
        return l_resposta
     end if

   # CARREGA BASE
   call bdata137_processa_carga()
      returning lr_erro.*
   call bdata137_trata_erro(lr_erro.*)
      returning l_resposta

     if l_resposta = 1 then
        return l_resposta
     end if

   # PROCESSA CLIENTES VIP (ATIVOS)
   call bdata137_processa_apolice_pessoa_vip_ativo()
       returning lr_erro.*
   call bdata137_trata_erro(lr_erro.*)
      returning l_resposta

     if l_resposta = 1 then
        return l_resposta
     end if

   # PROCESSA CLIENTES VIP (INATIVOS)
   call bdata137_processa_apolice_pessoa_vip_NAO_ativo()
        returning lr_erro.*
   call bdata137_trata_erro(lr_erro.*)
      returning l_resposta

     if l_resposta = 1 then
        return l_resposta
     end if

   call bdata137_exibe_final()


   drop table t_arquivos
  return l_resposta
#========================================================================
end function # Fim da Funcao bdata137
#========================================================================

#========================================================================
function bdata137_recupera_arquivos()
#========================================================================
   define l_comando  char(800)
   define l_erro     integer
   define l_sql      char(100)
   define l_codigo   smallint

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   display " "
   display "-----------------------------------------------------------"
   display "           .:: RECUPERANDO ARQUIVOS DE CARGA ::.           "
   display "-----------------------------------------------------------"
   call errorlog('RECUPERANDO ARQUIVOS DE CARGA')


   {let l_comando = "ls ",
                   m_path_origem clipped, "*.TXT ",
                   m_path_origem clipped, "*.V* > temp"
   run l_comando returning l_erro}


   let l_comando = "ls "
                  ,m_path_origem clipped, "R1OBCP*.TXT "
                  ,m_path_origem clipped, "R1OBCP*.V* > temp"
   run l_comando returning l_erro


{
   if l_erro <> 0 then
      let lr_erro.sqlcode = l_erro
      let lr_erro.mens = 'Erro (' , lr_erro.sqlcode ,') na recuperacao dos arquivos de carga.'
      call errorlog(lr_erro.mens)
      call errorlog("Nenhum arquivo encontrado...")
      #return lr_erro.*
   end if
}
   whenever error continue
   load from 'temp' insert into t_arquivos
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = 'Erro (' , lr_erro.sqlcode ,') na recuperacao dos arquivos de carga.'
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*

#========================================================================
end function # Fim da Funcao bdata137_recupera_arquivos
#========================================================================
#========================================================================
function bdata137_armazena_arquivo(l_arquivo)
#========================================================================
   define l_arquivo  char(200)
   define l_comando  char(800)
   define l_erro     integer

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   let l_comando = "mv ", l_arquivo clipped, " ", m_path_processado clipped, "."
   run l_comando returning l_erro

   if l_erro <> 0 then
      let lr_erro.sqlcode = l_erro
      let lr_erro.mens = 'Erro (' , lr_erro.sqlcode ,') na copia para a pasta de processados.'
      call errorlog(lr_erro.mens)
      let lr_erro.mens = 'Arquivo: ', l_arquivo clipped
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*

#========================================================================
end function # Fim da Funcao bdata137_armazena_arquivo
#========================================================================

#========================================================================
function bdata137_cria_log()
#========================================================================

   define l_path char(200)

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")

   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if

   display 'Diretorio: ',m_path_log
   let m_path_log = m_path_log clipped, "bdata137.log"

   display 'Criando Log em: ',m_path_log
   call startlog(m_path_log)

#========================================================================
end function  # fim da função bdata137_cria_log
#========================================================================

#========================================================================
function bdata137_processa_importacao()
#========================================================================

   define lr_header record
      itaasiarqvrsnum   like datmhdritaasiarq.itaasiarqvrsnum
     ,mvtdat            like datmhdritaasiarq.mvtdat
     ,prsnom            like datmhdritaasiarq.prsnom
     ,arqnom            like datmhdritaasiarq.arqnom
     ,lnhtotqtd         like datmhdritaasiarq.lnhtotqtd
     ,crglnhqtd         like datmhdritaasiarq.crglnhqtd
     ,fnzimpflg         like datmhdritaasiarq.fnzimpflg
     ,crgarqremnum      like datmhdritaasiarq.crgarqremnum
   end record

   define lr_trailer record
      qtd_movimentos    integer
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_contador        integer
   define l_parcial         integer
   define l_grlinf          integer
   define l_linha           char(800)
   define l_arquivo         char(200)
   define l_arquivo2        char(200)
   define l_versao          smallint

   define l_num_versao      char(5)
   define l_indice          smallint
   define l_novo_arquivo    char(50)
   define l_comando         char(150)
   define l_erro            integer

   define l_file            integer
   define l_eof             integer
   define l_mens            char(80)

   initialize lr_erro.* to null

   display " "
   display "-----------------------------------------------------------"
   display "           .:: IMPORTANDO ARQUIVOS DE CARGA ::.            "
   display "-----------------------------------------------------------"
   call errorlog("IMPORTANDO ARQUIVOS DE CARGA")

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if


   whenever error continue
   open c_bdata137_008
   foreach c_bdata137_008 into l_arquivo

      initialize lr_header.* to null
      initialize lr_trailer.* to null

      call bdata137_extrai_nome_arquivo(l_arquivo)
          returning l_arquivo2

      let l_versao = 0

      call bdata137_verifica_versao_arquivo(l_arquivo2)
      returning l_versao

      display "ARQUIVO.: ", l_arquivo2 clipped
      display "VERSAO..: ", l_versao clipped

      {let  l_arquivo = "./", lr_header.arqnom clipped
      let  l_arquivo = m_path_origem clipped, lr_header.arqnom clipped
      let  l_arquivo = m_path_origem clipped, l_arquivo clipped}


      # Abre arquivo em modo de leitura e devolve identificador
      call abrearq(l_arquivo clipped,0)
      returning l_file

      if l_file = -1 then
         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Erro ao abrir o arquivo para HEADER: ", l_arquivo2 clipped, "."
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if


      # Exibe log indicando o inicio do processamento do arquivo
      display " ARQUIVO............: ", l_arquivo2 clipped
      let l_mens = " ARQUIVO IMPORTANDO: ", l_arquivo2 clipped
      call errorlog(l_mens)

      call learq(l_file,798) returning l_linha, l_eof

      {display "##:", l_linha clipped
      sleep 1}

      if l_eof = 0 then
         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Final do arquivo antes do header: ", l_arquivo2 clipped, "."
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if

      # Le o Header quebrando as colunas do arquivo
      call bdata137_le_header(l_linha)
      returning lr_header.*

      # Fecha o arquivo
      call fechaarq(l_file)

      if lr_header.crgarqremnum is null or
         lr_header.crgarqremnum <= 0 then

         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Header nao encontrado na primeira linha do arquivo: ", l_arquivo2 clipped
         call errorlog(lr_erro.mens)
         return lr_erro.*
      end if

      {if l_versao > 0 and
         l_versao <> lr_header.vrscod then

         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Versao do header nao coincide com nome do arquivo: ", l_arquivo2 clipped
         call errorlog(lr_erro.mens)
         return lr_erro.*
      end if}


      if l_versao = 0 then
         # Trata arquivos novos verificando a versao e renomeando
         let lr_header.arqnom = l_arquivo2 clipped

         call bdata137_insere_header(lr_header.*)
         returning lr_erro.*, lr_header.*

         if lr_erro.sqlcode <> 0 then
            return lr_erro.*
         end if

         let l_num_versao = lr_header.itaasiarqvrsnum using "&&&&&"
         let l_novo_arquivo = l_arquivo2 clipped, ".V", l_num_versao

         let l_comando = "mv ", m_path_origem clipped, l_arquivo2 clipped, " ", m_path_origem clipped, l_novo_arquivo clipped
         run l_comando returning l_erro

         if l_erro <> 0 then
            let lr_erro.sqlcode = l_erro
            let lr_erro.mens = "Erro (" , lr_erro.sqlcode clipped ,") ao renomear o arquivo de carga: ", lr_header.arqnom
            call errorlog(lr_erro.mens)
            return lr_erro.*
         end if

         {display "ARQUIVO ORIGINAL..: ",l_arquivo2
         display "ARQUIVO RENOMEADO.: ",l_novo_arquivo
         display "NOVA VERSAO.......: ",lr_header.itaasiarqvrsnum}

         let l_arquivo = m_path_origem clipped, l_novo_arquivo clipped

      else
         # Ja existe marcacao de versao no arquivo.
         call bdata137_consulta_header(l_versao)
         returning lr_erro.*, lr_header.*

         if lr_erro.sqlcode <> 0 then
            return lr_erro.*
         end if

         # Verifica se o arquivo ja foi processado
         if upshift(lr_header.fnzimpflg) = "S" then
            let lr_erro.sqlcode = 1
            let lr_erro.mens = "Erro. Arquivo versao ", lr_header.itaasiarqvrsnum using "<<<<<", " ja foi processado."
            display lr_erro.mens
            call errorlog(lr_erro.mens)
            continue foreach
            #return lr_erro.*
         end if

      end if


      # Abre arquivo em modo de leitura e devolve identificador
      call abrearq(l_arquivo clipped,0)
      returning l_file

      if l_file = -1 then
         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Erro ao abrir o arquivo para leitura: ", l_arquivo2 clipped, "."
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if

      # Loop de Leitura do arquivo sequencial ate final (l_eof = 0)
      let l_parcial = 0
      let l_contador = 0

      display " VERSAO ............: ", lr_header.itaasiarqvrsnum clipped
      let l_mens = " VERSAO IMPORTANDO: ", lr_header.itaasiarqvrsnum clipped
      call errorlog(l_mens)
      display " REMESSA............: ", lr_header.crgarqremnum clipped
      let l_mens = " REMESSA IMPORTANDO: ", lr_header.crgarqremnum clipped
      call errorlog(l_mens)

      begin work
      while true

         # Le a proxima linha do arquivo retornando uma string
         # e um indicador verifica se o final de arquivo foi atingido
         call learq(l_file,798) returning l_linha, l_eof

         if l_eof = 0 then
            exit while
         end if

         # Divide a string recebida pela leitura em campos e carrega na
         # tabela de movimento (datmdetitaasiarq)
         let l_contador = l_contador + 1

         if l_contador <= lr_header.crglnhqtd then
            # Pular as linhas ja processadas em processamentos anteriores
            # Vai ignorando as linhas ate chegar onde se deve reiniciar o processo
            continue while
         end if

         call bdata137_le_trailer (l_linha)
         returning lr_trailer.*

         if lr_trailer.qtd_movimentos is not null and
            lr_trailer.qtd_movimentos <> 0 then
            exit while
         end if


         call bdata137_carrega_tabela_movimento(l_contador, l_linha, lr_header.itaasiarqvrsnum)
         returning lr_erro.*

         if lr_erro.sqlcode = 0 then
            let l_parcial = l_parcial + 1
            if l_parcial >= 1000 then
               let l_parcial = 0

               let lr_header.crglnhqtd = l_contador
               let lr_header.fnzimpflg = "N"

               call bdata137_atualiza_header(lr_header.*)
               returning lr_erro.*

               if lr_erro.sqlcode <> 0 then
                  exit while
               end if

               commit work

               display " LINHAS IMPORTADAS..: ", l_contador
               let l_mens = " LINHAS IMPORTADAS: ", l_contador
               call errorlog(l_mens)

               begin work
            end if
         else
            exit while
         end if

      end while

      if lr_erro.sqlcode = 0 then

         display " LINHAS IMPORTADAS..: ", l_contador
         let l_mens = " LINHAS IMPORTADAS: ", l_contador
         display "-----------------------------------------------------------"
         call errorlog(l_mens)

         let lr_header.crglnhqtd = l_contador
         let lr_header.lnhtotqtd = l_contador
         let lr_header.fnzimpflg = "S"

         whenever error continue
         open c_bdata137_003 using lr_header.itaasiarqvrsnum
         fetch c_bdata137_003 into l_contador
         whenever error stop
         close c_bdata137_003

         if lr_trailer.qtd_movimentos <> l_contador then
            let lr_erro.sqlcode = -1
            let lr_erro.mens = "Erro na quantidade de movimentos.",
                               " Carregados: ", l_contador using "<<<<<<<",
                               " Informados: ", lr_trailer.qtd_movimentos using "<<<<<<<"
            call errorlog(lr_erro.mens)
            call fechaarq(l_file)
            rollback work
            return lr_erro.*
         end if

         call bdata137_atualiza_header(lr_header.*)
         returning lr_erro.*

         let l_contador = 0

      end if

      # Fecha o arquivo sequencial
      call fechaarq(l_file)

      if lr_erro.sqlcode = 0 then
         commit work
      else
         rollback work
         return lr_erro.*
      end if

      call bdata137_armazena_arquivo(l_arquivo)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         continue foreach
         #return lr_erro.*
      end if


   end foreach
   close c_bdata137_008

   let lr_erro.sqlcode = 0
   return lr_erro.*

#=======================================================
end function # Fim da função bdata137_processa_importacao
#=======================================================


#=======================================================
function bdata137_verifica_versao_arquivo(lr_param)
#=======================================================
   define lr_param record
      arquivo     char(200)
   end record

   define l_indice smallint
   define l_versao smallint

   let l_indice = 200
   let l_versao = 0

   while l_indice >= 1
      if lr_param.arquivo[l_indice] = "/" then
         exit while
      end if
      let l_indice = l_indice - 1
   end while

   let l_indice = l_indice + 1

   while l_indice <= 194
      if lr_param.arquivo[l_indice, l_indice + 1] = ".V" then
         let l_versao = lr_param.arquivo[l_indice + 2, l_indice + 6]
         exit while
      end if
      let l_indice = l_indice + 1
   end while

   return l_versao

#=======================================================
end function # Fim da função bdata137_verifica_versao_arquivo
#=======================================================

#=======================================================
function bdata137_extrai_nome_arquivo(lr_param)
#=======================================================
   define lr_param record
      arquivo     char(200)
   end record

   define l_indice1 smallint
   define l_indice2 smallint

   let l_indice1 = 200

   while l_indice1 >= 1
      if lr_param.arquivo[l_indice1] = "/" then
         exit while
      end if
      let l_indice1 = l_indice1 - 1
   end while

   let l_indice1 = l_indice1 + 1
   let l_indice2 = l_indice1 + 1

   while l_indice2 <= 200
      if lr_param.arquivo[l_indice2] = " " then
         let l_indice2 = l_indice2 - 1
         exit while
      end if
      let l_indice2 = l_indice2 + 1
   end while

   let lr_param.arquivo = lr_param.arquivo[l_indice1, l_indice2]

   return lr_param.arquivo

#=======================================================
end function # Fim da função bdata137_extrai_nome_arquivo
#=======================================================

#=======================================================
function bdata137_verifica_proximo_processamento()
#=======================================================

   define lr_hist_process record
       asiarqvrsnum     like datmitaarqpcshst.itaasiarqvrsnum
      ,pcsseqnum        like datmitaarqpcshst.pcsseqnum
      ,lnhtotqtd        like datmitaarqpcshst.lnhtotqtd
      ,pcslnhqtd        like datmitaarqpcshst.pcslnhqtd
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if

   initialize lr_hist_process.* to null

   # Verifica e busca se ha alguma versao de movimento que possa ser processada
   whenever error continue
   open c_bdata137_009
   fetch c_bdata137_009 into lr_hist_process.asiarqvrsnum, lr_hist_process.lnhtotqtd
   whenever error stop
   close c_bdata137_009

   if sqlca.sqlcode = notfound or
      lr_hist_process.asiarqvrsnum is null then
      let lr_erro.sqlcode = notfound
      let lr_erro.mens = " Nao existem mais processamentos pendentes..."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_hist_process.*
   end if

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao buscar o proximo processamento..."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_hist_process.*
   end if

   # Verifica se ja existe processamento iniciado para a versao
   whenever error continue
   open c_bdata137_010 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_010 into lr_hist_process.*
   whenever error stop
   close c_bdata137_010

   if sqlca.sqlcode = notfound or
      lr_hist_process.pcslnhqtd is null then

      # Cria um novo processamento caso nao exista um processamento ja iniciado
      call cty22g02_gera_processamento(lr_hist_process.*)
      returning lr_erro.*, lr_hist_process.pcsseqnum

      let lr_hist_process.pcslnhqtd = 0

      if lr_erro.sqlcode <> 0 then
         call errorlog(lr_erro.mens)
         return lr_erro.*, lr_hist_process.*
      end if
   end if

   if sqlca.sqlcode <> 0 and
      sqlca.sqlcode <> notfound then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao buscar processamento ativo..."
      return lr_erro.*, lr_hist_process.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_hist_process.*

#=======================================================
end function # Fim da função bdata137_verifica_proximo_processamento
#=======================================================

#=======================================================
function bdata137_insere_header(lr_header)
#=======================================================

   define lr_header record
      itaasiarqvrsnum   like datmhdritaasiarq.itaasiarqvrsnum
     ,mvtdat            like datmhdritaasiarq.mvtdat
     ,prsnom            like datmhdritaasiarq.prsnom
     ,arqnom            like datmhdritaasiarq.arqnom
     ,lnhtotqtd         like datmhdritaasiarq.lnhtotqtd
     ,crglnhqtd         like datmhdritaasiarq.crglnhqtd
     ,fnzimpflg         like datmhdritaasiarq.fnzimpflg
     ,crgarqremnum      like datmhdritaasiarq.crgarqremnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_remessa_esperada smallint

   initialize lr_erro.* to null

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if

   let l_remessa_esperada = 0
   let lr_header.itaasiarqvrsnum = 0

   whenever error continue
   open c_bdata137_004
   fetch c_bdata137_004 into l_remessa_esperada, lr_header.itaasiarqvrsnum
   whenever error stop
   close c_bdata137_004

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na busca de nova versao do HEADER. Tabela: <datmhdritaasiarq>."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   if l_remessa_esperada <> lr_header.crgarqremnum then
      let lr_erro.sqlcode = -1
      let lr_erro.mens = "Conflito de numero de remessa. Esperada: ", l_remessa_esperada using "<<<<<",
                         " Lida: ", lr_header.crgarqremnum  using "<<<<<"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   begin work

   whenever error continue
   execute p_bdata137_005 using lr_header.itaasiarqvrsnum
                               ,lr_header.mvtdat
                               ,lr_header.prsnom
                               ,lr_header.arqnom
                               ,lr_header.lnhtotqtd
                               ,lr_header.crglnhqtd
                               ,lr_header.fnzimpflg
                               ,lr_header.crgarqremnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do HEADER. Tabela: <datmhdritaasiarq>."
      call errorlog(lr_erro.mens)
      rollback work

      return lr_erro.*, lr_header.*
   end if

   commit work
   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_header.*
#=======================================================
end function # Fim da função bdata137_insere_header
#=======================================================

#=======================================================
function bdata137_atualiza_header(lr_header)
#=======================================================

   define lr_header record
      itaasiarqvrsnum   like datmhdritaasiarq.itaasiarqvrsnum
     ,mvtdat            like datmhdritaasiarq.mvtdat
     ,prsnom            like datmhdritaasiarq.prsnom
     ,arqnom            like datmhdritaasiarq.arqnom
     ,lnhtotqtd         like datmhdritaasiarq.lnhtotqtd
     ,crglnhqtd         like datmhdritaasiarq.crglnhqtd
     ,fnzimpflg         like datmhdritaasiarq.fnzimpflg
     ,crgarqremnum      like datmhdritaasiarq.crgarqremnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if

   whenever error continue
   execute p_bdata137_007 using  lr_header.mvtdat
                                ,lr_header.prsnom
                                ,lr_header.arqnom
                                ,lr_header.lnhtotqtd
                                ,lr_header.crglnhqtd
                                ,lr_header.fnzimpflg
                                ,lr_header.crgarqremnum
                                ,lr_header.itaasiarqvrsnum
   whenever error stop


   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na atualizacao do HEADER. Tabela: <datmhdritaasiarq>."
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*
#=======================================================
end function # Fim da função bdata137_atualiza_header
#=======================================================
#=======================================================
function bdata137_le_trailer(l_linha)
#=======================================================
   define l_linha char(800)

   define lr_trailer record
      qtd_movimentos    integer
   end record

   define l_tpreg char(1)
         ,l_count integer

   initialize lr_trailer.* to null

   let l_tpreg = null
   let l_tpreg = l_linha[1,1]

   let lr_trailer.qtd_movimentos = 0

   case l_tpreg

      when 9 #--Distribui a string nos campos do registro Trailer------#
      let lr_trailer.qtd_movimentos = l_linha[60,74]

   end case

   #display "MOVIMENTOS: ", lr_trailer.qtd_movimentos

   return lr_trailer.*
#=======================================================
end function # Fim da função bdata137_le_trailer
#=======================================================

#=======================================================
function bdata137_le_header(l_linha)
#=======================================================
   define l_linha char(800)

   define lr_header record
      itaasiarqvrsnum   like datmhdritaasiarq.itaasiarqvrsnum
     ,mvtdat            like datmhdritaasiarq.mvtdat
     ,prsnom            like datmhdritaasiarq.prsnom
     ,arqnom            like datmhdritaasiarq.arqnom
     ,lnhtotqtd         like datmhdritaasiarq.lnhtotqtd
     ,crglnhqtd         like datmhdritaasiarq.crglnhqtd
     ,fnzimpflg         like datmhdritaasiarq.fnzimpflg
     ,crgarqremnum      like datmhdritaasiarq.crgarqremnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_tpreg char(1)
         ,l_count integer

   initialize lr_erro.* to null
   initialize lr_header.* to null

   let l_tpreg = null
   let l_tpreg = l_linha[1,1]

   case l_tpreg

      when 0 #--Distribui a string nos campos do registro Header------#

      let lr_header.itaasiarqvrsnum       = 0
      let lr_header.mvtdat                = l_linha[2,9]
      let lr_header.prsnom                = l_linha[10,54]
      let lr_header.crgarqremnum          = l_linha[55,59]
      let lr_header.arqnom                = " "
      let lr_header.lnhtotqtd             = 0
      let lr_header.crglnhqtd             = 0
      let lr_header.fnzimpflg             = "N"

   end case

   return lr_header.*
#=======================================================
end function # Fim da função bdata137_le_header
#=======================================================

#=======================================================
function bdata137_consulta_header(lr_param)
#=======================================================
   define lr_param record
      versao   smallint
   end record

   define lr_header record
      itaasiarqvrsnum   like datmhdritaasiarq.itaasiarqvrsnum
     ,mvtdat            like datmhdritaasiarq.mvtdat
     ,prsnom            like datmhdritaasiarq.prsnom
     ,arqnom            like datmhdritaasiarq.arqnom
     ,lnhtotqtd         like datmhdritaasiarq.lnhtotqtd
     ,crglnhqtd         like datmhdritaasiarq.crglnhqtd
     ,fnzimpflg         like datmhdritaasiarq.fnzimpflg
     ,crgarqremnum      like datmhdritaasiarq.crgarqremnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null
   initialize lr_header.* to null

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if

   whenever error continue
   open c_bdata137_006 using lr_param.versao
   fetch c_bdata137_006 into lr_header.*
   whenever error stop
   close c_bdata137_006

   if sqlca.sqlcode = notfound or
      lr_header.itaasiarqvrsnum is null then
      let lr_erro.sqlcode = notfound
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, "). Versao ", lr_param.versao clipped , " nao encontrada."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na consulta de HEADER. Tabela: <datmhdritaasiarq>."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_header.*
#=======================================================
end function # Fim da função bdata137_consulta_header
#=======================================================

#=======================================================
function bdata137_carrega_tabela_movimento(l_contador, l_linha, l_versao)
#=======================================================

   define l_contador integer
   define l_linha    char(800)
   define l_versao   smallint

   define lr_campo record
       numver         like datmdetitaasiarq.itaasiarqvrsnum
      ,numlinha       like datmdetitaasiarq.itaasiarqlnhnum
      ,cpacod         like datmdetitaasiarq.itaciacod
      ,ramcod         like datmdetitaasiarq.itaramcod
      ,aplnumdig      like datmdetitaasiarq.itaaplnum
      ,itmnumdig      like datmdetitaasiarq.itaaplitmnum
      ,viginc         like datmdetitaasiarq.itaaplvigincdat
      ,vigfnl         like datmdetitaasiarq.itaaplvigfnldat
      ,prpnumdig      like datmdetitaasiarq.itaprpnum
      ,prdcod         like datmdetitaasiarq.itaprdcod
      ,plncod         like datmdetitaasiarq.itasgrplncod
      ,empcod         like datmdetitaasiarq.itaempasicod
      ,pstservcod     like datmdetitaasiarq.itaasisrvcod
      ,flgresergar    like datmdetitaasiarq.rsrcaogrtcod
      ,segnom         like datmdetitaasiarq.segnom
      ,pestip         like datmdetitaasiarq.pestipcod
      ,cgccpfnumdig   like datmdetitaasiarq.segcgccpfnum
      ,lgdnom         like datmdetitaasiarq.seglgdnom
      ,lgdnum         like datmdetitaasiarq.seglgdnum
      ,lgdcmp         like datmdetitaasiarq.segendcmpdes
      ,brrnom         like datmdetitaasiarq.segbrrnom
      ,cidnom         like datmdetitaasiarq.segcidnom
      ,ufdcod         like datmdetitaasiarq.segufdsgl
      ,lgdcep         like datmdetitaasiarq.segcepnum
      ,cmlteldddcod   like datmdetitaasiarq.segresteldddnum
      ,cmltelnum      like datmdetitaasiarq.segrestelnum
      ,vclchassi      like datmdetitaasiarq.autchsnum
      ,vcllicnum      like datmdetitaasiarq.autplcnum
      ,vclfab         like datmdetitaasiarq.autfbrnom
      ,vcllinha       like datmdetitaasiarq.autlnhnom
      ,vclmod         like datmdetitaasiarq.autmodnom
      ,vclanofab      like datmdetitaasiarq.autfbrano
      ,vclanomod      like datmdetitaasiarq.autmodano
      ,vclcomb        like datmdetitaasiarq.autcmbnom
      ,vclcor         like datmdetitaasiarq.autcornom
      ,vcltppin       like datmdetitaasiarq.autpintipdes
      ,vcltpcarga     like datmdetitaasiarq.itavclcrgtipcod
      ,flgsttmov      like datmdetitaasiarq.mvtsttcod
      ,adtdat         like datmdetitaasiarq.adniclhordat
      ,procdat        like datmdetitaasiarq.itapcshordat
      ,assdat         like datmdetitaasiarq.asiincdat
      ,flgzerokm      like datmdetitaasiarq.okmflg
      ,flgimp         like datmdetitaasiarq.impautflg
      ,susepcod       like datmdetitaasiarq.itacorsuscod
      ,lsrcepcod      like datmdetitaasiarq.rsclclcepnum
      ,scoclicod      like datmdetitaasiarq.itacliscocod
      ,mtvcancod      like datmdetitaasiarq.itaaplcanmtvcod
      ,resercarcod    like datmdetitaasiarq.itarsrcaosrvcod
      ,sgmclicod      like datmdetitaasiarq.itaclisgmcod
      ,vlrfranquia    like datmdetitaasiarq.casfrqvlr
      ,ubbcod         like datmdetitaasiarq.ubbcod
      ,porvclcod      like datmdetitaasiarq.porvclcod
      ,frtmdlnom      like datmdetitaasiarq.frtmdlnom
      ,plndes         like datmdetitaasiarq.plndes
      ,vndcnldes      like datmdetitaasiarq.vndcnldes
      ,bldflg         like datmdetitaasiarq.bldflg
      ,vcltipnom      like datmdetitaasiarq.vcltipnom
      ,adtapol        char(5) #aditamento da apolice
      ,adtapolvrs     char(1) #versao do aditamento da apolice
      ,adtitem        char(5) #aditamento do item
      ,adtitemvrs     char(1) #versao do aditamento do item
      ,filler         char(88) #filler
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_tpreg char(1)
         ,l_count integer


   initialize lr_campo.* to null
   initialize lr_erro.* to null

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if


   let l_tpreg = null
   let l_tpreg = l_linha[1,1]

   case l_tpreg

      when 1 #--Distribui a string nos campos do registro Detalhes------#

      let lr_campo.numlinha        = l_contador
      let lr_campo.cpacod          = l_linha[2,3]
      let lr_campo.ramcod          = l_linha[4,6]
      let lr_campo.aplnumdig       = l_linha[7,15]
      let lr_campo.itmnumdig       = l_linha[16,22]
      let lr_campo.viginc          = l_linha[23,30]
      let lr_campo.vigfnl          = l_linha[31,38]
      let lr_campo.prpnumdig       = l_linha[39,47]
      let lr_campo.prdcod          = l_linha[48,51]
      let lr_campo.plncod          = l_linha[52,53]
      let lr_campo.empcod          = l_linha[54,56]
      let lr_campo.pstservcod      = l_linha[57,59]
      let lr_campo.flgresergar     = l_linha[60,60]
      let lr_campo.segnom          = l_linha[61,105]
      let lr_campo.pestip          = l_linha[106,106]
      let lr_campo.cgccpfnumdig    = l_linha[107,126]
      let lr_campo.lgdnom          = l_linha[127,176]
      let lr_campo.lgdnum          = l_linha[177,181]
      let lr_campo.lgdcmp          = l_linha[182,221]
      let lr_campo.brrnom          = l_linha[222,251]
      let lr_campo.cidnom          = l_linha[252,291]
      let lr_campo.ufdcod          = l_linha[292,293]
      let lr_campo.lgdcep          = l_linha[294,301]
      let lr_campo.cmlteldddcod    = l_linha[302,305]
      let lr_campo.cmltelnum       = l_linha[306,314]
      let lr_campo.vclchassi       = l_linha[315,334]
      let lr_campo.vcllicnum       = l_linha[335,344]
      let lr_campo.vclfab          = l_linha[345,364]
      let lr_campo.vcllinha        = l_linha[365,384]
      let lr_campo.vclmod          = l_linha[385,414]
      let lr_campo.vclanofab       = l_linha[415,418]
      let lr_campo.vclanomod       = l_linha[419,422]
      let lr_campo.vclcomb         = l_linha[423,442]
      let lr_campo.vclcor          = l_linha[443,457]
      let lr_campo.vcltppin        = l_linha[458,472]
      let lr_campo.vcltpcarga      = l_linha[473,492]
      let lr_campo.flgsttmov       = l_linha[493,493]
      let lr_campo.adtdat          = l_linha[494,507]
      let lr_campo.procdat         = l_linha[508,521]
      let lr_campo.assdat          = l_linha[522,529]
      let lr_campo.flgzerokm       = l_linha[530,530]
      let lr_campo.flgimp          = l_linha[531,531]
      let lr_campo.susepcod        = l_linha[532,540]
      let lr_campo.lsrcepcod       = l_linha[541,548]
      let lr_campo.scoclicod       = l_linha[549,573]
      let lr_campo.mtvcancod       = l_linha[574,575]
      let lr_campo.resercarcod     = l_linha[576,578]
      let lr_campo.sgmclicod       = l_linha[579,580]
      let lr_campo.vlrfranquia     = l_linha[581,590]
      let lr_campo.ubbcod          = l_linha[591,591]
      let lr_campo.porvclcod       = l_linha[592,598]
      let lr_campo.frtmdlnom       = l_linha[599,628]
      let lr_campo.plndes          = l_linha[629,658]
      let lr_campo.vndcnldes       = l_linha[659,667]
      let lr_campo.bldflg          = l_linha[668,668]
      let lr_campo.vcltipnom       = l_linha[669,698]
      let lr_campo.adtapol         = l_linha[699,703]
      let lr_campo.adtapolvrs      = l_linha[704,704]
      let lr_campo.adtitem         = l_linha[705,709]
      let lr_campo.adtitemvrs      = l_linha[710,710]
      let lr_campo.filler          = l_linha[711,798]

      #--Insere a linha detalhe na tabela de movimento ---------------------------------#

      whenever error continue
      execute p_bdata137_001 using l_versao
                                ,lr_campo.numlinha
                                ,lr_campo.cpacod
                                ,lr_campo.ramcod
                                ,lr_campo.aplnumdig
                                ,lr_campo.itmnumdig
                                ,lr_campo.viginc
                                ,lr_campo.vigfnl
                                ,lr_campo.prpnumdig
                                ,lr_campo.prdcod
                                ,lr_campo.plncod
                                ,lr_campo.empcod
                                ,lr_campo.pstservcod
                                ,lr_campo.flgresergar
                                ,lr_campo.segnom
                                ,lr_campo.pestip
                                ,lr_campo.cgccpfnumdig
                                ,lr_campo.lgdnom
                                ,lr_campo.lgdnum
                                ,lr_campo.lgdcmp
                                ,lr_campo.brrnom
                                ,lr_campo.cidnom
                                ,lr_campo.ufdcod
                                ,lr_campo.lgdcep
                                ,lr_campo.cmlteldddcod
                                ,lr_campo.cmltelnum
                                ,lr_campo.vclchassi
                                ,lr_campo.vcllicnum
                                ,lr_campo.vclfab
                                ,lr_campo.vcllinha
                                ,lr_campo.vclmod
                                ,lr_campo.vclanofab
                                ,lr_campo.vclanomod
                                ,lr_campo.vclcomb
                                ,lr_campo.vclcor
                                ,lr_campo.vcltppin
                                ,lr_campo.vcltpcarga
                                ,lr_campo.flgsttmov
                                ,lr_campo.adtdat
                                ,lr_campo.procdat
                                ,lr_campo.assdat
                                ,lr_campo.flgzerokm
                                ,lr_campo.flgimp
                                ,lr_campo.susepcod
                                ,lr_campo.lsrcepcod
                                ,lr_campo.scoclicod
                                ,lr_campo.mtvcancod
                                ,lr_campo.resercarcod
                                ,lr_campo.sgmclicod
                                ,lr_campo.vlrfranquia
                                ,lr_campo.ubbcod
                                ,lr_campo.porvclcod
                                ,lr_campo.frtmdlnom
                                ,lr_campo.plndes
                                ,lr_campo.vndcnldes
                                ,lr_campo.bldflg
                                ,lr_campo.vcltipnom
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_erro.sqlcode = sqlca.sqlcode
         let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do MOVIMENTO. Tabela: <datmdetitaasiarq>. ", lr_campo.numlinha clipped
         call errorlog(lr_erro.mens)
         rollback work

         return lr_erro.*
      end if

   end case

   let lr_erro.sqlcode = 0

   return lr_erro.*

#=================================================================
end function # Fim da Função bdata137_carrega_tabela_movimento
#=================================================================

#=================================================================
function bdata137_processa_carga()
#=================================================================

   define lr_dados record
       asiarqvrsnum     like datmdetitaasiarq.itaasiarqvrsnum
      ,asiarqlnhnum     like datmdetitaasiarq.itaasiarqlnhnum
      ,ciacod           like datmdetitaasiarq.itaciacod
      ,ramcod           like datmdetitaasiarq.itaramcod
      ,aplnum           like datmdetitaasiarq.itaaplnum
      ,aplitmnum        like datmdetitaasiarq.itaaplitmnum
      ,aplvigincdat     like datmdetitaasiarq.itaaplvigincdat
      ,aplvigfnldat     like datmdetitaasiarq.itaaplvigfnldat
      ,prpnum           like datmdetitaasiarq.itaprpnum
      ,prdcod           like datmdetitaasiarq.itaprdcod
      ,sgrplncod        like datmdetitaasiarq.itasgrplncod
      ,empasicod        like datmdetitaasiarq.itaempasicod
      ,asisrvcod        like datmdetitaasiarq.itaasisrvcod
      ,rsrcaogrtcod     like datmdetitaasiarq.rsrcaogrtcod
      ,segnom           like datmdetitaasiarq.segnom
      ,pestipcod        like datmdetitaasiarq.pestipcod
      ,segcgccpfnum     like datmdetitaasiarq.segcgccpfnum
      ,seglgdnom        like datmdetitaasiarq.seglgdnom
      ,seglgdnum        like datmdetitaasiarq.seglgdnum
      ,segendcmpdes     like datmdetitaasiarq.segendcmpdes
      ,segbrrnom        like datmdetitaasiarq.segbrrnom
      ,segcidnom        like datmdetitaasiarq.segcidnom
      ,segufdsgl        like datmdetitaasiarq.segufdsgl
      ,segcepnum        like datmdetitaasiarq.segcepnum
      ,segresteldddnum  like datmdetitaasiarq.segresteldddnum
      ,segrestelnum     like datmdetitaasiarq.segrestelnum
      ,autchsnum        like datmdetitaasiarq.autchsnum
      ,autplcnum        like datmdetitaasiarq.autplcnum
      ,autfbrnom        like datmdetitaasiarq.autfbrnom
      ,autlnhnom        like datmdetitaasiarq.autlnhnom
      ,autmodnom        like datmdetitaasiarq.autmodnom
      ,autfbrano        like datmdetitaasiarq.autfbrano
      ,autmodano        like datmdetitaasiarq.autmodano
      ,autcmbnom        like datmdetitaasiarq.autcmbnom
      ,autcornom        like datmdetitaasiarq.autcornom
      ,autpintipdes     like datmdetitaasiarq.autpintipdes
      ,vclcrgtipcod     like datmdetitaasiarq.itavclcrgtipcod
      ,mvtsttcod        like datmdetitaasiarq.mvtsttcod
      ,adniclhordat     like datmdetitaasiarq.adniclhordat
      ,pcshordat        like datmdetitaasiarq.itapcshordat
      ,asiincdat        like datmdetitaasiarq.asiincdat
      ,okmflg           like datmdetitaasiarq.okmflg
      ,impautflg        like datmdetitaasiarq.impautflg
      ,corsuscod        like datmdetitaasiarq.itacorsuscod
      ,rsclclcepnum     like datmdetitaasiarq.rsclclcepnum
      ,cliscocod        like datmdetitaasiarq.itacliscocod
      ,aplcanmtvcod     like datmdetitaasiarq.itaaplcanmtvcod
      ,rsrcaosrvcod     like datmdetitaasiarq.itarsrcaosrvcod
      ,clisgmcod        like datmdetitaasiarq.itaclisgmcod
      ,casfrqvlr        like datmdetitaasiarq.casfrqvlr
      ,ubbcod           like datmdetitaasiarq.ubbcod
      ,porvclcod        like datmdetitaasiarq.porvclcod
      ,frtmdlnom        like datmdetitaasiarq.frtmdlnom
      ,plndes           like datmdetitaasiarq.plndes
      ,vndcnldes        like datmdetitaasiarq.vndcnldes
      ,bldflg           like datmdetitaasiarq.bldflg
      ,vcltipnom        like datmdetitaasiarq.vcltipnom
      ,auxprdcod        like datmitaapl.itaprdcod    # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod     like datmitaaplitm.itasgrplncod
      ,auxempasicod     like datmitaaplitm.itaempasicod
      ,auxasisrvcod     like datmitaaplitm.itaasisrvcod
      ,auxcliscocod     like datmitaapl.itacliscocod
      ,auxrsrcaosrvcod  like datmitaaplitm.itarsrcaosrvcod
      ,auxclisgmcod     like datmitaaplitm.itaclisgmcod
      ,auxaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod
      ,auxrsrcaogrtcod  like datmitaaplitm.rsrcaogrtcod
      ,auxubbcod        like datmitaaplitm.ubbcod
      ,auxvclcrgtipcod  like datmitaaplitm.itavclcrgtipcod
      ,auxfrtmdlcod     like datmitaapl.frtmdlcod
      ,auxvndcnlcod     like datmitaapl.vndcnlcod
      ,auxvcltipcod     like datmitaaplitm.vcltipcod
   end record

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_apolice_ant record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_hist_process record
       asiarqvrsnum     like datmitaarqpcshst.itaasiarqvrsnum
      ,pcsseqnum        like datmitaarqpcshst.pcsseqnum
      ,lnhtotqtd        like datmitaarqpcshst.lnhtotqtd
      ,pcslnhqtd        like datmitaarqpcshst.pcslnhqtd
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define lr_arquivo record
       asiarqvrsnum  like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum     like datmitaasiarqico.pcsseqnum
      ,asiarqlnhnum  like datmitaasiarqico.itaasiarqlnhnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_parcial  integer
   define l_mens char(80)
   define l_qtd_inconsist smallint   # Qtd inconsistencias impeditivas na apolice
   define l_qtd_impedit   smallint   # Qtd inconsistencias impeditivas no item que esta sendo processado
   define l_qtd_nimpedit  smallint   # Qtd inconsistencias nao impeditivas

   initialize lr_dados.* to null
   initialize lr_hist_process.* to null
   initialize lr_erro.* to null
   initialize lr_apolice_ant.* to null
   let l_mens = null

   display " "
   display "-----------------------------------------------------------"
   display "             .:: CARREGANDO BASE DE DADOS ::.              "
   display "-----------------------------------------------------------"
   call errorlog("CARREGANDO BASE DE DADOS")

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if


   while true

      initialize lr_hist_process.* to null

      call bdata137_verifica_proximo_processamento()
      returning lr_erro.*, lr_hist_process.*

      if lr_erro.sqlcode = notfound then
         display lr_erro.mens
         exit while
      end if

      if lr_erro.sqlcode <> 0 then
         call errorlog(lr_erro.mens)
         return lr_erro.*
         exit while
      end if

      display " VERSAO ............: ", lr_hist_process.asiarqvrsnum clipped
      let l_mens = " VERSAO CARREGANDO..: ", lr_hist_process.asiarqvrsnum clipped
      call errorlog(l_mens)

      let l_parcial = 0
      let l_qtd_inconsist = 0
                             
      call cty22g02_cria_arquivos(lr_hist_process.asiarqvrsnum) 
      

      #TRANSACAO
      begin work
      whenever error continue
      open c_bdata137_002 using lr_hist_process.asiarqvrsnum, lr_hist_process.pcslnhqtd
      foreach c_bdata137_002 into lr_dados.asiarqvrsnum
                                 ,lr_dados.asiarqlnhnum
                                 ,lr_dados.ciacod
                                 ,lr_dados.ramcod
                                 ,lr_dados.aplnum
                                 ,lr_dados.aplitmnum
                                 ,lr_dados.aplvigincdat
                                 ,lr_dados.aplvigfnldat
                                 ,lr_dados.prpnum
                                 ,lr_dados.prdcod
                                 ,lr_dados.sgrplncod
                                 ,lr_dados.empasicod
                                 ,lr_dados.asisrvcod
                                 ,lr_dados.rsrcaogrtcod
                                 ,lr_dados.segnom
                                 ,lr_dados.pestipcod
                                 ,lr_dados.segcgccpfnum
                                 ,lr_dados.seglgdnom
                                 ,lr_dados.seglgdnum
                                 ,lr_dados.segendcmpdes
                                 ,lr_dados.segbrrnom
                                 ,lr_dados.segcidnom
                                 ,lr_dados.segufdsgl
                                 ,lr_dados.segcepnum
                                 ,lr_dados.segresteldddnum
                                 ,lr_dados.segrestelnum
                                 ,lr_dados.autchsnum
                                 ,lr_dados.autplcnum
                                 ,lr_dados.autfbrnom
                                 ,lr_dados.autlnhnom
                                 ,lr_dados.autmodnom
                                 ,lr_dados.autfbrano
                                 ,lr_dados.autmodano
                                 ,lr_dados.autcmbnom
                                 ,lr_dados.autcornom
                                 ,lr_dados.autpintipdes
                                 ,lr_dados.vclcrgtipcod
                                 ,lr_dados.mvtsttcod
                                 ,lr_dados.adniclhordat
                                 ,lr_dados.pcshordat
                                 ,lr_dados.asiincdat
                                 ,lr_dados.okmflg
                                 ,lr_dados.impautflg
                                 ,lr_dados.corsuscod
                                 ,lr_dados.rsclclcepnum
                                 ,lr_dados.cliscocod
                                 ,lr_dados.aplcanmtvcod
                                 ,lr_dados.rsrcaosrvcod
                                 ,lr_dados.clisgmcod
                                 ,lr_dados.casfrqvlr
                                 ,lr_dados.ubbcod
                                 ,lr_dados.porvclcod
                                 ,lr_dados.frtmdlnom  # NOVO LAYOUT DAQUI PRA BAIXO
                                 ,lr_dados.plndes
                                 ,lr_dados.vndcnldes
                                 ,lr_dados.bldflg
                                 ,lr_dados.vcltipnom


         initialize lr_apolice_atual.* to null

         let lr_apolice_atual.ciacod       = lr_dados.ciacod
         let lr_apolice_atual.ramcod       = lr_dados.ramcod
         let lr_apolice_atual.aplnum       = lr_dados.aplnum
         let lr_apolice_atual.aplseqnum    = null # Sera recuperado a seguir
         let lr_apolice_atual.aplitmnum    = lr_dados.aplitmnum
         let lr_apolice_atual.aplitmsttcod = lr_dados.mvtsttcod
         let lr_apolice_atual.qtdinconsist = 0 # Sera recuperado a seguir

         if lr_apolice_atual.ciacod = lr_apolice_ant.ciacod and
            lr_apolice_atual.ramcod = lr_apolice_ant.ramcod and
            lr_apolice_atual.aplnum = lr_apolice_ant.aplnum then
            # Se a apolice atual for a mesma da anterior

            if lr_apolice_atual.aplitmsttcod = lr_apolice_ant.aplitmsttcod then
               # Se a operacao atual for a mesma da anterior recuperar a sequencia gerada
               # e a quantidade de inconsistencias

               let lr_apolice_atual.aplseqnum = lr_apolice_ant.aplseqnum
               let lr_apolice_atual.qtdinconsist = lr_apolice_ant.qtdinconsist

               if lr_apolice_atual.aplitmnum = lr_apolice_ant.aplitmnum then
                  let l_mens = "Erro. Encontrado o mesmo item da apolice mais de uma vez."
                  call errorlog(l_mens)
                  let l_mens = "Apolice/Item: ", lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped,
                               " Arquivo/Linha: ", lr_dados.asiarqvrsnum clipped, "/", lr_dados.asiarqlnhnum clipped
                  call errorlog(l_mens)

                  continue foreach
               end if
            else
               # Grava a quantidade de inconsistencias apenas quando for para outro bloco de operacao
               let lr_apolice_atual.qtdinconsist = l_qtd_inconsist
            end if
         else
            # Ao mudar de apolice zerar as inconsistencias
            # Ao mudar de apolice incrementar a variavel parcial para garantir commit de apolices inteiras gravadas
            let l_qtd_inconsist = 0

            if l_parcial >= 300 then
               # A cada 300 linhas faz o commit e abre uma nova transacao
               # Mas somente ao mudar de apolice para garantir commit de apolices inteiras

               let lr_hist_process.pcslnhqtd = lr_arquivo.asiarqlnhnum

               call cty22g02_atualiza_processamento(lr_hist_process.*)
               returning lr_erro.*

               if lr_erro.sqlcode <> 0 then
                  call errorlog(lr_erro.mens)
                  # TRANSACAO
                  rollback work
                  return lr_erro.*
               end if

               #TRANSACAO
               commit work
               display " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
               let l_mens = " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
               call errorlog (l_mens)

               let l_parcial = 0
               begin work
            end if

         end if

         let l_parcial = l_parcial + 1

         let l_qtd_impedit = 0
         let l_qtd_nimpedit = 0
         call cty22g02_verifica_inconsistencias(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
         returning lr_erro.*, l_qtd_impedit, l_qtd_nimpedit, lr_dados.*

         if lr_erro.sqlcode <> 0 then
            call errorlog(lr_erro.mens)
            # TRANSACAO
            rollback work
            return lr_erro.*
         end if

         let l_qtd_inconsist = l_qtd_inconsist + l_qtd_impedit


         initialize lr_valida.* to null
         initialize lr_arquivo.* to null

         let lr_valida.erro   = 1
         let lr_valida.warn   = 0
         let lr_valida.codigo = 5 # ERRO DE BANCO DE DADOS
         let lr_valida.campo  = "SQL-CODE"

         let lr_arquivo.asiarqvrsnum = lr_hist_process.asiarqvrsnum
         let lr_arquivo.pcsseqnum    = lr_hist_process.pcsseqnum
         let lr_arquivo.asiarqlnhnum = lr_dados.asiarqlnhnum

         if l_qtd_impedit = 0 then
            #Realizar o cancelamento, gravacao da apolice e item apenas se nao houver inconsistencia

            case lr_apolice_atual.aplitmsttcod # Verifica se eh inclusao ou cancelamento

            when 'C' # Processa cancelamento

               call cty22g02_carrega_cancelamento(lr_apolice_atual.*, lr_hist_process.*, lr_dados.auxaplcanmtvcod)
               returning lr_erro.*, lr_apolice_atual.aplseqnum

               if lr_erro.sqlcode <> 0 then
                  call errorlog(lr_erro.mens)
                  let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                     " Linha: ", lr_dados.asiarqlnhnum clipped
                  call errorlog(lr_erro.mens)

                  let lr_valida.valor  = lr_erro.sqlcode clipped, " - CANCELAMENTO"
                  call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     # TRANSACAO
                     rollback work
                     return lr_erro.*
                  end if

                  let l_qtd_impedit = 1

               end if

               # Atualiza o campo alpseqnum nas inconsistencias nao impeditivas
               call cty22g02_atualiza_inconsistencia(lr_apolice_atual.*, lr_arquivo.*)
               returning lr_erro.*

               if lr_erro.sqlcode <> 0 then
                  # TRANSACAO
                  rollback work
                  return lr_erro.*
               end if


            when 'I' # Processa inclusao

               if lr_apolice_atual.aplseqnum is null then
                  # Se já existir sequencia gravada pula a gravacao da apolice e passa para a gravacao do item
                  # Se não existir ainda busca uma nova sequencia

                  call cty22g02_gera_sequencia_apolice(lr_apolice_atual.*)
                  returning lr_erro.*, lr_apolice_atual.aplseqnum

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                     let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                        " Linha: ", lr_dados.asiarqlnhnum clipped
                     call errorlog(lr_erro.mens)
                     # TRANSACAO
                     rollback work
                     return lr_erro.*
                  end if

                  # Carrega a apolice
                  call cty22g02_carrega_tabela_apolice(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                     let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                        " Linha: ", lr_dados.asiarqlnhnum clipped
                     call errorlog(lr_erro.mens)

                     let lr_valida.valor  = lr_erro.sqlcode clipped, " - APOLICE"
                     call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
                     returning lr_erro.*

                     if lr_erro.sqlcode <> 0 then
                        # TRANSACAO
                        rollback work
                        return lr_erro.*
                     end if

                     let lr_apolice_atual.aplseqnum = null
                     let l_qtd_impedit = 1

                  end if


                  # Atualiza o campo alpseqnum nas inconsistencias nao impeditivas
                  call cty22g02_atualiza_inconsistencia(lr_apolice_atual.*, lr_arquivo.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     # TRANSACAO
                     rollback work
                     return lr_erro.*
                  end if


               end if

               # Verifico novamente pois se houve algum erro na insercao da apolice, nao se pode inserir o item da apolice
               if l_qtd_impedit = 0 then

                  # Carrega o item da apolice
                  call cty22g02_carrega_tabela_item(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                        let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                           " Linha: ", lr_dados.asiarqlnhnum clipped
                        call errorlog(lr_erro.mens)

                        let lr_valida.valor = lr_erro.sqlcode clipped, " - ITEM"
                        call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
                        returning lr_erro.*

                        if lr_erro.sqlcode <> 0 then
                           # TRANSACAO
                           rollback work
                           return lr_erro.*
                        end if

                        let l_qtd_impedit = 1

                  end if

               end if

            end case

            let l_qtd_inconsist = l_qtd_inconsist + l_qtd_impedit
         end if

         # Atualiza os dados da apolice anterior
         initialize lr_apolice_ant.* to null

         let lr_apolice_ant.ciacod       = lr_apolice_atual.ciacod
         let lr_apolice_ant.ramcod       = lr_apolice_atual.ramcod
         let lr_apolice_ant.aplnum       = lr_apolice_atual.aplnum
         let lr_apolice_ant.aplseqnum    = lr_apolice_atual.aplseqnum
         let lr_apolice_ant.aplitmnum    = lr_apolice_atual.aplitmnum
         let lr_apolice_ant.aplitmsttcod = lr_apolice_atual.aplitmsttcod
         let lr_apolice_ant.qtdinconsist = lr_apolice_atual.qtdinconsist

         # Limpa dados da apolice que foi procesada
         initialize lr_dados.* to null

      end foreach
      #TRANSACAO

      let lr_hist_process.pcslnhqtd = lr_dados.asiarqlnhnum
       
      call cty22g02_finaliza_relatorio()              
      
      call cty22g02_encerra_processamento(lr_hist_process.*)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         call errorlog(lr_erro.mens)
         # TRANSACAO
         rollback work
         return lr_erro.*
      end if

      commit work
      display " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
      let l_mens = " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
      call errorlog (l_mens)
      display "-----------------------------------------------------------"


      call bdata137_envia_email_resumo(lr_hist_process.*)
      returning lr_erro.*

      call errorlog(lr_erro.mens)


   end while

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function  # Fim funcao bdata137_processa_carga
#========================================================================

#========================================================================
function bdata137_exibe_inicio()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second,
          l_mens  char(80)

   let l_data = today
   let l_hora = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO bdata137 - CARGA DE APOLICES DO ITAU               "
   display "-----------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let l_mens = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(l_mens)


#========================================================================
end function # Fim da Funcao bdata137_exibe_inicio
#========================================================================

#========================================================================
function bdata137_exibe_final()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second,
          l_mens  char(80)

   let l_data = today
   let l_hora = current

   display " "
   display " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   let l_mens = " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   call errorlog(l_mens)
   call errorlog("------------------------------------------------------")

#========================================================================
end function # Fim da Funcao bdata137_exibe_final
#========================================================================


#========================================================================
function bdata137_processa_apolice_pessoa_vip_ativo()
#========================================================================
   # Atualiza Flag ATIVO (S)
   define l_cgccpfnum like datkitavippes.cgccpfnum
   define l_cgccpford like datkitavippes.cgccpford
   define l_cgccpfdig like datkitavippes.cgccpfdig
   define l_pestipcod like datkitavippes.pestipcod
   define l_atvflg    like datkitavippes.atvflg
   define l_err       smallint
   define l_msg       char(100)
   define l_index     smallint

   display " "
   display "-----------------------------------------------------------"
   display "         .:: ATUALIZANDO APOLICES VIP [ATIVOS] ::.         "
   display "-----------------------------------------------------------"
   call errorlog("ATUALIZANDO APOLICES VIP [ATIVOS]")


   let l_err = 0
   let l_msg = ' '
   let l_index = 0

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if


   begin work

   open c_bdata137_011
   foreach c_bdata137_011 into l_cgccpfnum
                             , l_cgccpford
                             , l_cgccpfdig
                             , l_pestipcod
                             , l_atvflg

      if l_pestipcod = 'F' then
         whenever error continue
         execute p_bdata137_012 using l_cgccpfnum
                                    , l_cgccpfdig

         whenever error stop
      else
         whenever error continue
         execute p_bdata137_013 using l_cgccpfnum
                                    , l_cgccpford
                                    , l_cgccpfdig
         whenever error stop
      end if

      if sqlca.sqlcode <> 0 then
         let l_err = sqlca.sqlcode
         let l_msg = 'Erro (',sqlca.sqlcode,') no UPDATE da tabela datmitaapl (S)'
         rollback work
         call errorlog(l_msg)
         return l_err
              , l_msg
      else
         let l_index = l_index + 1
      end if

      if l_index = 50 then
         let l_index = 0
         commit work
         begin work
      end if

   end foreach
   commit work

   if sqlca.sqlcode <> 0 then
      let l_err = sqlca.sqlcode
      let l_msg = 'Erro (',sqlca.sqlcode,') ao SELECIONAR os dados de datkitavippes.'
      call errorlog(l_msg)
   end if

   return l_err
        , l_msg

#========================================================================
end function # FIM bdata137_processa_apolice_pessoa_vip_ativo
#========================================================================

#========================================================================
function bdata137_processa_apolice_pessoa_vip_NAO_ativo()
#========================================================================
   # Atualiza Flag ATIVO (N)
   define l_cgccpfnum like datkitavippes.cgccpfnum
   define l_cgccpford like datkitavippes.cgccpford
   define l_cgccpfdig like datkitavippes.cgccpfdig
   define l_pestipcod like datkitavippes.pestipcod
   define l_atvflg    like datkitavippes.atvflg
   define l_err       smallint
   define l_msg       char(100)
   define l_index     smallint

   display " "
   display "-----------------------------------------------------------"
   display "        .:: ATUALIZANDO APOLICES VIP [INATIVOS] ::.        "
   display "-----------------------------------------------------------"
   call errorlog("ATUALIZANDO APOLICES VIP [INATIVOS]")

   let l_err = 0
   let l_msg = ' '
   let l_index = 0

   if m_bdata137_prep is null or
      m_bdata137_prep = false then
      call bdata137_prepare()
   end if

   begin work

   open c_bdata137_014
   foreach c_bdata137_014 into l_cgccpfnum
                             , l_cgccpford
                             , l_cgccpfdig
                             , l_pestipcod
                             , l_atvflg

      if l_pestipcod = 'F' then
         whenever error continue
         execute p_bdata137_015 using l_cgccpfnum
                                    , l_cgccpfdig

         whenever error stop
      else
         whenever error continue
         execute p_bdata137_016 using l_cgccpfnum
                                    , l_cgccpford
                                    , l_cgccpfdig
         whenever error stop
      end if

      if sqlca.sqlcode <> 0 then
         let l_err = sqlca.sqlcode
         let l_msg = 'Erro (',sqlca.sqlcode,') no UPDATE da tabela datmitaapl (N)'
         rollback work
         call errorlog(l_msg)
         return l_err
              , l_msg
      else
         let l_index = l_index + 1
      end if

      if l_index = 50 then
         let l_index = 0
         commit work
         begin work
      end if

   end foreach
   commit work

   if sqlca.sqlcode <> 0 then
      let l_err = sqlca.sqlcode
      let l_msg = 'Erro (',sqlca.sqlcode,') ao SELECIONAR os dados de datkitavippes.'
      call errorlog(l_msg)
   end if

   return l_err
        , l_msg

#========================================================================
end function # FIM bdata137_processa_apolice_pessoa_vip_NAO_ativo
#========================================================================


#========================================================================
function bdata137_trata_erro(lr_erro)
#========================================================================
   define lr_erro record
          sqlcode smallint
         ,mens    char(80)
   end record

   define l_mensagem char(100)

   define l_resposta smallint
   let l_resposta = 0
   let l_mensagem = "O PROGRAMA FOI ENCERRADO EM VIRTUDE DE ERROS. CONSULTE O LOG."

   if lr_erro.sqlcode <> 0 then
      display lr_erro.mens

      call bdata137_envia_email_erro(lr_erro.*, l_mensagem)

      display l_mensagem
      let l_resposta = 1
      #exit program(1)
      return l_resposta
   end if
 return l_resposta
#========================================================================
end function # FIM bdata137_trata_erro
#========================================================================


#========================================================================
function bdata137_envia_email_erro(lr_erro, l_mensagem)
#========================================================================

   define lr_erro record
          sqlcode smallint
         ,mens    char(80)
   end record

   define lr_mail record
          rem     char(150),
          des     char(10000),
          ccp     char(10000),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
   define l_mensagem char(500)

   define l_cod_erro integer,
          l_msg_erro char(20)

   initialize lr_mail.* to null

   display " "
   display "-----------------------------------------------------------"
   display "            .:: ENVIANDO E-MAIL COM OS ERROS ::.           "
   display "-----------------------------------------------------------"
   call errorlog("ENVIANDO E-MAIL COM OS ERROS")



   let lr_mail.msg = "<html><body><font  size=2><b>                                           ",
                     "---------------| ERRO PROCESSAMENTO CARGA |---------------------</b><br>",
                     "<b>C&oacute;digo do Erro......:</b> ",lr_erro.sqlcode,"<br>                     ",
                     "<b>Mensagem do Erro....:</b><b><font color='red'><i> ",lr_erro.mens,"</i></font><br>",
                     "<b>Inform. Complementar:</b> ",l_mensagem,"</b><br>                      ",
                     "<b>Local do arquivo: </b> ",m_path_origem,"<br>                          ",
                     "<b>Local do log: </b> ",m_path_log,                                 "<br>",
                     "</body></html>                                                          "

     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "Erros Carga ITAU - Batch: bdata137"
     let lr_mail.idr = "bdata137"
     let lr_mail.tip = "html"

        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro
                    ,l_msg_erro

   if l_cod_erro = 0 then
      let lr_erro.mens = " E-MAIL ENVIADO COM SUCESSO."
   else
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no envio do e-mail."
      call errorlog(lr_erro.mens)
   end if

#========================================================================
end function # FIM bdata137_envia_email_erro
#========================================================================



#========================================================================
function bdata137_envia_email_resumo(lr_hist_process)
#========================================================================

   define lr_hist_process record
          asiarqvrsnum    like datmitaarqpcshst.itaasiarqvrsnum
         ,pcsseqnum       like datmitaarqpcshst.pcsseqnum
         ,lnhtotqtd       like datmitaarqpcshst.lnhtotqtd
         ,pcslnhqtd       like datmitaarqpcshst.pcslnhqtd
   end record

   define lr_resumo        record
          arqgerinchordat  like datmhdritaasiarq.arqgerinchordat
         ,arqgerfnlhordat  like datmhdritaasiarq.arqgerfnlhordat
         ,arqnom           like datmhdritaasiarq.arqnom
         ,crgarqremnum     like datmhdritaasiarq.crgarqremnum
         ,arqpcsinchordat  like datmitaarqpcshst.arqpcsinchordat
         ,arqpcsfnlhordat  like datmitaarqpcshst.arqpcsfnlhordat
         ,lnhtotqtd        like datmitaarqpcshst.lnhtotqtd
         ,qtd_movimentos   integer
         ,qtd_apolices     integer
         ,qtd_itens        integer
         ,qtd_itens_incl   integer
         ,qtd_itens_excl   integer
         ,qtd_imped        integer
         ,qtd_nimped       integer
   end record

   define lr_erro record
          sqlcode smallint
         ,mens    char(80)
   end record

   define l_msg           char(10000),
          l_assunto       char(100),
          l_remetente     char(100),
          l_para          char(10000),
          l_cc            char(10000),
          l_cod_erro      integer   ,
          l_msg_erro      char(20)  ,
          l_arquivo1      char(100) ,     
          l_arquivo2      char(100) ,     
          l_flgarq1       smallint  ,     
          l_flgarq2       smallint        

   define lr_mail record
          rem     char(50),
          des     char(10000),
          ccp     char(10000),
          cco     char(250),
          ass     char(250),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
   initialize lr_resumo.* to null
   initialize lr_erro.* to null
   initialize lr_mail.* to null


   let l_msg       = null
   let l_assunto   = null
   let l_remetente = null
   let l_arquivo1  = null      
   let l_arquivo2  = null      
   let l_flgarq1   = null      
   let l_flgarq2   = null      
   

   display " "
   display "-----------------------------------------------------------"
   display "       .:: ENVIANDO E-MAIL COM O RESUMO DA CARGA ::.       "
   display "-----------------------------------------------------------"
   call errorlog("ENVIANDO E-MAIL COM O RESUMO DA CARGA")

   whenever error continue
   open c_bdata137_017 using lr_hist_process.asiarqvrsnum
                            ,lr_hist_process.pcsseqnum
   fetch c_bdata137_017 into lr_resumo.arqgerinchordat
                            ,lr_resumo.arqgerfnlhordat
                            ,lr_resumo.arqnom
                            ,lr_resumo.crgarqremnum
                            ,lr_resumo.arqpcsinchordat
                            ,lr_resumo.arqpcsfnlhordat
                            ,lr_resumo.lnhtotqtd
   whenever error stop
   close c_bdata137_017

   whenever error continue
   open c_bdata137_003 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_003 into lr_resumo.qtd_movimentos
   whenever error stop
   close c_bdata137_003

   whenever error continue
   open c_bdata137_018 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_018 into lr_resumo.qtd_itens
   whenever error stop
   close c_bdata137_018

   whenever error continue
   open c_bdata137_022 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_022 into lr_resumo.qtd_itens_incl
   whenever error stop
   close c_bdata137_022

   whenever error continue
   open c_bdata137_023 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_023 into lr_resumo.qtd_itens_excl
   whenever error stop
   close c_bdata137_023

   whenever error continue
   open c_bdata137_019 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_019 into lr_resumo.qtd_apolices
   whenever error stop
   close c_bdata137_019

   whenever error continue
   open c_bdata137_020 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_020 into lr_resumo.qtd_imped
   whenever error stop
   close c_bdata137_020

   whenever error continue
   open c_bdata137_021 using lr_hist_process.asiarqvrsnum
   fetch c_bdata137_021 into lr_resumo.qtd_nimped
   whenever error stop
   close c_bdata137_021


   let l_remetente = "Carga_ITAU"
   let l_assunto = "Carga ITAU - Versao: ", lr_hist_process.asiarqvrsnum using "<<<<<"
   let l_para = m_emails

   if l_para = " " or l_para is null then
      let lr_erro.sqlcode = 1
      let lr_erro.mens = " Nenhum destinatario encontrado para envio de e-mail."
      return lr_erro.*
   end if

   let l_msg = "       <html><body><font><b>                                                          ",
               "---------------| RESUMO MOVIMENTO |--------------------- </b></br>                    ",
               "<b>Arquivo.............: </b>", lr_resumo.arqnom              clipped, "</br>         ",
               "<b>Vers&atilde;o Arquivo......: </b>", lr_hist_process.asiarqvrsnum  using "<<#####&", "</br>",
               "<b>N&uacute;mero Remessa......: </b>", lr_resumo.crgarqremnum        using "<<#####&", "</br>",
               "<b>Qtd Linhas Arquivo..: </b>", lr_resumo.lnhtotqtd           using "<<#####&", "</br>",
               "<b>Inicio Importa&ccedil;&atilde;o...: </b>", lr_resumo.arqgerinchordat     clipped, "</br>         ",
               "<b>Final Importa&ccedil;&atilde;o....: </b>", lr_resumo.arqgerfnlhordat     clipped, "</br>         ",
               "<b>Linhas importadas...: </b>", lr_resumo.qtd_movimentos      using "<<#####&", "</br>",
               "<b>---------------| RESUMO AP&Oacute;LICES/ITENS |----------------</b></br>                  ",
               "<b>Inicio Carga........: </b>", lr_resumo.arqpcsinchordat     clipped, "</br>         ",
               "<b>Final Carga.........: </b>", lr_resumo.arqpcsfnlhordat     clipped, "</br>         ",
               "<b>Ap&oacute;lices Carregadas.: </b>", lr_resumo.qtd_apolices        using "<<#####&", "</br>",
               "<b>Total de Itens......: </b>", lr_resumo.qtd_itens           using "<<#####&", "</br>",
               "<b>Itens Inclu&iacute;dos.....: </b>", lr_resumo.qtd_itens_incl      using "<<#####&", "</br>",
               "<b>Itens Cancelados....: </b>", lr_resumo.qtd_itens_excl      using "<<#####&", "</br>",
               "<b>---------------| RESUMO INCONSIST&Ecirc;NCIAS - ANALISAR|----</b></br>                  ",
               "<b>Impeditivas.........: </b>", lr_resumo.qtd_imped           using "<<#####&", "</br>",
               "<b>N&atilde;o Impeditivas.....: </b>", lr_resumo.qtd_nimped          using "<<#####&", "</br>",
               "<b>Qtde Impeditivas N&atilde;o Tratadas.....: </b>", m_qtd_impeditivas    using "<<#####&", "</br>",
               "</font></body></html>                                                                 "

     let lr_mail.des = l_para
     let lr_mail.rem = l_remetente
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = l_assunto
     let lr_mail.idr = "bdata137"
     let lr_mail.tip = "html"
     let lr_mail.msg = l_msg
     
     call cty22g02_recupera_arquivos()
     returning l_arquivo1,
               l_arquivo2,
               l_flgarq1 ,
               l_flgarq2
     
     if l_flgarq1 then 
        call figrc009_attach_file(l_arquivo1)
     end if  
     
     if l_flgarq2 then                       
        call figrc009_attach_file(l_arquivo2)          
     end if                                           
    
     call figrc009_mail_send1(lr_mail.*)
        returning l_cod_erro
                 ,l_msg_erro

   if l_cod_erro = 0 then
      let lr_erro.mens = " E-MAIL ENVIADO COM SUCESSO."
   else
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no envio do e-mail."
   end if

   return lr_erro.*

#========================================================================
end function # FIM bdata137_envia_email_resumo
#========================================================================


#========================================================================
function bdata137_obtem_caminhos()
#========================================================================

   define l_codigo     smallint
   define l_email      like datkdominio.cpodes
   define l_email_erro like iddkdominio.cpodes
   define l_tam_email  integer

   let m_path_origem     = " "
   let m_path_processado = " "
   let m_path_log        = " "
   let m_emails          = " "
   let m_emails_cc       = " "
   let l_tam_email       = 0

   {let m_path_origem     = "/sheeve/"
   let m_path_processado = "/asheeve/"
   let m_path_log        = "/logeve/"
   let m_emails          = "humbertobenedito.santos@portoseguro.com.br"
   #                        ",amiltonlourenco.pinto@portoseguro.com.br",
   #                        ",humbertobenedito.santos@portoseguro.com.br",
   #                        ",karla.santos@portoseguro.com.br",
   #                        ",renata.pascoal@portoseguro.com.br",
   #                        ",anapaula.goncalves@portoseguro.com.br",
   #                        ",marcilio.braz@portoseguro.com.br",
   #                        ",luisfernando.melo@portoseguro.com.br",
   #                        ",carla.macieira@portoseguro.com.br"}

   # Obtem caminho ORIGEM (onde buscar arquivos a serem processados)
   let l_codigo = 1
   whenever error continue
   open c_bdata137_024 using l_codigo
   fetch c_bdata137_024 into m_path_origem
   whenever error stop
   close c_bdata137_024

   # Obtem caminho PROCESSADOS (onde gravar os arquivos apos processados)
   let l_codigo = 2
   whenever error continue
   open c_bdata137_024 using l_codigo
   fetch c_bdata137_024 into m_path_processado
   whenever error stop
   close c_bdata137_024

   # Obtem caminho LOG (onde gravar o arquivo de log)
   {let l_codigo = 3
   whenever error continue
   open c_bdata137_024 using l_codigo
   fetch c_bdata137_024 into m_path_log
   whenever error stop
   close c_bdata137_024}

   # Obtem os enderecos de e-mail para envio do resumo da carga diaria
   let l_email = ""
   whenever error continue
   open c_bdata137_025
   foreach c_bdata137_025 into l_email
    {if m_emails = " " then
      let m_emails = l_email clipped
    else
      let l_tam_email = length(m_emails)
      if l_tam_email <= 80 then
        let m_emails = m_emails clipped, ",", l_email clipped
      else
        if m_emails_cc = " " then
          let m_emails_cc = l_email clipped
        else
          let m_emails_cc = m_emails_cc clipped, ",",l_email clipped
        end if
      end if
    end if}
      if m_emails = " " then
         let m_emails = l_email clipped
      else
         let m_emails = m_emails clipped, ",", l_email clipped
      end if
      let l_email = ""
   end foreach
   whenever error stop

   display "m_path_origem     : ", m_path_origem
   display "m_path_processado : ", m_path_processado
   display "m_path_log        : ", m_path_log
   #display "m_emails          : ", m_emails clipped

#========================================================================
end function # FIM bdata137_obtem_caminhos
#========================================================================
