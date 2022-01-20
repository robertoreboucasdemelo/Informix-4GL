#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : bdata140                                                   #
# Analista Resp : Amilton Pinto                                              #
#                 Carga das Apolices para a tabela de movimentação           #
#............................................................................#
# Desenvolvimento: Amilton Pinto                                             #
# Liberacao      : 30/11/2010                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 02/09/2015 Alberto/Luiz              CT 569531 Impeditivas Itau            #
#----------------------------------------------------------------------------#
#----------------------------------------------------------------------------#
database porto

globals
   define g_ismqconn smallint
end globals
define m_bdata140_prep     smallint

define m_path_origem     char(100)
define m_path_processado char(100)
define m_path_log        char(100)
define m_emails          char(10000)
define m_emails_cc       char(10000)
define m_qtd_impeditivas integer

define m_retorno         smallint
define l_path char(200)

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
   display "Diretorio: ",m_path_log
   let m_path_log = m_path_log clipped, "/bdata140.log"
   display 'Criando Log em: ',m_path_log
   call startlog(m_path_log)
   display 'LOG STARTADO'
   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata140_prep = false
   let m_retorno = 0

   call bdata140_prepare()
   call bdata140_obtem_caminhos()

   {call bdata140_cria_log()}

   call bdata140()
     returning m_retorno

#========================================================================
end main  # fim do Main
#========================================================================


#========================================================================
function bdata140_prepare()
#========================================================================

   define l_sql char(2000)

   let l_sql = "insert into datmresitaarqdet (vrscod,linnum,ciacod,ramcod, "
               ," aplnum,aplitmnum,viginidat, "
               ,"vigfimdat,prpnum,prdcod,plncod,empcod,srvcod,segnom, "
               ,"pestipcod,cpjcpfcod,seglgdnom,seglgdnum,seglcacplnom, "
               ,"segbrrnom,segcidnom,segestsgl,segcepcod,dddcod,telnum, "
               ,"rsclgdnom,rsclgdnum,rsclcacpldes,rscbrrnom,rsccidnom, "
               ,"rscestsgl,rsccepcod,rscsegcbttipcod,restipcod,imvtipcod, "
               ,"movsttcod,adnicldat,pcmdat,sgmtipcod,suscod,aplseqnum ) values  "
               ," ( ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, "
               ," ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?  )"
   prepare p_bdata140_001 from l_sql




   let l_sql = "SELECT vrscod,linnum,ciacod,ramcod,aplnum,aplitmnum,viginidat, "
              ,"vigfimdat,prpnum,prdcod,plncod,empcod,srvcod,segnom, "
              ,"pestipcod,cpjcpfcod,seglgdnom,seglgdnum,seglcacplnom, "
              ,"segbrrnom,segcidnom,segestsgl,segcepcod,dddcod,telnum, "
              ,"rsclgdnom,rsclgdnum,rsclcacpldes,rscbrrnom,rsccidnom, "
              ,"rscestsgl,rsccepcod,rscsegcbttipcod,restipcod,imvtipcod, "
              ,"movsttcod,adnicldat,pcmdat,sgmtipcod,suscod ",
               "FROM datmresitaarqdet ",
               "WHERE vrscod = ? ",
               "AND   linnum > ? ",
               "ORDER BY linnum  "
   prepare p_bdata140_002 from l_sql
   declare c_bdata140_002 cursor with hold for p_bdata140_002

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqdet ",
               "WHERE vrscod = ? "
   prepare p_bdata140_003 from l_sql
   declare c_bdata140_003 cursor with hold for p_bdata140_003

   let l_sql = "SELECT NVL(MAX(crgremnum),0)+1, NVL(MAX(vrscod),0)+1 ",
               "FROM datmresitaasiarq"
   prepare p_bdata140_004 from l_sql
   declare c_bdata140_004 cursor with hold for p_bdata140_004

   let l_sql = "INSERT INTO datmresitaasiarq ",
               "(vrscod, movdat, grcinihordat, prsnom, arqnom, ",
               " grcfimhordat, lintotqtd, crglinqtd, flzcrgflg, crgremnum ) ",
               "VALUES (?, ?, current, ?, ?, NULL, ?, ?, ?, ?) "
   prepare p_bdata140_005 from l_sql

   let l_sql = "SELECT vrscod, movdat, prsnom, arqnom,      ",
               "       lintotqtd, crglinqtd, flzcrgflg, crgremnum ",
               "FROM datmresitaasiarq ",
               "WHERE vrscod = ? "
   prepare p_bdata140_006 from l_sql
   declare c_bdata140_006 cursor with hold for p_bdata140_006

   let l_sql = "UPDATE datmresitaasiarq ",
               "SET movdat          = ? ",
               "   ,prsnom          = ? ",
               "   ,arqnom          = ? ",
               "   ,grcfimhordat = current ",
               "   ,lintotqtd       = ? ",
               "   ,crglinqtd       = ? ",
               "   ,flzcrgflg       = ? ",
               "   ,crgremnum    = ? ", # verificar
               "WHERE vrscod = ? "
   prepare p_bdata140_007 from l_sql

   create temp table t_arquivos(arquivo char(200)) with no log

   let l_sql = "SELECT arquivo from t_arquivos "
   prepare p_bdata140_008 from l_sql
   declare c_bdata140_008 cursor with hold for p_bdata140_008

   let l_sql = "SELECT vrscod, crglinqtd ",
               "FROM datmresitaasiarq ",
               "WHERE vrscod IN ",
               "  (SELECT NVL(MAX(vrscod),0) + 1 ",
               "   FROM datmresitaarqpcmhs ",
               "   WHERE flzpcmflg = 'S') ",
               "AND flzcrgflg = 'S' "
   prepare p_bdata140_009 from l_sql
   declare c_bdata140_009 cursor with hold for p_bdata140_009

   let l_sql = "SELECT vrscod, pcmnum, lintotnum, NVL(pdolinnum,0) ",
               "FROM datmresitaarqpcmhs ",
               "WHERE vrscod = ? ",
               "AND   flzpcmflg = 'N' ",
               "ORDER BY pcmnum "
   prepare p_bdata140_010 from l_sql
   declare c_bdata140_010 cursor with hold for p_bdata140_010

   {let l_sql = 'SELECT cgccpfnum     '
             , '     , cgccpford     '
             , '     , cgccpfdig     '
             , '     , pestipcod     '
             , '     , atvflg        '
             , '  FROM datkitavippes '
             , ' WHERE atvflg = "S"  '
   prepare p_bdata140_011 from l_sql
   declare c_bdata140_011 cursor with hold for p_bdata140_011}

   let l_sql = ' update datmresitaapl       '
             , '    set eslsegflg = "S"  '
             , '  where segcpjcpfnum = ? '
             , '    and cpjcpfdignum = ? '
             , '    and eslsegflg = "N"  '
   prepare p_bdata140_012 from l_sql

   let l_sql = ' update datmresitaapl       '
             , '    set eslsegflg = "S"  '
             , '  where segcpjcpfnum = ? '
             , '    and cpjordnum = ? '
             , '    and cpjcpfdignum = ? '
             , '    and eslsegflg = "N"  '
   prepare p_bdata140_013 from l_sql

   {let l_sql = 'SELECT cgccpfnum     '
             , '     , cgccpford     '
             , '     , cgccpfdig     '
             , '     , pestipcod     '
             , '     , atvflg        '
             , '  FROM datkitavippes '
             , ' WHERE atvflg = "N"  '
   prepare p_bdata140_014 from l_sql
   declare c_bdata140_014 cursor with hold for p_bdata140_014

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "N"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "S"  '
   prepare p_bdata140_015 from l_sql

   let l_sql = ' update datmitaapl       '
             , '    set vipsegflg = "N"  '
             , '  where segcgccpfnum = ? '
             , '    and segcgcordnum = ? '
             , '    and segcgccpfdig = ? '
             , '    and vipsegflg = "S"  '
   prepare p_bdata140_016 from l_sql}

   let l_sql = "SELECT HDR.grcinihordat, HDR.grcfimhordat, HDR.arqnom, HDR.crgremnum, ",
               "       PCS.pcminihordat, PCS.pcmfnlhordat, PCS.lintotnum ",
               "FROM datmresitaarqpcmhs PCS ",
               "INNER JOIN datmresitaasiarq HDR ",
               "   ON HDR.vrscod = PCS.vrscod ",
               "WHERE PCS.vrscod = ? ",
               "AND   PCS.pcmnum       = ? "
   prepare p_bdata140_017 from l_sql
   declare c_bdata140_017 cursor with hold for p_bdata140_017

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaapl APL ",
               "INNER JOIN datmresitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.aplnum = ITM.aplnum ",
               "WHERE APL.vrsnum = ? "
   prepare p_bdata140_018 from l_sql
   declare c_bdata140_018 cursor with hold for p_bdata140_018

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaapl ",
               "WHERE vrsnum = ? "
   prepare p_bdata140_019 from l_sql
   declare c_bdata140_019 cursor with hold for p_bdata140_019

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic ",
               "WHERE vrscod = ? ",
               "AND   ipvicoflg = 'S' "
   prepare p_bdata140_020 from l_sql
   declare c_bdata140_020 cursor with hold for p_bdata140_020

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic ",
               "WHERE vrscod = ? ",
               "AND   ipvicoflg = 'N' "
   prepare p_bdata140_021 from l_sql
   declare c_bdata140_021 cursor with hold for p_bdata140_021

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaapl APL ",
               "INNER JOIN datmresitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.aplnum = ITM.aplnum ",
               "WHERE APL.vrsnum = ? ",
               "AND   ITM.itmsttcod = 'I' "
   prepare p_bdata140_022 from l_sql
   declare c_bdata140_022 cursor with hold for p_bdata140_022

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaapl APL ",
               "INNER JOIN datmresitaaplitm ITM ",
               "   ON APL.aplseqnum = ITM.aplseqnum ",
               "  AND APL.itaciacod = ITM.itaciacod ",
               "  AND APL.itaramcod = ITM.itaramcod ",
               "  AND APL.aplnum = ITM.aplnum ",
               "WHERE APL.vrsnum = ? ",
               "AND   ITM.itmsttcod = 'C' "
   prepare p_bdata140_023 from l_sql
   declare c_bdata140_023 cursor with hold for p_bdata140_023

   let l_sql = "SELECT cpodes ",
               "FROM datkdominio ",
               "WHERE cponom = 'itau_caminhos' ",
               "AND   cpocod = ? "
   prepare p_bdata140_024 from l_sql
   declare c_bdata140_024 cursor with hold for p_bdata140_024

   let l_sql = "SELECT cpodes    ",
               "FROM datkdominio ",
               "WHERE cponom = 'itau_email_carga' ",
               "ORDER BY cpocod "
   prepare p_bdata140_025 from l_sql
   declare C_Bdata140_025 cursor with hold for p_bdata140_025

     let l_sql = " SELECT sgmcod ",
                 " FROM datkresitaclisgm ",
                 " WHERE sgmasttipflg = ? "
   prepare p_bdata140_026 from l_sql
   declare c_bdata140_026 cursor with hold for p_bdata140_026

   let l_sql = " SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic INCON ",
               "INNER JOIN datmresitaarqpcmhs HIST ",
               "   ON HIST.vrscod = INCON.vrscod ",
               "  AND HIST.pcmnum = INCON.pcmnum ",
               "INNER JOIN datmresitaarqdet DETALHE ",
               "   ON DETALHE.vrscod = INCON.vrscod ",
               "  AND DETALHE.linnum = INCON.linnum ",
               "LEFT JOIN datkitaasiarqicotip TIPO ON (TIPO.itaasiarqicotipcod = INCON.itaasiarqicotipcod) ",
               "WHERE INCON.livicoflg = 'N' "
   
   prepare p_bdata140_027 from l_sql
   declare c_bdata140_027 cursor with hold for p_bdata140_027

   let m_bdata140_prep = true

#========================================================================
end function # Fim da função bdata140_prepare
#========================================================================

#========================================================================
function bdata140()
#========================================================================
   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_resposta smallint
   let l_resposta = 0
   initialize lr_erro.* to null

   #call bdata140_prepare()

   let m_qtd_impeditivas = 0
   whenever error continue
   open c_bdata140_027
   fetch c_bdata140_027 into m_qtd_impeditivas   
   whenever error stop
   close c_bdata140_027

   call bdata140_exibe_inicio()


   # RECUPERA ARQUIVO
   call bdata140_recupera_arquivos()
   returning lr_erro.*
   call bdata140_trata_erro(lr_erro.*)
       returning l_resposta
     if l_resposta = 1 then
       return l_resposta
     end if

   # IMPORTA ARQUIVO
   call bdata140_processa_importacao()
   returning lr_erro.*
   call bdata140_trata_erro(lr_erro.*)
      returning l_resposta
     if l_resposta = 1 then
        return l_resposta
     end if

   # CARREGA BASE
   call bdata140_processa_carga()
   returning lr_erro.*
   call bdata140_trata_erro(lr_erro.*)
      returning l_resposta
     if l_resposta = 1 then
        return l_resposta
     end if

   {# PROCESSA CLIENTES VIP (ATIVOS)
   call bdata140_processa_apolice_pessoa_vip_ativo()
   returning lr_erro.*
   call bdata140_trata_erro(lr_erro.*)
      returning l_resposta
     if l_resposta = 1 then
        return l_resposta
     end if


   # PROCESSA CLIENTES VIP (INATIVOS)
   call bdata140_processa_apolice_pessoa_vip_NAO_ativo()
   returning lr_erro.*
   call bdata140_trata_erro(lr_erro.*)
      returning l_resposta
     if l_resposta = 1 then
        return l_resposta
     end if}

   call bdata140_exibe_final()

   drop table t_arquivos
  return l_resposta
#========================================================================
end function # Fim da Funcao bdata140
#========================================================================

#========================================================================
function bdata140_recupera_arquivos()
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
   call errorlog("RECUPERANDO ARQUIVOS DE CARGA")


   {let l_comando = "ls ",
                   m_path_origem clipped, "*.TXT ",
                   m_path_origem clipped, "*.V* > temp"
   run l_comando returning l_erro}


   let l_comando = "ls "
                  ,m_path_origem clipped, "R1OBCL*.TXT "
                  ,m_path_origem clipped, "R1OBCL*.V* > temp"
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
      let lr_erro.mens = 'Erro (' , lr_erro.sqlcode ,') na recuperacao dos arquivos de carga. (LINHA 401 DO CÓDIGO DO PROGRAMA) '
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*

#========================================================================
end function # Fim da Funcao bdata140_recupera_arquivos
#========================================================================
#========================================================================
function bdata140_armazena_arquivo(l_arquivo)
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
      let lr_erro.mens = 'Erro (' , lr_erro.sqlcode ,') na copia para a pasta de processados.(LINHA 443 DO CÓDIGO DO PROGRAMA)'
      call errorlog(lr_erro.mens)
      let lr_erro.mens = 'Arquivo: ', l_arquivo clipped
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*

#========================================================================
end function # Fim da Funcao bdata140_armazena_arquivo
#========================================================================

#========================================================================
function bdata140_cria_log()
#========================================================================

   define l_path char(200)

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")

   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if

   display 'Diretorio: ',m_path_log
   let m_path_log = m_path_log clipped, "/bdata140.log"

   display 'Criando Log em: ',m_path_log
   call startlog(m_path_log)

#========================================================================
end function  # fim da função bdata140_cria_log
#========================================================================

#========================================================================
function bdata140_processa_importacao()
#========================================================================

   define lr_header record
      vrscod            like datmresitaasiarq.vrscod
     ,movdat            like datmresitaasiarq.movdat
     ,prsnom            like datmresitaasiarq.prsnom
     ,arqnom            like datmresitaasiarq.arqnom
     ,lnhtotqtd         like datmresitaasiarq.lintotqtd
     ,crglnhqtd         like datmresitaasiarq.crglinqtd
     ,fnzimpflg         like datmresitaasiarq.flzcrgflg
     ,crgarqremnum      like datmresitaasiarq.crgremnum
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

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if


   whenever error continue
   open c_bdata140_008
   foreach c_bdata140_008 into l_arquivo

      initialize lr_header.* to null
      initialize lr_trailer.* to null

      call bdata140_extrai_nome_arquivo(l_arquivo)
      returning l_arquivo2

      let l_versao = 0

      call bdata140_verifica_versao_arquivo(l_arquivo2)
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
         let lr_erro.mens = "Erro ao abrir o arquivo para HEADER: ", l_arquivo2 clipped, ".(LINHA 565 DO CÓDIGO DO PROGRAMA)"
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if


      # Exibe log indicando o inicio do processamento do arquivo
      display " ARQUIVO............: ", l_arquivo2 clipped
      let l_mens = " ARQUIVO IMPORTANDO: ", l_arquivo2 clipped
      call errorlog(l_mens)

      call learq(l_file,559) returning l_linha, l_eof

      #display "##:", l_linha
      #sleep 1

      if l_eof = 0 then
         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Final do arquivo antes do header: ", l_arquivo2 clipped, ".(LINHA 582 DO CÓDIGO DO PROGRAMA)"
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if

      # Le o Header quebrando as colunas do arquivo
      call bdata140_le_header(l_linha)
      returning lr_header.*

      # Fecha o arquivo
      call fechaarq(l_file)


      # VERIFICAR amilton
      if lr_header.crgarqremnum is null or
         lr_header.crgarqremnum <= 0 then

         let lr_erro.sqlcode = -1
         let lr_erro.mens = "Header nao encontrado na primeira linha do arquivo: ", l_arquivo2 clipped,
         ".(LINHA 596 DO CÓDIGO DO PROGRAMA)"
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

         call bdata140_insere_header(lr_header.*)
         returning lr_erro.*, lr_header.*

         if lr_erro.sqlcode <> 0 then
            return lr_erro.*
         end if

         let l_num_versao = lr_header.vrscod using "&&&&&"
         let l_novo_arquivo = l_arquivo2 clipped, ".V", l_num_versao

         let l_comando = "mv ", m_path_origem clipped, l_arquivo2 clipped, " ", m_path_origem clipped, l_novo_arquivo clipped
         run l_comando returning l_erro

         if l_erro <> 0 then
            let lr_erro.sqlcode = l_erro
            let lr_erro.mens = "Erro (" , lr_erro.sqlcode clipped ,") ao renomear o arquivo de carga: ", lr_header.arqnom clipped,
            ".(LINHA 638 DO CÓDIGO DO PROGRAMA)"
            call errorlog(lr_erro.mens)
            return lr_erro.*
         end if

         {display "ARQUIVO ORIGINAL..: ",l_arquivo2
         display "ARQUIVO RENOMEADO.: ",l_novo_arquivo
         display "NOVA VERSAO.......: ",lr_header.vrscod}

         let l_arquivo = m_path_origem clipped, l_novo_arquivo clipped

      else
         # Ja existe marcacao de versao no arquivo.
         call bdata140_consulta_header(l_versao)
         returning lr_erro.*, lr_header.*

         if lr_erro.sqlcode <> 0 then
            return lr_erro.*
         end if

         # Verifica se o arquivo ja foi processado
         if upshift(lr_header.fnzimpflg) = "S" then
            let lr_erro.sqlcode = 1
            let lr_erro.mens = "Erro. Arquivo versao ", lr_header.vrscod using "<<<<<", " ja foi processado. (LINHA 657 DO CÓDIGO DO PROGRAMA)"
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
         let lr_erro.mens = "Erro ao abrir o arquivo para leitura: ", l_arquivo2 clipped, ".(LINHA 678 DO CÓDIGO DO PROGRAMA)"
         call errorlog(lr_erro.mens)
         call fechaarq(l_file)
         return lr_erro.*
      end if

      # Loop de Leitura do arquivo sequencial ate final (l_eof = 0)
      let l_parcial = 0
      let l_contador = 0

      display " VERSAO ............: ", lr_header.vrscod clipped
      let l_mens = " VERSAO IMPORTANDO: ", lr_header.vrscod clipped
      call errorlog(l_mens)
      # Verificar Amilton
      display " REMESSA............: ", lr_header.crgarqremnum clipped
      let l_mens = " REMESSA IMPORTANDO: ", lr_header.crgarqremnum clipped
      call errorlog(l_mens)


      begin work
      while true

         # Le a proxima linha do arquivo retornando uma string
         # e um indicador verifica se o final de arquivo foi atingido
         call learq(l_file,558) returning l_linha, l_eof

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

         #call bdata140_le_trailer (l_linha)
         #returning lr_trailer.*
         if lr_trailer.qtd_movimentos is not null and
            lr_trailer.qtd_movimentos <> 0 then
            exit while
         end if


         call bdata140_carrega_tabela_movimento(l_contador, l_linha, lr_header.vrscod)
         returning lr_erro.*

         if lr_erro.sqlcode = 0 then
            let l_parcial = l_parcial + 1
            if l_parcial >= 1000 then
               let l_parcial = 0

               let lr_header.crglnhqtd = l_contador
               let lr_header.fnzimpflg = "N"

               call bdata140_atualiza_header(lr_header.*)
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
         open c_bdata140_003 using lr_header.vrscod
         fetch c_bdata140_003 into l_contador
         whenever error stop
         close c_bdata140_003

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

         call bdata140_atualiza_header(lr_header.*)
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

      call bdata140_armazena_arquivo(l_arquivo)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         continue foreach
         #return lr_erro.*
      end if


   end foreach
   close c_bdata140_008

   let lr_erro.sqlcode = 0
   return lr_erro.*

#=======================================================
end function # Fim da função bdata140_processa_importacao
#=======================================================


#=======================================================
function bdata140_verifica_versao_arquivo(lr_param)
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
end function # Fim da função bdata140_verifica_versao_arquivo
#=======================================================

#=======================================================
function bdata140_extrai_nome_arquivo(lr_param)
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
end function # Fim da função bdata140_extrai_nome_arquivo
#=======================================================

#=======================================================
function bdata140_verifica_proximo_processamento()
#=======================================================

   define lr_hist_process record
       asiarqvrsnum     like datmresitaarqpcmhs.vrscod
      ,pcsseqnum        like datmresitaarqpcmhs.pcmnum
      ,lnhtotqtd        like datmresitaarqpcmhs.lintotnum
      ,pcslnhqtd        like datmresitaarqpcmhs.pdolinnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if

   initialize lr_hist_process.* to null

   # Verifica e busca se ha alguma versao de movimento que possa ser processada
   whenever error continue
   open c_bdata140_009
   fetch c_bdata140_009 into lr_hist_process.asiarqvrsnum, lr_hist_process.lnhtotqtd
   whenever error stop
   close c_bdata140_009

   if sqlca.sqlcode = notfound or
      lr_hist_process.asiarqvrsnum is null then
      let lr_erro.sqlcode = notfound
      let lr_erro.mens = " Nao existem mais processamentos pendentes..."
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_hist_process.*
   end if

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao buscar o proximo processamento...(LINHA 945 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_hist_process.*
   end if

   # Verifica se ja existe processamento iniciado para a versao
   whenever error continue
   open c_bdata140_010 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_010 into lr_hist_process.*
   whenever error stop
   close c_bdata140_010

   if sqlca.sqlcode = notfound or
      lr_hist_process.pcslnhqtd is null then

      # Cria um novo processamento caso nao exista um processamento ja iniciado
      call cty22g03_gera_processamento(lr_hist_process.*)
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
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao buscar processamento ativo...(LINHA 961 DO CÓDIGO DO PROGRAMA)"
      return lr_erro.*, lr_hist_process.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_hist_process.*

#=======================================================
end function # Fim da função bdata140_verifica_proximo_processamento
#=======================================================

#=======================================================
function bdata140_insere_header(lr_header)
#=======================================================

   define lr_header record
      vrscod   like datmresitaasiarq.vrscod
     ,movdat            like datmresitaasiarq.movdat
     ,prsnom            like datmresitaasiarq.prsnom
     ,arqnom            like datmresitaasiarq.arqnom
     ,lnhtotqtd         like datmresitaasiarq.lintotqtd
     ,crglnhqtd         like datmresitaasiarq.crglinqtd
     ,fnzimpflg         like datmresitaasiarq.flzcrgflg
     ,crgarqremnum      like datmresitaasiarq.crgremnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_remessa_esperada smallint

   initialize lr_erro.* to null

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if

   let l_remessa_esperada = 0
   let lr_header.vrscod = 0

   whenever error continue
   open c_bdata140_004
   fetch c_bdata140_004 into l_remessa_esperada, lr_header.vrscod
   whenever error stop
   close c_bdata140_004



   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na busca de nova versao do HEADER. Tabela: <datmhdritaasiarq>.(LINHA 1019 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   # Amilton Verificar
   if l_remessa_esperada <> lr_header.crgarqremnum then
      let lr_erro.sqlcode = -1
      let lr_erro.mens = "Conflito de numero de remessa. Esperada: ", l_remessa_esperada using "<<<<<",
                         " Lida: ", lr_header.crgarqremnum  using "<<<<<"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   begin work

   whenever error continue
   execute p_bdata140_005 using lr_header.vrscod
                               ,lr_header.movdat
                               ,lr_header.prsnom
                               ,lr_header.arqnom
                               ,lr_header.lnhtotqtd
                               ,lr_header.crglnhqtd
                               ,lr_header.fnzimpflg
                               ,lr_header.crgarqremnum # Amilton Verificar
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do HEADER. Tabela: <datmhdritaasiarq>.(LINHA 1045 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      rollback work

      return lr_erro.*, lr_header.*
   end if

   commit work
   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_header.*
#=======================================================
end function # Fim da função bdata140_insere_header
#=======================================================

#=======================================================
function bdata140_atualiza_header(lr_header)
#=======================================================

   define lr_header record
      vrscod            like datmresitaasiarq.vrscod
     ,movdat            like datmresitaasiarq.movdat
     ,prsnom            like datmresitaasiarq.prsnom
     ,arqnom            like datmresitaasiarq.arqnom
     ,lnhtotqtd         like datmresitaasiarq.lintotqtd
     ,crglnhqtd         like datmresitaasiarq.crglinqtd
     ,fnzimpflg         like datmresitaasiarq.flzcrgflg
     ,crgarqremnum      like datmresitaasiarq.crgremnum # Verificar Amilton
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if

   whenever error continue
   execute p_bdata140_007 using  lr_header.movdat
                                ,lr_header.prsnom
                                ,lr_header.arqnom
                                ,lr_header.lnhtotqtd
                                ,lr_header.crglnhqtd
                                ,lr_header.fnzimpflg
                                ,lr_header.crgarqremnum
                                ,lr_header.vrscod
   whenever error stop


   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na atualizacao do HEADER. Tabela: <datmhdritaasiarq>.(LINHA 1099 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*
#=======================================================
end function # Fim da função bdata140_atualiza_header
#=======================================================
#=======================================================
function bdata140_le_trailer(l_linha)
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
      let lr_trailer.qtd_movimentos      = l_linha[60,74]
      #display "1144 - lr_trailer.qtd_movimentos = ",lr_trailer.qtd_movimentos
   end case

   #display "MOVIMENTOS: ", lr_trailer.qtd_movimentos

   return lr_trailer.*
#=======================================================
end function # Fim da função bdata140_le_trailer
#=======================================================

#=======================================================
function bdata140_le_header(l_linha)
#=======================================================
   define l_linha char(800)

   define lr_header     record
          vrscod        like datmresitaasiarq.vrscod
         ,movdat        like datmresitaasiarq.movdat
         ,prsnom        like datmresitaasiarq.prsnom
         ,arqnom        like datmresitaasiarq.arqnom
         ,lnhtotqtd     like datmresitaasiarq.lintotqtd
         ,crglnhqtd     like datmresitaasiarq.crglinqtd
         ,fnzimpflg     like datmresitaasiarq.flzcrgflg
         ,crgarqremnum  like datmresitaasiarq.crgremnum
   end record

   define lr_erro record
          sqlcode smallint
         ,mens    char(80)
   end record

   define l_tpreg char(1)
         ,l_count integer

   initialize lr_erro.* to null
   initialize lr_header.* to null

   let l_tpreg = null
   let l_tpreg = l_linha[1,1]

   case l_tpreg

      when 0 #--Distribui a string nos campos do registro Header------#

      let lr_header.vrscod                = 0
      let lr_header.movdat                = l_linha[2,9]
      let lr_header.prsnom                = l_linha[10,54]
      let lr_header.crgarqremnum          = l_linha[55,59]
      let lr_header.arqnom                = " "
      let lr_header.lnhtotqtd             = 0
      let lr_header.crglnhqtd             = 0
      let lr_header.fnzimpflg             = "N"

   end case

   return lr_header.*
#=======================================================
end function # Fim da função bdata140_le_header
#=======================================================

#=======================================================
function bdata140_consulta_header(lr_param)
#=======================================================
   define lr_param record
      versao   smallint
   end record

   define lr_header     record
          vrscod        like datmresitaasiarq.vrscod
         ,movdat        like datmresitaasiarq.movdat
         ,prsnom        like datmresitaasiarq.prsnom
         ,arqnom        like datmresitaasiarq.arqnom
         ,lnhtotqtd     like datmresitaasiarq.lintotqtd
         ,crglnhqtd     like datmresitaasiarq.crglinqtd
         ,fnzimpflg     like datmresitaasiarq.flzcrgflg
         ,crgarqremnum  like datmresitaasiarq.crgremnum
   end record

   define lr_erro record
          sqlcode smallint
         ,mens    char(80)
   end record

   initialize lr_erro.* to null
   initialize lr_header.* to null

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if

   whenever error continue
   open c_bdata140_006 using lr_param.versao
   fetch c_bdata140_006 into lr_header.*
   whenever error stop
   close c_bdata140_006

   if sqlca.sqlcode = notfound or
      lr_header.vrscod is null then
      let lr_erro.sqlcode = notfound
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, "). Versao ", lr_param.versao clipped , " nao encontrada.(LINHA 1239 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na consulta de HEADER. Tabela: <datmhdritaasiarq>.(LINHA 1239 DO CÓDIGO DO PROGRAMA)"
      call errorlog(lr_erro.mens)
      return lr_erro.*, lr_header.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_header.*
#=======================================================
end function # Fim da função bdata140_consulta_header
#=======================================================

#=======================================================
function bdata140_carrega_tabela_movimento(l_contador, l_linha, l_versao)
#=======================================================

   define l_contador integer
   define l_linha    char(800)
   define l_versao   smallint

   define lr_campo record
       numver         like datmresitaarqdet.vrscod
      ,numlinha       like datmresitaarqdet.linnum
      ,cpacod         like datmresitaarqdet.ciacod
      ,ramcod         like datmresitaarqdet.ramcod
      ,aplnumdig      like datmresitaarqdet.aplnum
      ,itmnumdig      like datmresitaarqdet.aplitmnum
      ,viginc         like datmresitaarqdet.viginidat
      ,vigfnl         like datmresitaarqdet.vigfimdat
      ,prpnumdig      like datmresitaarqdet.prpnum
      ,prdcod         like datmresitaarqdet.prdcod
      ,plncod         like datmresitaarqdet.plncod
      ,empcod         like datmresitaarqdet.empcod
      ,pstservcod     like datmresitaarqdet.srvcod
      ,segnom         like datmresitaarqdet.segnom
      ,pestip         like datmresitaarqdet.pestipcod
      ,cgccpfnumdig   like datmresitaarqdet.cpjcpfcod
      ,lgdnom         like datmresitaarqdet.seglgdnom
      ,lgdnum         like datmresitaarqdet.seglgdnum
      ,lgdcmp         like datmresitaarqdet.seglcacplnom
      ,brrnom         like datmresitaarqdet.segbrrnom
      ,cidnom         like datmresitaarqdet.segcidnom  # Verificar Amilton
      ,ufdcod         like datmresitaarqdet.segestsgl
      ,lgdcep         like datmresitaarqdet.segcepcod
      ,cmlteldddcod   like datmresitaarqdet.dddcod
      ,cmltelnum      like datmresitaarqdet.telnum
      ,rsclgdnom      like datmresitaarqdet.rsclgdnom
      ,rsclgdnum      like datmresitaarqdet.rsclgdnum
      ,rsclgdcmp      like datmresitaarqdet.rsclcacpldes
      ,rscbrrnom      like datmresitaarqdet.rscbrrnom
      ,rsccidnom      like datmresitaarqdet.rsccidnom
      ,rscufdcod      like datmresitaarqdet.rscestsgl
      ,rsclgdcep      like datmresitaarqdet.rsccepcod
      ,cobseg	        like datmresitaarqdet.rscsegcbttipcod
      ,ressegcod	    like datmresitaarqdet.restipcod
      ,mrdsegcod	    like datmresitaarqdet.imvtipcod
      ,flgsttmov      like datmresitaarqdet.movsttcod
      ,adtdat         like datmresitaarqdet.adnicldat
      ,procdat        like datmresitaarqdet.pcmdat
      ,segmtipcod	    like datmresitaarqdet.sgmtipcod
      ,susepcod       like datmresitaarqdet.suscod
      ,vrsnumre	      like datmresitaarqdet.vrscod
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_sequencia smallint

   define l_tpreg char(1)
         ,l_count integer


   initialize lr_campo.* to null
   initialize lr_erro.* to null

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if


   let l_tpreg = null
   let l_tpreg = l_linha[1,1]
   let l_sequencia = 1

   if l_tpreg <> 0 and
      l_tpreg <> 9 then
   #case l_tpreg
   #
   #   when 1 #--Distribui a string nos campos do registro Detalhes------#

      {let lr_campo.numlinha        = l_contador
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
      let lr_campo.segnom          = l_linha[60,104]
      let lr_campo.pestip          = l_linha[105,105]
      let lr_campo.cgccpfnumdig    = l_linha[106,125]
      let lr_campo.lgdnom          = l_linha[126,175]
      let lr_campo.lgdnum          = l_linha[176,180]
      let lr_campo.lgdcmp          = l_linha[181,220]
      let lr_campo.brrnom          = l_linha[221,250]
      let lr_campo.cidnom          = l_linha[251,290]
      let lr_campo.ufdcod          = l_linha[291,292]
      let lr_campo.lgdcep          = l_linha[293,300]
      let lr_campo.cmlteldddcod    = l_linha[301,304]
      let lr_campo.cmltelnum       = l_linha[305,313]
      let lr_campo.rsclgdnom       = l_linha[314,363]
      let lr_campo.rsclgdnum       = l_linha[364,368]
      let lr_campo.rsclgdcmp       = l_linha[369,408]
      let lr_campo.rscbrrnom       = l_linha[409,438]
      let lr_campo.rsccidnom       = l_linha[439,463]
      let lr_campo.rscufdcod       = l_linha[464,465]
      let lr_campo.rsclgdcep       = l_linha[466,473]
      let lr_campo.cobseg	         = l_linha[474,474]
      let lr_campo.ressegcod	     = l_linha[475,475]
      let lr_campo.mrdsegcod	     = l_linha[476,476]
      let lr_campo.flgsttmov       = l_linha[477,477]
      let lr_campo.adtdat          = l_linha[478,491]
      let lr_campo.procdat         = l_linha[492,505]
      let lr_campo.segmtipcod	     = l_linha[506,507]
      let lr_campo.segmtipcod	     = l_linha[508,544]
      let lr_campo.vrsnumre	       = l_linha[545,549]
      let lr_campo.susepcod        = l_linha[550,558] }

      let lr_campo.numlinha        = l_contador
      let lr_campo.cpacod          = l_linha[1,2]
      let lr_campo.ramcod          = l_linha[3,5]
      let lr_campo.aplnumdig       = l_linha[6,14]
      let lr_campo.itmnumdig       = l_linha[15,21]
      let lr_campo.viginc          = l_linha[22,29]
      let lr_campo.vigfnl          = l_linha[30,37]
      let lr_campo.prpnumdig       = l_linha[38,46]
      let lr_campo.prdcod          = l_linha[47,50]
      let lr_campo.plncod          = l_linha[51,52]
      let lr_campo.empcod          = l_linha[53,55]
      let lr_campo.pstservcod      = l_linha[56,58]
      let lr_campo.segnom          = l_linha[59,103]
      let lr_campo.pestip          = l_linha[104,104]
      let lr_campo.cgccpfnumdig    = l_linha[105,124]
      let lr_campo.lgdnom          = l_linha[125,174]
      let lr_campo.lgdnum          = l_linha[175,179]
      let lr_campo.lgdcmp          = l_linha[180,219]
      let lr_campo.brrnom          = l_linha[220,249]
      let lr_campo.cidnom          = l_linha[250,289]
      let lr_campo.ufdcod          = l_linha[290,291]
      let lr_campo.lgdcep          = l_linha[292,299]
      let lr_campo.cmlteldddcod    = l_linha[300,303]
      let lr_campo.cmltelnum       = l_linha[304,312]
      let lr_campo.rsclgdnom       = l_linha[313,362]
      let lr_campo.rsclgdnum       = l_linha[363,367]
      let lr_campo.rsclgdcmp       = l_linha[368,407]
      let lr_campo.rscbrrnom       = l_linha[408,437]
      let lr_campo.rsccidnom       = l_linha[438,462]
      let lr_campo.rscufdcod       = l_linha[463,464]
      let lr_campo.rsclgdcep       = l_linha[465,472]
      let lr_campo.cobseg	         = l_linha[473,473]
      let lr_campo.ressegcod	     = l_linha[474,474]
      let lr_campo.mrdsegcod	     = l_linha[475,475]
      let lr_campo.flgsttmov       = l_linha[476,476]
      let lr_campo.adtdat          = l_linha[477,490]
      let lr_campo.procdat         = l_linha[491,504]
      let lr_campo.segmtipcod	     = l_linha[505,506]
      #let lr_campo.segmtipcod	     = l_linha[507,543]
      let lr_campo.vrsnumre	       = l_linha[544,548]
      let lr_campo.susepcod        = l_linha[549,557]

     { display "l_versao = ",l_versao
      display "lr_campo.numlinha     = ",lr_campo.numlinha
      display "lr_campo.cpacod       = ",lr_campo.cpacod
      display "lr_campo.ramcod       = ",lr_campo.ramcod
      display "lr_campo.aplnumdig    = ",lr_campo.aplnumdig
      display "lr_campo.itmnumdig    = ",lr_campo.itmnumdig
      display "lr_campo.viginc       = ",lr_campo.viginc
      display "lr_campo.vigfnl       = ",lr_campo.vigfnl
      display "lr_campo.prpnumdig    = ",lr_campo.prpnumdig
      display "lr_campo.prdcod       = ",lr_campo.prdcod
      display "lr_campo.plncod       = ",lr_campo.plncod
      display "lr_campo.empcod       = ",lr_campo.empcod
      display "lr_campo.pstservcod   = ",lr_campo.pstservcod
      display "lr_campo.segnom       = ",lr_campo.segnom
      display "lr_campo.pestip       = ",lr_campo.pestip
      display "lr_campo.cgccpfnumdig = ",lr_campo.cgccpfnumdig
      display "lr_campo.lgdnom       = ",lr_campo.lgdnom
      display "lr_campo.lgdnum       = ",lr_campo.lgdnum
      display "lr_campo.lgdcmp       = ",lr_campo.lgdcmp
      display "lr_campo.brrnom       = ",lr_campo.brrnom
      display "lr_campo.cidnom       = ",lr_campo.cidnom
      display "lr_campo.ufdcod       = ",lr_campo.ufdcod
      display "lr_campo.lgdcep       = ",lr_campo.lgdcep
      display "lr_campo.cmlteldddcod = ",lr_campo.cmlteldddcod
      display "lr_campo.cmltelnum    = ",lr_campo.cmltelnum
      display "lr_campo.rsclgdnom    = ",lr_campo.rsclgdnom
      display "lr_campo.rsclgdnum    = ",lr_campo.rsclgdnum
      display "lr_campo.rsclgdcmp    = ",lr_campo.rsclgdcmp
      display "lr_campo.rscbrrnom    = ",lr_campo.rscbrrnom
      display "lr_campo.rsccidnom    = ",lr_campo.rsccidnom
      display "lr_campo.rscufdcod    = ",lr_campo.rscufdcod
      display "lr_campo.rsclgdcep    = ",lr_campo.rsclgdcep
      display "lr_campo.cobseg	     = ",lr_campo.cobseg
      display "lr_campo.ressegcod	   = ",lr_campo.ressegcod
      display "lr_campo.mrdsegcod	   = ",lr_campo.mrdsegcod
      display "lr_campo.flgsttmov    = ",lr_campo.flgsttmov
      display "lr_campo.adtdat       = ",lr_campo.adtdat
      display "lr_campo.procdat      = ",lr_campo.procdat
      display "lr_campo.segmtipcod	 = ",lr_campo.segmtipcod
      display "lr_campo.segmtipcod	 = ",lr_campo.segmtipcod
      display "lr_campo.vrsnumre	   = ",lr_campo.vrsnumre
      display "lr_campo.susepcod     = ",lr_campo.susepcod}


      #--Insere a linha detalhe na tabela de movimento ---------------------------------#

      whenever error continue
      execute p_bdata140_001 using l_versao
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
                                  ,lr_campo.rsclgdnom
                                  ,lr_campo.rsclgdnum
                                  ,lr_campo.rsclgdcmp
                                  ,lr_campo.rscbrrnom
                                  ,lr_campo.rsccidnom
                                  ,lr_campo.rscufdcod
                                  ,lr_campo.rsclgdcep
                                  ,lr_campo.cobseg
                                  ,lr_campo.ressegcod
                                  ,lr_campo.mrdsegcod
                                  ,lr_campo.flgsttmov
                                  ,lr_campo.adtdat
                                  ,lr_campo.procdat
                                  ,lr_campo.segmtipcod
                                  ,lr_campo.susepcod
                                  ,l_sequencia
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_erro.sqlcode = sqlca.sqlcode
         let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do MOVIMENTO. Tabela: <datmresitaarqdet>. ", lr_campo.numlinha clipped,
         ".(LINHA 1395 DO CÓDIGO DO PROGRAMA)"
         call errorlog(lr_erro.mens)

         {display "l_versao = ",l_versao
         display "lr_campo.numlinha     = ",lr_campo.numlinha
         display "lr_campo.cpacod       = ",lr_campo.cpacod
         display "lr_campo.ramcod       = ",lr_campo.ramcod
         display "lr_campo.aplnumdig    = ",lr_campo.aplnumdig
         display "lr_campo.itmnumdig    = ",lr_campo.itmnumdig
         display "lr_campo.viginc       = ",lr_campo.viginc
         display "lr_campo.vigfnl       = ",lr_campo.vigfnl
         display "lr_campo.prpnumdig    = ",lr_campo.prpnumdig
         display "lr_campo.prdcod       = ",lr_campo.prdcod
         display "lr_campo.plncod       = ",lr_campo.plncod
         display "lr_campo.empcod       = ",lr_campo.empcod
         display "lr_campo.pstservcod   = ",lr_campo.pstservcod
         display "lr_campo.segnom       = ",lr_campo.segnom
         display "lr_campo.pestip       = ",lr_campo.pestip
         display "lr_campo.cgccpfnumdig = ",lr_campo.cgccpfnumdig
         display "lr_campo.lgdnom       = ",lr_campo.lgdnom
         display "lr_campo.lgdnum       = ",lr_campo.lgdnum
         display "lr_campo.lgdcmp       = ",lr_campo.lgdcmp
         display "lr_campo.brrnom       = ",lr_campo.brrnom
         display "lr_campo.cidnom       = ",lr_campo.cidnom
         display "lr_campo.ufdcod       = ",lr_campo.ufdcod
         display "lr_campo.lgdcep       = ",lr_campo.lgdcep
         display "lr_campo.cmlteldddcod = ",lr_campo.cmlteldddcod
         display "lr_campo.cmltelnum    = ",lr_campo.cmltelnum
         display "lr_campo.rsclgdnom    = ",lr_campo.rsclgdnom
         display "lr_campo.rsclgdnum    = ",lr_campo.rsclgdnum
         display "lr_campo.rsclgdcmp    = ",lr_campo.rsclgdcmp
         display "lr_campo.rscbrrnom    = ",lr_campo.rscbrrnom
         display "lr_campo.rsccidnom    = ",lr_campo.rsccidnom
         display "lr_campo.rscufdcod    = ",lr_campo.rscufdcod
         display "lr_campo.rsclgdcep    = ",lr_campo.rsclgdcep
         display "lr_campo.cobseg	     = ",lr_campo.cobseg
         display "lr_campo.ressegcod	   = ",lr_campo.ressegcod
         display "lr_campo.mrdsegcod	   = ",lr_campo.mrdsegcod
         display "lr_campo.flgsttmov    = ",lr_campo.flgsttmov
         display "lr_campo.adtdat       = ",lr_campo.adtdat
         display "lr_campo.procdat      = ",lr_campo.procdat
         display "lr_campo.segmtipcod	 = ",lr_campo.segmtipcod
         display "lr_campo.segmtipcod	 = ",lr_campo.segmtipcod
         display "lr_campo.vrsnumre	   = ",lr_campo.vrsnumre
         display "lr_campo.susepcod     = ",lr_campo.susepcod}


         rollback work

         return lr_erro.*
      end if

   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#=================================================================
end function # Fim da Função bdata140_carrega_tabela_movimento
#=================================================================

#=================================================================
function bdata140_processa_carga()
#=================================================================

define lr_dados record
       asiarqvrsnum  	 like datmresitaarqdet.vrscod
      ,asiarqlnhnum  	 like datmresitaarqdet.linnum
      ,ciacod        	 like datmresitaarqdet.ciacod
      ,ramcod        	 like datmresitaarqdet.ramcod
      ,aplnum        	 like datmresitaarqdet.aplnum
      ,aplitmnum     	 like datmresitaarqdet.aplitmnum
      ,aplvigincdat  	 like datmresitaarqdet.viginidat
      ,aplvigfnldat  	 like datmresitaarqdet.vigfimdat
      ,prpnum        	 like datmresitaarqdet.prpnum
      ,prdcod        	 like datmresitaarqdet.prdcod
      ,plncod        	 like datmresitaarqdet.plncod
      ,empasicod     	 like datmresitaarqdet.empcod
      ,asisrvcod     	 like datmresitaarqdet.srvcod
      ,segnom          like datmresitaarqdet.segnom
      ,pestipcod       like datmresitaarqdet.pestipcod
      ,segcgccpfnum    like datmresitaarqdet.cpjcpfcod
      ,seglgdnom       like datmresitaarqdet.seglgdnom
      ,seglgdnum       like datmresitaarqdet.seglgdnum
      ,segendcmpdes    like datmresitaarqdet.seglcacplnom
      ,segbrrnom       like datmresitaarqdet.segbrrnom
      ,segcidnom       like datmresitaarqdet.rsccidnom #segcidnom
      ,segufdsgl       like datmresitaarqdet.segestsgl
      ,segcepnum       like datmresitaarqdet.segcepcod
      ,segresteldddnum like datmresitaarqdet.dddcod
      ,segrestelnum    like datmresitaarqdet.telnum
      ,rsclcllgdnom    like datmresitaarqdet.rsclgdnom
      ,rsclcllgdnum    like datmresitaarqdet.rsclgdnum
      ,rsclclendcmpdes like datmresitaarqdet.rsclcacpldes
      ,rsclclbrrnom    like datmresitaarqdet.rscbrrnom
      ,rsclclcidnom    like datmresitaarqdet.rsccidnom
      ,rsclclufdsgl    like datmresitaarqdet.rscestsgl
      ,rsclclcepnum    like datmresitaarqdet.rsccepcod
      ,itacobsegcod    like datmresitaarqdet.rscsegcbttipcod
      ,itaressegcod    like datmresitaarqdet.restipcod
      ,itamrdsegcod    like datmresitaarqdet.imvtipcod
      ,mvtsttcod       like datmresitaarqdet.movsttcod
      ,adniclhordat    like datmresitaarqdet.adnicldat
      ,itapcshordat    like datmresitaarqdet.pcmdat
      ,itasegtipcod    like datmresitaarqdet.sgmtipcod
      ,corsus          like datmresitaarqdet.suscod
      ,vrscodre	       like datmresitaarqdet.vrscod
      ,auxprdcod       like datmresitaaplitm.prdcod       # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod    like datmresitaaplitm.plncod
      ,auxempasicod    like datmresitaaplitm.empcod
      ,auxasisrvcod    like datmresitaaplitm.srvcod
      ,auxsegtipcod    like datmresitaapl.sgmcod
   end record

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum # amilton Verifica
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_apolice_ant record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum # amilton Verifica
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_hist_process record
       asiarqvrsnum     like datmresitaarqpcmhs.vrscod
      ,pcsseqnum        like datmresitaarqpcmhs.pcmnum
      ,lnhtotqtd        like datmresitaarqpcmhs.lintotnum
      ,pcslnhqtd        like datmresitaarqpcmhs.pdolinnum
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define lr_arquivo record
       asiarqvrsnum  like datmresitaarqcrgic.vrscod
      ,pcsseqnum     like datmresitaarqcrgic.pcmnum
      ,asiarqlnhnum  like datmresitaarqcrgic.linnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_parcial  integer
   define l_contador_geral integer
   define l_mens char(80)
   define l_qtd_inconsist smallint   # Qtd inconsistencias impeditivas na apolice
   define l_qtd_impedit   smallint   # Qtd inconsistencias impeditivas no item que esta sendo processado
   define l_qtd_nimpedit  smallint   # Qtd inconsistencias nao impeditivas
   define l_linha char(9)

   initialize lr_dados.* to null
   initialize lr_hist_process.* to null
   initialize lr_erro.* to null
   initialize lr_apolice_ant.* to null
   let l_mens = null
   let l_linha = null
   let l_contador_geral = 0

   display " "
   display "-----------------------------------------------------------"
   display "             .:: CARREGANDO BASE DE DADOS ::.              "
   display "-----------------------------------------------------------"
   call errorlog("CARREGANDO BASE DE DADOS")

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if


   while true

      initialize lr_hist_process.* to null

      call bdata140_verifica_proximo_processamento()
      returning lr_erro.*, lr_hist_process.*


      if lr_erro.sqlcode = notfound then
        #display "1609"
         display lr_erro.mens
         exit while
      end if

      if lr_erro.sqlcode <> 0 then
        # display "1615"
         call errorlog(lr_erro.mens)
         return lr_erro.*
         exit while
      end if

      display " VERSAO ............: ", lr_hist_process.asiarqvrsnum clipped
      let l_mens = " VERSAO CARREGANDO..: ", lr_hist_process.asiarqvrsnum clipped
      call errorlog(l_mens)

      let l_parcial = 0
      let l_contador_geral = 0
      let l_qtd_inconsist = 0
                           
      call cty22g03_cria_arquivos(lr_hist_process.asiarqvrsnum)  
      

      #TRANSACAO
      begin work
      #let l_linha = lr_hist_process.pcslnhqtd
      whenever error continue
      open c_bdata140_002 using lr_hist_process.asiarqvrsnum, lr_hist_process.pcslnhqtd
      foreach c_bdata140_002 into lr_dados.asiarqvrsnum
                                  ,lr_dados.asiarqlnhnum
                                  ,lr_dados.ciacod
                                  ,lr_dados.ramcod
                                  ,lr_dados.aplnum
                                  ,lr_dados.aplitmnum
                                  ,lr_dados.aplvigincdat
                                  ,lr_dados.aplvigfnldat
                                  ,lr_dados.prpnum
                                  ,lr_dados.prdcod
                                  ,lr_dados.plncod
                                  ,lr_dados.empasicod
                                  ,lr_dados.asisrvcod
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
                                  ,lr_dados.rsclcllgdnom
                                  ,lr_dados.rsclcllgdnum
                                  ,lr_dados.rsclclendcmpdes
                                  ,lr_dados.rsclclbrrnom
                                  ,lr_dados.rsclclcidnom
                                  ,lr_dados.rsclclufdsgl
                                  ,lr_dados.rsclclcepnum
                                  ,lr_dados.itacobsegcod
                                  ,lr_dados.itaressegcod
                                  ,lr_dados.itamrdsegcod
                                  ,lr_dados.mvtsttcod
                                  ,lr_dados.adniclhordat
                                  ,lr_dados.itapcshordat
                                  ,lr_dados.itasegtipcod
                                  ,lr_dados.corsus

         let l_contador_geral = l_contador_geral + 1
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
                  let l_mens = "Apolice/Item:  ",lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped,
                               "Arquivo/Linha: ",lr_dados.asiarqvrsnum   clipped, "/", lr_dados.asiarqlnhnum      clipped
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
               #display "chamei atualizacao"
               call cty22g03_atualiza_processamento(lr_hist_process.*)
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
         call cty22g03_verifica_inconsistencias(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
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

        # display "1773"
         if l_qtd_impedit = 0 then
            #Realizar o cancelamento, gravacao da apolice e item apenas se nao houver inconsistencia

            #let  lr_apolice_atual.aplitmsttcod  = 'I'
            case lr_apolice_atual.aplitmsttcod # Verifica se eh inclusao ou cancelamento

            when 'C' # Processa cancelamento

               call cty22g03_carrega_cancelamento(lr_apolice_atual.*, lr_hist_process.*)
               returning lr_erro.*, lr_apolice_atual.aplseqnum

               if lr_erro.sqlcode <> 0 then
                  call errorlog(lr_erro.mens)
                  let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                     " Linha: ", lr_dados.asiarqlnhnum clipped, ".(LINHA 1810 DO CÓDIGO DO PROGRAMA)"
                  call errorlog(lr_erro.mens)

                  let lr_valida.valor  = lr_erro.sqlcode clipped, " - CANCELAMENTO"
                  call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     # TRANSACAO
                     rollback work
                     return lr_erro.*
                  end if

                  let l_qtd_impedit = 1

               end if

                #Atualiza o campo alpseqnum nas inconsistencias nao impeditivas
               call cty22g03_atualiza_inconsistencia(lr_apolice_atual.*, lr_arquivo.*)
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

                  call cty22g03_gera_sequencia_apolice(lr_apolice_atual.*)
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

                 # display "1835"

                  #display "1988 - lr_dados.itasegtipcod = ",lr_dados.itasegtipcod
                  whenever error continue
                  open c_bdata140_026 using lr_dados.itasegtipcod
                  fetch c_bdata140_026 into lr_dados.itasegtipcod
                  whenever error stop
                  #display "1893 - lr_dados.itasegtipcod = ",lr_dados.itasegtipcod

                  # Carrega a apolice
                  call cty22g03_carrega_tabela_apolice(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                     let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                        " Linha: ", lr_dados.asiarqlnhnum clipped
                     call errorlog(lr_erro.mens)

                     let lr_valida.valor  = lr_erro.sqlcode clipped, " - APOLICE"
                     call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
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
                  call cty22g03_atualiza_inconsistencia(lr_apolice_atual.*, lr_arquivo.*)
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
                  call cty22g03_carrega_tabela_item(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
                  returning lr_erro.*

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                        let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                           " Linha: ", lr_dados.asiarqlnhnum clipped
                        call errorlog(lr_erro.mens)

                        let lr_valida.valor = lr_erro.sqlcode clipped, " - ITEM"
                        call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
                        returning lr_erro.*

                        if lr_erro.sqlcode <> 0 then
                           # TRANSACAO
                           rollback work
                           return lr_erro.*
                        end if

                        let l_qtd_impedit = 1

                  end if

               end if
           when 'A'
              # Verifico novamente pois se houve algum erro na insercao da apolice, nao se pode inserir o item da apolice
               if l_qtd_impedit = 0 then

                  # Carrega o item da apolice
                  call cty22g03_carrega_Atualizacao(lr_apolice_atual.*, lr_dados.*, lr_hist_process.*)
                  returning lr_erro.*, lr_apolice_atual.aplseqnum

                  if lr_erro.sqlcode <> 0 then
                     call errorlog(lr_erro.mens)
                        let lr_erro.mens = "Erro Carga. Versao: ", lr_hist_process.asiarqvrsnum clipped,
                                           " Linha: ", lr_dados.asiarqlnhnum clipped
                        call errorlog(lr_erro.mens)

                        let lr_valida.valor = lr_erro.sqlcode clipped, " - APOLICE - ATUALIZACAO"
                        call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
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
      
 
      call cty22g03_finaliza_relatorio()       
      
      call cty22g03_encerra_processamento(lr_hist_process.*)
      returning lr_erro.*

      if lr_erro.sqlcode <> 0 then
         call errorlog(lr_erro.mens)
         # TRANSACAO
         rollback work
         return lr_erro.*
      end if

      commit work
      #display " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
      #let l_mens = " LINHAS CARREGADAS..: ", lr_arquivo.asiarqlnhnum clipped
      display " 2087 - LINHAS CARREGADAS..: ", l_contador_geral clipped
      let l_mens = " LINHAS CARREGADAS..: ", l_contador_geral clipped
      call errorlog (l_mens)
      display "-----------------------------------------------------------"


      call bdata140_envia_email_resumo(lr_hist_process.*)
      returning lr_erro.*

      call errorlog(lr_erro.mens)


   end while

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function  # Fim funcao bdata140_processa_carga
#========================================================================

#========================================================================
function bdata140_exibe_inicio()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second,
          l_mens  char(80)

   let l_data = today
   let l_hora = current

   display " "
   display "-----------------------------------------------------------"
   display " INICIO bdata140 - CARGA DE APOLICES DO ITAU               "
   display "-----------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let l_mens = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(l_mens)


#========================================================================
end function # Fim da Funcao bdata140_exibe_inicio
#========================================================================

#========================================================================
function bdata140_exibe_final()
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
end function # Fim da Funcao bdata140_exibe_final
#========================================================================

{
#========================================================================
function bdata140_processa_apolice_pessoa_vip_ativo()
#========================================================================
   # Atualiza Flag ATIVO (S)
   define l_cgccpfnum like datkitavippes.cgccpfnum
   define l_cgccpford like datkitavippes.cgccpford
   define l_cgccpfdig like datkitavippes.cgccpfdig
   define l_pestipcod like datkitavippes.pestipcod
   define l_atvflg    like datkitavippes.atvflg
   define l_err       smallint
   define l_msg       char(100)
   define l_index    smallint

   display " "
   display "-----------------------------------------------------------"
   display "         .:: ATUALIZANDO APOLICES VIP [ATIVOS] ::.         "
   display "-----------------------------------------------------------"
   call errorlog("ATUALIZANDO APOLICES VIP [ATIVOS]")


   let l_err = 0
   let l_msg = ' '
   let l_index = 0

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if


   begin work

   open c_bdata140_011
   foreach c_bdata140_011 into l_cgccpfnum
                             , l_cgccpford
                             , l_cgccpfdig
                             , l_pestipcod
                             , l_atvflg

      if l_pestipcod = 'F' then
         whenever error continue
         execute p_bdata140_012 using l_cgccpfnum
                                    , l_cgccpfdig

         whenever error stop
      else
         whenever error continue
         execute p_bdata140_013 using l_cgccpfnum
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
end function # FIM bdata140_processa_apolice_pessoa_vip_ativo
#========================================================================
}
{
#========================================================================
function bdata140_processa_apolice_pessoa_vip_NAO_ativo()
#========================================================================
   # Atualiza Flag ATIVO (N)
   define l_cgccpfnum like datkitavippes.cgccpfnum
   define l_cgccpford like datkitavippes.cgccpford
   define l_cgccpfdig like datkitavippes.cgccpfdig
   define l_pestipcod like datkitavippes.pestipcod
   define l_atvflg    like datkitavippes.atvflg
   define l_err       smallint
   define l_msg       char(100)
   define l_index    smallint

   display " "
   display "-----------------------------------------------------------"
   display "        .:: ATUALIZANDO APOLICES VIP [INATIVOS] ::.        "
   display "-----------------------------------------------------------"
   call errorlog("ATUALIZANDO APOLICES VIP [INATIVOS]")

   let l_err = 0
   let l_msg = ' '
   let l_index = 0

   if m_bdata140_prep is null or
      m_bdata140_prep = false then
      call bdata140_prepare()
   end if

   begin work

   open c_bdata140_014
   foreach c_bdata140_014 into l_cgccpfnum
                             , l_cgccpford
                             , l_cgccpfdig
                             , l_pestipcod
                             , l_atvflg

      if l_pestipcod = 'F' then
         whenever error continue
         execute p_bdata140_015 using l_cgccpfnum
                                    , l_cgccpfdig

         whenever error stop
      else
         whenever error continue
         execute p_bdata140_016 using l_cgccpfnum
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
end function # FIM bdata140_processa_apolice_pessoa_vip_NAO_ativo
#========================================================================
}

#========================================================================
function bdata140_trata_erro(lr_erro)
#========================================================================
   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_mensagem char(100)

   define l_resposta smallint
   let l_resposta = 0
   let l_mensagem = "O PROGRAMA FOI ENCERRADO EM VIRTUDE DE ERROS. CONSULTE O LOG."

   if lr_erro.sqlcode <> 0 then
      display lr_erro.mens

      call bdata140_envia_email_erro(lr_erro.*, l_mensagem)

      display l_mensagem
      let l_resposta = 1
      #exit program(1)
      return l_resposta
   end if
 return l_resposta
#========================================================================
end function # FIM bdata140_trata_erro
#========================================================================


#========================================================================
function bdata140_envia_email_erro(lr_erro, l_mensagem)
#========================================================================

   define lr_erro record
       sqlcode  smallint
      ,mens     char(150)
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

   define l_cod_erro      integer,
          l_msg_erro      char(20)

   initialize lr_mail.* to null

   display " "
   display "-----------------------------------------------------------"
   display "            .:: ENVIANDO E-MAIL COM OS ERROS ::.           "
   display "-----------------------------------------------------------"
   call errorlog("ENVIANDO E-MAIL COM OS ERROS")


   let lr_mail.msg = "       <html><body><font size=2><b>                        ",
               "---------------| ERRO PROCESSAMENTO CARGA |---------------------</b><br>",
               "<b>C&oacute;digo do Erro......:</b> ",lr_erro.sqlcode,                    "<br> ",
               "<b>Mensagem do Erro....:</b><b><font color='red'><i> ",lr_erro.mens,"</i></font><br>",
               "<b>Inform. Complementar: </b> ",l_mensagem,                     "</b><br>",
               "<b>Local do arquivo: </b> ",m_path_origem,                          "<br>",
               "<b>Local do log: </b> ",m_path_log,                                 "<br>",
               "</body></html>                                                          "

     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = "Erros Carga ITAU Residencia - Batch bdata140."
     let lr_mail.idr = "bdata140"
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
end function # FIM bdata140_envia_email_erro
#========================================================================



#========================================================================
function bdata140_envia_email_resumo(lr_hist_process)
#========================================================================

   define lr_hist_process record
       asiarqvrsnum     like datmresitaarqpcmhs.vrscod
      ,pcsseqnum        like datmresitaarqpcmhs.pcmnum
      ,lnhtotqtd        like datmresitaarqpcmhs.lintotnum
      ,pcslnhqtd        like datmresitaarqpcmhs.pdolinnum
   end record

   define lr_resumo record
       arqgerinchordat   like datmresitaasiarq.grcinihordat
      ,arqgerfnlhordat   like datmresitaasiarq.grcfimhordat
      ,arqnom            like datmresitaasiarq.arqnom
      ,crgarqremnum      like datmresitaasiarq.crgremnum
      ,arqpcsinchordat   like datmresitaarqpcmhs.pcminihordat
      ,arqpcsfnlhordat   like datmresitaarqpcmhs.pcmfnlhordat
      ,lnhtotqtd         like datmresitaarqpcmhs.lintotnum
      ,qtd_movimentos    integer
      ,qtd_apolices      integer
      ,qtd_itens         integer
      ,qtd_itens_incl    integer
      ,qtd_itens_excl    integer
      ,qtd_imped         integer
      ,qtd_nimped        integer
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_comando       char(15000),
          l_msg           char(10000),
          l_assunto       char(100),
          l_remetente     char(50),
          l_para          char(10000),
          l_cc            char(10000),
          l_cod_erro      integer,
          l_msg_erro      char(20),
          l_arquivo1      char(100) , 
          l_arquivo2      char(100) ,
          l_flgarq1       smallint  ,
          l_flgarq2       smallint

   define lr_mail record
          rem     char(50),
          des     char(10000),
          ccp     char(10000),
          cco     char(10000),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
   initialize lr_resumo.* to null
   initialize lr_erro.* to null
   initialize lr_mail.* to null

   let l_comando   = null
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
   open c_bdata140_017 using lr_hist_process.asiarqvrsnum
                            ,lr_hist_process.pcsseqnum
   fetch c_bdata140_017 into lr_resumo.arqgerinchordat
                            ,lr_resumo.arqgerfnlhordat
                            ,lr_resumo.arqnom
                            ,lr_resumo.crgarqremnum
                            ,lr_resumo.arqpcsinchordat
                            ,lr_resumo.arqpcsfnlhordat
                            ,lr_resumo.lnhtotqtd
   whenever error stop
   close c_bdata140_017

   whenever error continue
   open c_bdata140_003 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_003 into lr_resumo.qtd_movimentos
   whenever error stop
   close c_bdata140_003

   whenever error continue
   open c_bdata140_018 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_018 into lr_resumo.qtd_itens
   whenever error stop
   close c_bdata140_018

   whenever error continue
   open c_bdata140_022 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_022 into lr_resumo.qtd_itens_incl
   whenever error stop
   close c_bdata140_022

   whenever error continue
   open c_bdata140_023 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_023 into lr_resumo.qtd_itens_excl
   whenever error stop
   close c_bdata140_023

   whenever error continue
   open c_bdata140_019 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_019 into lr_resumo.qtd_apolices
   whenever error stop
   close c_bdata140_019

   whenever error continue
   open c_bdata140_020 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_020 into lr_resumo.qtd_imped
   whenever error stop
   close c_bdata140_020

   whenever error continue
   open c_bdata140_021 using lr_hist_process.asiarqvrsnum
   fetch c_bdata140_021 into lr_resumo.qtd_nimped
   whenever error stop
   close c_bdata140_021


   let l_remetente = "Carga_ITAU"
   let l_assunto = "Carga ITAU RESIDENCIAL - Versao: ", lr_hist_process.asiarqvrsnum using "<<<<<"
   let l_para = m_emails

   if l_para = " " or l_para is null then
      let lr_erro.sqlcode = 1
      let lr_erro.mens = " Nenhum destinatario encontrado para envio de e-mail."
      return lr_erro.*
   end if

   let l_msg = "       <html><body><font><b>                                                          ",
               "---------------| RESUMO MOVIMENTO |---------------------</font></b></br>              ",
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
               "<b>Itens Inclu&iacutedos.....: </b>", lr_resumo.qtd_itens_incl      using "<<#####&", "</br>",
               "<b>Itens Cancelados....: </b>", lr_resumo.qtd_itens_excl      using "<<#####&", "</br>",
               "<b>---------------| RESUMO INCONSIST&Ecirc;NCIAS - ANALISAR|-----</b></br>                  ",
               "<b>Impeditivas.........: </b>", lr_resumo.qtd_imped           using "<<#####&", "</br>",
               "<b>N&atilde;o Impeditivas.....: </b>", lr_resumo.qtd_nimped          using "<<#####&", "</br>",
               "<b>Qtde Impeditivas N&atilde;o Tratadas.....: </b>", m_qtd_impeditivas    using "<<#####&", "</br>",
               "</font></body></html>                                                                        "

     let lr_mail.des = l_para
     let lr_mail.rem = l_remetente
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = l_assunto
     let lr_mail.idr = "bdata140"
     let lr_mail.tip = "html"
     let lr_mail.msg = l_msg
     
     call cty22g03_recupera_arquivos()
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
end function # FIM bdata140_envia_email_resumo
#========================================================================


#========================================================================
function bdata140_obtem_caminhos()
#========================================================================

   define l_codigo     smallint
   define l_email      like datkdominio.cpodes
   define l_tam_email  integer



   let m_path_origem     = " "
   let m_path_processado = " "
   {let m_path_log        = " "}
   let m_emails          = " "
   let m_emails_cc       = " "
   let l_tam_email       = 0

   {let m_path_origem     = "/sheeve/"
   let m_path_processado = "/adat/itau/processados/"
   let m_path_log        = "/logeve/"
   {let m_emails          = "amiltonlourenco.pinto@portoseguro.com.br",
                           ",humbertobenedito.santos@portoseguro.com.br"
                          ",karla.santos@portoseguro.com.br"
                          ",roberto.melo@portoseguro.com.br",
                          ",karla.santos@portoseguro.com.br",
                          ",renata.pascoal@portoseguro.com.br",
                          ",anapaula.goncalves@portoseguro.com.br",
                          ",marcilio.braz@portoseguro.com.br",
                          ",luisfernando.melo@portoseguro.com.br",
                          ",carla.macieira@portoseguro.com.br"}

   # Obtem caminho ORIGEM (onde buscar arquivos a serem processados)
   let l_codigo = 1
   whenever error continue
   open c_bdata140_024 using l_codigo
   fetch c_bdata140_024 into m_path_origem
   whenever error stop
   close c_bdata140_024
   #let m_path_origem = "/internet/"


   # Obtem caminho PROCESSADOS (onde gravar os arquivos apos processados)
   let l_codigo = 2
   whenever error continue
   open c_bdata140_024 using l_codigo
   fetch c_bdata140_024 into m_path_processado
   whenever error stop
   close c_bdata140_024
   #let m_path_processado = "/internet/"


   # Obtem caminho LOG (onde gravar o arquivo de log)
   {let l_codigo = 3
   whenever error continue
   open c_bdata140_024 using l_codigo
   fetch c_bdata140_024 into m_path_log
   whenever error stop
   close c_bdata140_024}

   #let m_path_log = '/logeve/'

   # Obtem os enderecos de e-mail para envio do resumo da carga diaria
   let l_email = ""
   whenever error continue
   open c_bdata140_025
   foreach c_bdata140_025 into l_email
    {if m_emails = " " then
      let m_emails = l_email clipped
    else
      let l_tam_email = length(m_emails)
      if l_tam_email <= 1000 then
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


display 'caminhos processado: ',m_path_processado
display 'caminhos origem: ',m_path_origem
#========================================================================
end function # FIM bdata140_obtem_caminhos
#========================================================================





