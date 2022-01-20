
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cty22g03                                                  #
# Objetivo.......: Funcoes Itau                                              #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Marcos Goes                                               #
# Liberacao      : 07/06/2011                                                #
#............................................................................#
# 02/12/2015      Roberto Melo  Frota                                        #
#----------------------------------------------------------------------------# 
database porto

#globals "/fontes/controle_ct24h/ct24h_geral/glct.4gl"
#globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint
define g_issk     record
       funmat     decimal(6,0)         # Matricula Funcionario
      ,usrtip     char(1)
      ,empcod     decimal(2,0)
 end record
 
define mr_retorno record
	diretorio char(100) , 
  arquivo1  char(100) ,
  arquivo2  char(100) ,
  flg_arq1  smallint  ,
  flg_arq2  smallint  ,
  processo  smallint
end record	   

#------------------------------------------------------------------------------
function cty22g03_prepare()
#------------------------------------------------------------------------------

define l_sql char(32000)

   #let l_sql = "SELECT COUNT(*) ",
   #            "FROM datkitaaplcanmtv ",
   #            "WHERE itaaplcanmtvcod = ? "
   #prepare p_cty22g03_051 from l_sql
   #declare c_cty22g03_051 cursor with hold for p_cty22g03_051


   let l_sql = "UPDATE datmresitaarqcrgic ",
               "SET livicoflg = 'S' ",
               "   ,libdat = today ",
               "   ,libusrtipcod = ? ",
               "   ,libempcod = ? ",
               "   ,libmatnum = ? ",
               "WHERE aplnum = ? ",
               "AND   livicoflg = 'N' ",
               "AND   ipvicoflg = 'S' "
   prepare p_cty22g03_052 from l_sql

   let l_sql = "UPDATE datmresitaarqcrgic ",
               "SET livicoflg = 'S' ",
               "   ,libdat = today ",
               "   ,libusrtipcod = ? ",
               "   ,libempcod    = ? ",
               "   ,libmatnum    = ? ",
               "WHERE vrscod = ? ",
               "AND   pcmnum       = ? ",
               "AND   linnum = ? ",
               "AND   livicoflg = 'N' ",
               "AND   ipvicoflg = 'N' "
   prepare p_cty22g03_052b from l_sql

   let l_sql = "SELECT count(*) ",
               "FROM datmresitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? ",
               "AND   aplitmnum = ? "
   prepare p_cty22g03_053 from l_sql
   declare c_cty22g03_053 cursor with hold for p_cty22g03_053

   let l_sql = "select count(*) from datkitacia ",
              " where itaciacod = ? "
   prepare p_cty22g03_054 from l_sql
   declare c_cty22g03_054 cursor with hold for p_cty22g03_054

   let l_sql = "SELECT sgmcod ",
               "FROM datkresitaclisgm ",
               "WHERE sgmasttipflg = ? "
   prepare p_cty22g03_055 from l_sql
   declare c_cty22g03_055 cursor with hold for p_cty22g03_055

   let l_sql = "select count(*) from datkresitaprd ",
              " where prdcod = ? "
   prepare p_cty22g03_056 from l_sql
   declare c_cty22g03_056 cursor with hold for p_cty22g03_056

   let l_sql = "select count(*) from datkresitapln",
              " where plncod = ? ",
              " and   prdcod = ? "
   prepare p_cty22g03_057 from l_sql
   declare c_cty22g03_057 cursor with hold for p_cty22g03_057

   let l_sql = "select count(*) from datkitaempasi ",
              " where itaempasicod = ? "
   prepare p_cty22g03_058 from l_sql
   declare c_cty22g03_058 cursor with hold for p_cty22g03_058


   let l_sql = "SELECT COUNT(*) ",
               "FROM datmresitaarqcrgic ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   livicoflg = 'N' ",  #nao liberadas
               "AND   ipvicoflg = 'S' ",  #impeditivas
               "AND   vrscod <> ? "
   prepare p_cty22g03_061 from l_sql
   declare c_cty22g03_061 cursor with hold for p_cty22g03_061

   let l_sql = "select NVL(MAX(pcmnum),0)+1 ",
               " from datmresitaarqpcmhs ",
               " where vrscod = ? "
   prepare p_cty22g03_062 from l_sql
   declare c_cty22g03_062 cursor with hold for p_cty22g03_062

   let l_sql = "insert into datmresitaarqpcmhs ",
               "(vrscod, pcmnum, pcminihordat, ",
               " pcmfnlhordat, lintotnum, pdolinnum, flzpcmflg) ",
               "values (?, ?, current, NULL, ?, 0, 'N')"
   prepare p_cty22g03_063 from l_sql


   let l_sql = "SELECT NVL(MAX(iconum),0)+1 ",
               "FROM datmresitaarqcrgic ",
               "WHERE vrscod = ? ",
               "AND pcmnum = ? ",
               "AND linnum = ? "
   prepare p_cty22g03_064 from l_sql
   declare c_cty22g03_064 cursor with hold for p_cty22g03_064

   let l_sql = "INSERT INTO datmresitaarqcrgic ",
               "(vrscod,pcmnum,linnum,iconum, ",
               "itaasiarqicotipcod,icocponom,icocpocuddes,itaciacod, ",
               "itaramcod,aplnum,itmnum,livicoflg,aplseqnum, ",
               "ipvicoflg) ",
               "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_cty22g03_065 from l_sql

   let l_sql = "SELECT COUNT(*) FROM datmresitaarqdet ",
               "WHERE vrscod = ? "
   prepare p_cty22g03_066 from l_sql
   declare c_cty22g03_066 cursor with hold for p_cty22g03_066

   let l_sql = "SELECT NVL(MAX(aplseqnum),0) + 1 ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? "
   prepare p_cty22g03_067 from l_sql
   declare c_cty22g03_067 cursor with hold for p_cty22g03_067

   let l_sql = "insert into datmresitaapl ",
               "(itaciacod,itaramcod,aplnum,aplseqnum ",
               ",prpnum,incvigdat,fnlvigdat ",
               ",segnom,pestipcod,segcpjcpfnum,cpjordnum ",
               ",cpjcpfdignum,seglgdnom,seglgdnum,seglcacpldes ",
               ",brrnom,segcidnom,estsgl,cepcod ",
               ",cepcplcod,dddcod,telnum ",
               ",adnicldat,sgmcod,vrsnum ",
               ",pcmnum,succod,suscod,eslsegflg,segemanom,empcod) values ",
               "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
   prepare p_cty22g03_068 from l_sql


   let l_sql = "insert into datmresitaaplitm ",
               "(itaciacod,itaramcod,aplnum,aplseqnum ",
               ",aplitmnum,itmsttcod,prdcod ",
               ",plncod,empcod,srvcod ",
               ",rscsegcbttipcod,rscsegrestipcod,rscsegimvtipcod ",
               ",rsclgdnom,rsclgdnum,rsccpldes ",
               ",rscbrrnom,rsccidnom,rscestsgl ",
               ",rsccepcod,rsccepcplcod ) ",
               "values ",
               "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "

   prepare p_cty22g03_069 from l_sql

   let l_sql = "SELECT eslsegflg, segemanom ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? - 1"
   prepare p_cty22g03_072 from l_sql
   declare c_cty22g03_072 cursor with hold for p_cty22g03_072

   let l_sql = "UPDATE datmresitaarqcrgic ",
               "SET   aplseqnum = ? ",
               "WHERE vrscod = ? ",
               "AND   pcmnum       = ? ",
               "AND   linnum = ? ",
               "AND   ipvicoflg       = 'N'  "
   prepare p_cty22g03_073 from l_sql


   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? "
   prepare p_cty22g03_075 from l_sql
   declare c_cty22g03_075 cursor with hold for p_cty22g03_075


   let l_sql = "insert into datmresitaapl ",
               "(itaciacod,itaramcod,aplnum,aplseqnum ",
               ",prpnum,incvigdat,fnlvigdat ",
               ",segnom,pestipcod,segcpjcpfnum,cpjordnum ",
               ",cpjcpfdignum,seglgdnom,seglgdnum,seglcacpldes ",
               ",brrnom,segcidnom,estsgl,cepcod ",
               ",cepcplcod,dddcod,telnum ",
               ",adnicldat,sgmcod,vrsnum ",
               ",pcmnum,succod,suscod,eslsegflg,segemanom,empcod) ",
               " Select itaciacod,itaramcod,aplnum,(aplseqnum + 1) ",
               ",prpnum,incvigdat,fnlvigdat ",
               ",segnom,pestipcod,segcpjcpfnum,cpjordnum ",
               ",cpjcpfdignum,seglgdnom,seglgdnum,seglcacpldes ",
               ",brrnom,segcidnom,estsgl,cepcod ",
               ",cepcplcod,dddcod,telnum ",
               ",adnicldat,sgmcod,vrsnum ",
               ",pcmnum,succod,suscod,eslsegflg,segemanom,empcod ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum    = ? ",
               "AND   aplseqnum = ? "
   prepare p_cty22g03_076 from l_sql

   let l_sql = "UPDATE datmresitaapl ",
               "SET vrsnum = ?, ",
               "    pcmnum       = ?  ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? + 1 "
   prepare p_cty22g03_077 from l_sql

   let l_sql = " insert into datmresitaaplitm "
              ,"(itaciacod,itaramcod,aplnum,aplseqnum "
              ,",aplitmnum,itmsttcod,prdcod "
              ,",plncod,empcod,srvcod "
              ,",rscsegcbttipcod,rscsegrestipcod,rscsegimvtipcod "
              ,",rsclgdnom,rsclgdnum,rsccpldes "
              ,",rscbrrnom,rsccidnom,rscestsgl "
              ,",rsccepcod,rsccepcplcod ) "
              ," select itaciacod,itaramcod,aplnum,(aplseqnum + 1) "
              ,",aplitmnum,itmsttcod,prdcod "
              ,",plncod,empcod,srvcod "
              ,",rscsegcbttipcod,rscsegrestipcod,rscsegimvtipcod "
              ,",rsclgdnom,rsclgdnum,rsccpldes "
              ,",rscbrrnom,rsccidnom,rscestsgl "
              ,",rsccepcod,rsccepcplcod "
              ," FROM datmresitaaplitm "
              ," WHERE itaciacod = ? "
              ," AND   itaramcod = ? "
              ," AND   aplnum = ? "
              ," AND   aplseqnum = ? "
   prepare p_cty22g03_078 from l_sql

   let l_sql = "UPDATE datmresitaaplitm ",
               "SET itmsttcod = 'C' ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   aplnum = ? ",
               "AND   aplseqnum = ? + 1 " ,
               "AND   aplitmnum = ? "
   prepare p_cty22g03_079b from l_sql

   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmresitaapl ",
               "WHERE itaciacod = ? ",
               "AND itaramcod = ? ",
               "AND aplnum = ? "
   prepare p_cty22g03_080 from l_sql
   declare c_cty22g03_080 cursor with hold for p_cty22g03_080

   let l_sql = "UPDATE datmresitaarqpcmhs ",
               "SET pcmfnlhordat = current ",
               "   ,lintotnum = ? ",
               "   ,pdolinnum = ? ",
               "   ,pcmfnlhordat = current ",
               "   ,flzpcmflg = 'S' ",
               "WHERE vrscod = ? ",
               "AND   pcmnum = ? "
   prepare p_cty22g03_081 from l_sql

   let l_sql = "UPDATE datmresitaarqpcmhs ",
               "SET lintotnum = ? ",
               "   ,pdolinnum = ? ",
               "WHERE vrscod = ? ",
               "AND   pcmnum = ? "
   prepare p_cty22g03_082 from l_sql

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitaram ",
               "WHERE itaramcod = ? "
   prepare p_cty22g03_083 from l_sql
   declare c_cty22g03_083 cursor with hold for p_cty22g03_083


   #let l_sql = "  select cornom               ",
   #            "  from gcaksusep a,           ",
   #            "       gcakcorr b             ",
   #            "where a.corsus  = ?           ",
   #            "and a.corsuspcp = b.corsuspcp "
   #prepare p_cty22g03_086  from l_sql
   #declare c_cty22g03_086  cursor for p_cty22g03_086


   #let l_sql = "SELECT COUNT(*) ",
   #            "FROM datkresitaclisgm ",
   #            "WHERE itaclisgmcod = ? "
   #prepare p_cty22g03_088 from l_sql
   #declare c_cty22g03_088 cursor with hold for p_cty22g03_088


   let l_sql = "select count(*) from datkresitasrv ",
              " where itaasitipflg = ? "
   prepare p_cty22g03_091 from l_sql
   declare c_cty22g03_091 cursor with hold for p_cty22g03_091

   let l_sql = "SELECT plncod ",
               "FROM datkresitapln ",
               "WHERE UPPER(plndes) = ? "
   prepare p_cty22g03_092 from l_sql
   declare c_cty22g03_092 cursor with hold for p_cty22g03_092

   let l_sql = "select srvcod from datkresitasrv ",
              " where itaasitipflg = ? "
   prepare p_cty22g03_093 from l_sql
   declare c_cty22g03_093 cursor with hold for p_cty22g03_093


    let l_sql = " update datmresitaapl set  ",
                "  prpnum = ? ",
                " ,incvigdat = ? ",
                " ,fnlvigdat = ? ",
                " ,segnom = ? ",
                " ,pestipcod = ? ",
                " ,segcpjcpfnum = ? ",
                " ,cpjordnum = ? ",
                " ,cpjcpfdignum = ? ",
                " ,seglgdnom = ? ",
                " ,seglgdnum = ? ",
                " ,seglcacpldes = ? ",
                " ,brrnom = ? ",
                " ,segcidnom = ? ",
                " ,estsgl = ? ",
                " ,cepcod = ? ",
                " ,cepcplcod = ? ",
                " ,dddcod = ? ",
                " ,telnum = ? ",
                " ,adnicldat = ? ",
                " ,sgmcod = ? ",
                " ,vrsnum = ? ",
                " ,pcmnum = ? ",
                " ,succod = ? ",
                " ,suscod = ? ",
                " ,eslsegflg = ? ",
                " ,segemanom = ? ",
                " WHERE itaciacod = ? ",
                " AND   itaramcod = ? ",
                " AND   aplnum    = ? ",
                " AND   aplseqnum = ? "
   prepare p_cty22g03_094 from l_sql

   let l_sql = " update datmresitaaplitm set "
               ," itmsttcod = ? "
               ," ,prdcod = ? "
               ," ,plncod = ? "
               ," ,empcod = ? "
               ," ,srvcod = ? "
               ," ,rscsegcbttipcod = ? "
               ," ,rscsegrestipcod = ? "
               ," ,rscsegimvtipcod = ? "
               ," ,rsclgdnom = ? "
               ," ,rsclgdnum = ? "
               ," ,rsccpldes = ? "
               ," ,rscbrrnom = ? "
               ," ,rsccidnom = ? "
               ," ,rscestsgl = ? "
               ," ,rsccepcod = ? "
               ," ,rsccepcplcod = ? "
               ," WHERE itaciacod = ? "
               ," AND   itaramcod = ? "
               ," AND   aplnum = ? "
               ," AND   aplseqnum = ? "
               ," and   aplitmnum = ? "
   prepare p_cty22g03_095 from l_sql


   let m_prepare = true

end function


#=======================================================
function cty22g03_verifica_inconsistencias(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================
# Verifica inconsistencias da carga (MOVIMENTO -> APOLICE)

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_dados record
       asiarqvrsnum  	     like datmresitaarqdet.vrscod
      ,asiarqlnhnum  	     like datmresitaarqdet.linnum
      ,ciacod        	     like datmresitaarqdet.ciacod
      ,ramcod        	     like datmresitaarqdet.ramcod
      ,aplnum        	     like datmresitaarqdet.aplnum
      ,aplitmnum     	     like datmresitaarqdet.aplitmnum
      ,aplvigincdat  	     like datmresitaarqdet.viginidat
      ,aplvigfnldat  	     like datmresitaarqdet.vigfimdat
      ,prpnum        	     like datmresitaarqdet.prpnum
      ,prdcod        	     like datmresitaarqdet.prdcod
      ,plncod        	     like datmresitaarqdet.plncod
      ,empasicod     	     like datmresitaarqdet.empcod
      ,asisrvcod     	     like datmresitaarqdet.srvcod
      ,segnom           	 like datmresitaarqdet.segnom
      ,pestipcod        	 like datmresitaarqdet.pestipcod
      ,segcgccpfnum     	 like datmresitaarqdet.cpjcpfcod
      ,seglgdnom        	 like datmresitaarqdet.seglgdnom
      ,seglgdnum        	 like datmresitaarqdet.seglgdnum
      ,segendcmpdes     	 like datmresitaarqdet.seglcacplnom
      ,segbrrnom        	 like datmresitaarqdet.segbrrnom
      ,segcidnom        	 like datmresitaarqdet.segcidnom
      ,segufdsgl        	 like datmresitaarqdet.segestsgl
      ,segcepnum        	 like datmresitaarqdet.segcepcod
      ,segresteldddnum  	 like datmresitaarqdet.dddcod
      ,segrestelnum     	 like datmresitaarqdet.telnum
      ,rsclcllgdnom     	 like datmresitaarqdet.rsclgdnom
      ,rsclcllgdnum     	 like datmresitaarqdet.rsclgdnum
      ,rsclclendcmpdes  	 like datmresitaarqdet.rsclcacpldes
      ,rsclclbrrnom     	 like datmresitaarqdet.rscbrrnom
      ,rsclclcidnom     	 like datmresitaarqdet.rsccidnom
      ,rsclclufdsgl     	 like datmresitaarqdet.rscestsgl
      ,rsclclcepnum     	 like datmresitaarqdet.rsccepcod
      ,itacobsegcod     	 like datmresitaarqdet.rscsegcbttipcod
      ,itaressegcod     	 like datmresitaarqdet.restipcod
      ,itamrdsegcod     	 like datmresitaarqdet.imvtipcod
      ,mvtsttcod        	 like datmresitaarqdet.movsttcod
      ,adniclhordat     	 like datmresitaarqdet.adnicldat
      ,itapcshordat     	 like datmresitaarqdet.pcmdat
      ,itasegtipcod     	 like datmresitaarqdet.sgmtipcod
      ,corsus           	 like datmresitaarqdet.suscod
      ,itaasiarqvrsnumre	 like datmresitaarqdet.vrscod
      ,auxprdcod           like datmresitaaplitm.prdcod       
      ,auxsgrplncod        like datmresitaaplitm.plncod
      ,auxempasicod        like datmresitaaplitm.empcod
      ,auxasisrvcod        like datmresitaaplitm.srvcod
      ,auxsegtipcod        like datmresitaapl.sgmcod
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

   define l_cont_impedit smallint  #Qtd inconsistencias impeditivas de gravacao
   define l_cont_nimpedit smallint #Qtd inconsistencias nao impeditivas de gravacao

   initialize lr_arquivo.* to null
   initialize lr_erro.* to null
   let l_cont_impedit = 0
   let l_cont_nimpedit = 0

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   let lr_arquivo.asiarqvrsnum = lr_dados.asiarqvrsnum
   let lr_arquivo.asiarqlnhnum = lr_dados.asiarqlnhnum
   let lr_arquivo.pcsseqnum = lr_hist_process.pcsseqnum

   # Validacoes comuns para Inclusoes e Cancelamentos

   # VALIDA INCONSISTENCIAS ARQUIVO DE CARGA ATUAL
   if lr_apolice_atual.aplseqnum is null then
      # Este if valida se й o primeiro item. Os demais itens seguirao o primeiro.

      call cty22g03_valida_inconsist_atual(lr_apolice_atual.*)
      returning lr_valida.*
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if
   end if

   # VALIDA INCONSISTENCIAS ARQUIVOS DE CARGA ANTERIORES
   if l_cont_impedit = 0 then
      # Verifica cargas anteriores apenas se nгo existir inconsistencia no arquivo atual

      call cty22g03_valida_inconsist_anterior(lr_apolice_atual.*, lr_arquivo.*)
      returning lr_valida.*
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if
   end if


   # VALIDA CHAVE DA APOLICE
   call cty22g03_valida_chave_apolice(lr_apolice_atual.*)
   returning lr_valida.*
   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if


   # VALIDA COMPANHIA
   call cty22g03_valida_companhia(lr_dados.ciacod)
   returning lr_valida.*, lr_dados.ciacod


   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if



   # VALIDA RAMO
   call cty22g03_valida_ramo(lr_dados.ramcod)
   returning lr_valida.*, lr_dados.ramcod
  
   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if




  
   if lr_dados.mvtsttcod = 'I' then
      
      # VALIDA PRODUTO      
      call cty22g03_valida_produto(lr_dados.prdcod)
      returning lr_valida.*, lr_dados.auxprdcod
     
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if


      # VALIDA PLANO      
      call cty22g03_valida_plano(lr_dados.plncod,lr_dados.prdcod)
      returning lr_valida.*, lr_dados.auxsgrplncod
     
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if


      call cty22g03_acerta_servico_prestado(lr_dados.asisrvcod, lr_dados.itaressegcod)
      returning lr_dados.asisrvcod
      
      # VALIDA SERVICO PRESTADO
      call cty22g03_valida_servico_prestado(lr_dados.asisrvcod)
      returning lr_valida.*, lr_dados.auxasisrvcod
      

      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

     

      # VALIDA SEGMENTO
      call cty22g03_valida_segmento(lr_dados.itasegtipcod)
      returning lr_valida.*, lr_dados.auxsegtipcod
      

      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if



      # VALIDA CPF/CNPJ
      call cty22g03_valida_cgccpf(lr_dados.segcgccpfnum)
      returning lr_valida.*

      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         call cty22g03_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*, l_cont_impedit, l_cont_nimpedit, lr_dados.*

#============================================================
end function  # Fim funcao cty22g03_verifica_inconsistencias
#===========================================================}

#=======================================================
function cty22g03_valida_companhia(lr_param)
#=======================================================

   define lr_param record
      ciacod like datkitacia.itaciacod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.valor  = lr_param.ciacod clipped
   let lr_valida.campo = "CODIGO DA COMPANHIA (itaciacod)"
   let l_count = 0

   if lr_param.ciacod is null or
      lr_param.ciacod clipped = "" or
      lr_param.ciacod = 0 or
      lr_param.ciacod = 9999 then

      #let lr_param.ciacod = 9999 #NAO INFORMADO
      let lr_valida.erro = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.ciacod
   end if

   whenever error continue
   open c_cty22g03_054 using lr_param.ciacod
   fetch c_cty22g03_054 into l_count
   whenever error stop
   close c_cty22g03_054

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitacia>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.ciacod
   end if

  if l_count <= 0 then
      #let lr_param.ciacod = 9999 #NAO INFORMADO
      let lr_valida.erro = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*, lr_param.ciacod

#========================================================================
end function # Fim funcao cty22g03_valida_companhia
#========================================================================
#=======================================================
function cty22g03_valida_ramo(lr_param)
#=======================================================

   define lr_param record
      ramcod like datkitaram.itaramcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.valor  = lr_param.ramcod clipped
   let lr_valida.campo = "CODIGO DO RAMO (itaramcod)"
   let l_count = 0

   if lr_param.ramcod is null or
      lr_param.ramcod clipped = "" or
      lr_param.ramcod = 0 or
      lr_param.ramcod = 9999 then

      #let lr_param.ramcod = 9999 #NAO INFORMADO
      let lr_valida.erro = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.ramcod
   end if

   whenever error continue
   open c_cty22g03_083 using lr_param.ramcod
   fetch c_cty22g03_083 into l_count
   whenever error stop
   close c_cty22g03_083

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitacia>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.ramcod
   end if

  if l_count <= 0 then
      #let lr_param.ramcod = 9999 #NAO INFORMADO
      let lr_valida.erro = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*, lr_param.ramcod

#========================================================================
end function # Fim funcao cty22g03_valida_ramo
#========================================================================

#=======================================================
function cty22g03_valida_produto(lr_param)
#=======================================================

   define lr_param record
      prdcod like datkresitaprd.prdcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO PRODUTO (itaprdcod)"
   let lr_valida.valor  = lr_param.prdcod clipped
   let l_count = 0

   if lr_param.prdcod is null or
      lr_param.prdcod clipped = "" or
      lr_param.prdcod = 0 or
      lr_param.prdcod = 9999 then

      let lr_param.prdcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.prdcod
   end if

   whenever error continue
   open c_cty22g03_056 using lr_param.prdcod
   fetch c_cty22g03_056 into l_count
   whenever error stop
   close c_cty22g03_056

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaprd>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.prdcod
   end if

  if l_count <= 0 then
      let lr_param.prdcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*, lr_param.prdcod

#========================================================================
end function # Fim funcao cty22g03_valida_produto
#========================================================================

#=======================================================
function cty22g03_valida_inconsist_anterior(lr_apolice_atual, lr_arquivo)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_arquivo record
       asiarqvrsnum  like datmresitaarqcrgic.vrscod
      ,pcsseqnum     like datmresitaarqcrgic.pcmnum
      ,asiarqlnhnum  like datmresitaarqcrgic.linnum
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.codigo = 7 # ENCONTRADAS INCONSISTENCIAS DA MESMA APOLICE
   let lr_valida.campo = "ARQUIVO DE CARGA ANTERIOR"
   let l_count = 0

   whenever error continue
   open c_cty22g03_061 using lr_apolice_atual.ciacod
                           ,lr_apolice_atual.ramcod
                           ,lr_apolice_atual.aplnum
                           ,lr_arquivo.asiarqvrsnum
   fetch c_cty22g03_061 into l_count
   whenever error stop
   close c_cty22g03_061

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datmresitaarqcrgic>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*
   end if

  if l_count >= 1 then
      let lr_valida.erro = 1
      call cty22g03_trim(l_count)
      returning lr_valida.valor
      let lr_valida.valor = lr_valida.valor clipped, " INCONSISTENCIA(S)."
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g03_valida_inconsist_anterior
#========================================================================

#=======================================================
function cty22g03_valida_inconsist_atual(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.codigo = 7 # ENCONTRADAS INCONSISTENCIAS DA MESMA APOLICE
   let lr_valida.campo = "PROCESSAMENTO DE CARGA ATUAL"

  if lr_apolice_atual.qtdinconsist >= 1 then
      let lr_valida.erro = 1
      call cty22g03_trim(lr_apolice_atual.qtdinconsist)
      returning lr_valida.valor
      let lr_valida.valor = lr_valida.valor clipped, " INCONSISTENCIA(S)."
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g03_valida_inconsist_atual
#========================================================================

#=======================================================
function cty22g03_valida_segmento(lr_param)
#=======================================================

   define lr_param record
      itasgmcod  like datkresitaclisgm.sgmasttipflg
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_itaclisgmcod like datmresitaarqdet.sgmtipcod
   let l_itaclisgmcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "SEGMENTO DO CLIENTE (itasgmcod)"
   let lr_valida.valor  = lr_param.itasgmcod clipped

   if lr_param.itasgmcod is null then
      let l_itaclisgmcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_itaclisgmcod
   end if

   whenever error continue
   open c_cty22g03_055 using lr_param.itasgmcod
   fetch c_cty22g03_055 into l_itaclisgmcod
   whenever error stop
   close c_cty22g03_055

   #if l_itaclisgmcod = 16 then
   #   display "SEGMENTO TESTE: ", lr_param.itasgmcod
   #   prompt "<ENTER>" for lr_valida.campo
   #end if

   if sqlca.sqlcode = notfound or l_itaclisgmcod is null or l_itaclisgmcod = 0 then
      let l_itaclisgmcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_itaclisgmcod
   end if

   if sqlca.sqlcode < 0 then
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaclisgm>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if



  return lr_valida.*, l_itaclisgmcod

#========================================================================
end function # Fim funcao cty22g03_valida_segmento
#========================================================================

#=======================================================
function cty22g03_valida_chave_apolice(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.codigo = 8 #CODIGO TIPO INCONSISTENCIA
   let lr_valida.campo = "CIA, RAMO, APOL, ITEM"

   if lr_apolice_atual.ciacod    is null or lr_apolice_atual.ciacod    = 0 or
      lr_apolice_atual.ramcod    is null or lr_apolice_atual.ramcod    = 0 or
      lr_apolice_atual.aplnum    is null or lr_apolice_atual.aplnum    = 0 or
     (lr_apolice_atual.aplitmsttcod = 'I' and (
      lr_apolice_atual.aplitmnum is null or lr_apolice_atual.aplitmnum = 0)) then
      let lr_valida.erro = 1
      let lr_valida.valor  = lr_apolice_atual.ciacod     clipped, ", ",
                             lr_apolice_atual.ramcod     clipped, ", ",
                             lr_apolice_atual.aplnum     clipped, ", ",
                             lr_apolice_atual.aplitmnum  clipped, ", "
   end if

   if sqlca.sqlcode < 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaclisgm>."
   end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g03_valida_chave_apolice
#========================================================================


#=======================================================
function cty22g03_valida_plano(lr_param)
#=======================================================

   define lr_param record
      itaplncod like datkresitapln.plncod,
      itaprdcod like datkresitapln.prdcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO PLANO (plncod)"
   let lr_valida.valor  = lr_param.itaplncod clipped
   let l_count = 0

   if lr_param.itaplncod is null or
      lr_param.itaplncod clipped = "" or
      lr_param.itaplncod = 0 or
      lr_param.itaplncod = 9999 then

      let lr_param.itaplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.itaplncod
   end if

   whenever error continue
   open c_cty22g03_057 using lr_param.itaplncod,lr_param.itaprdcod
   fetch c_cty22g03_057 into l_count
   whenever error stop
   close c_cty22g03_057

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitasgrpln>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.itaplncod
   end if

  if l_count <= 0 then
      let lr_param.itaplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
      let lr_valida.erro = 1
  end if

  return lr_valida.*, lr_param.itaplncod

#========================================================================
end function # Fim funcao cty22g03_valida_plano
#========================================================================


#=======================================================
function cty22g03_valida_servico_prestado(lr_param)
#=======================================================

   define lr_param record
      asisrvcod like datkresitasrv.itaasitipflg
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO SERVICO PRESTADO (itaasisrvcod)"
   let lr_valida.valor  = lr_param.asisrvcod clipped
   let l_count = 0

   if lr_param.asisrvcod is null or
      lr_param.asisrvcod clipped = "" or
      lr_param.asisrvcod = 9999 then

      #display "teste"
      let lr_param.asisrvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.asisrvcod
   end if

   #display "cty 1433 - lr_param.asisrvcod = " ,lr_param.asisrvcod
   whenever error continue
   open c_cty22g03_091 using lr_param.asisrvcod
   fetch c_cty22g03_091 into l_count
   whenever error stop
   close c_cty22g03_091

   #display "l_count = ",l_count
   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaasisrv>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.asisrvcod
   end if

  if l_count <= 0 then
      let lr_param.asisrvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*, lr_param.asisrvcod

#========================================================================
end function # Fim funcao cty22g03_valida_servico_prestado
#========================================================================


#=======================================================
function cty22g03_valida_empresa(lr_param)
#=======================================================

   define lr_param record
      empasidcod like datkitaempasi.itaempasicod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.valor  = lr_param.empasidcod clipped
   let lr_valida.campo = "CODIGO DA EMPRESA (itaempasicod)"
   let l_count = 0

   if lr_param.empasidcod is null or
      lr_param.empasidcod clipped = "" or
      lr_param.empasidcod = 0 or
      lr_param.empasidcod = 9999 then

      let lr_param.empasidcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.empasidcod
   end if

   whenever error continue
   open c_cty22g03_058 using lr_param.empasidcod
   fetch c_cty22g03_058 into l_count
   whenever error stop
   close c_cty22g03_058

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaempasi>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.empasidcod
   end if

   if l_count <= 0 then
      let lr_param.empasidcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
   end if

  return lr_valida.*, lr_param.empasidcod

#========================================================================
end function # Fim funcao cty22g03_valida_empresa
#========================================================================
#=======================================================
function cty22g03_valida_cgccpf(lr_param)
#=======================================================

   define lr_param record
      segcgccpfnum like datmresitaarqdet.cpjcpfcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count integer

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "NUMERO DO CPF/CNPJ (segcgccpfnum)"
   let lr_valida.valor  = lr_param.segcgccpfnum clipped

   if lr_param.segcgccpfnum is null or
      lr_param.segcgccpfnum clipped = "" or
      lr_param.segcgccpfnum = 0 then

      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      let lr_valida.warn = 1
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g03_valida_cgccpf
#========================================================================


#=======================================================
function cty22g03_libera_inconsistencia(lr_param) # Por numero de apolice
#=======================================================
   define lr_param record
      apolice     like datmresitaarqcrgic.aplnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null


   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   #let g_issk.funmat = 5849
   #let g_issk.empcod = 1
   #let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO


   whenever error continue
   execute p_cty22g03_052 using g_issk.usrtip
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,lr_param.apolice
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") na liberacao da INCONSISTENCIA (1). Tabela: <datmresitaarqcrgic>."
   else
      let lr_erro.sqlcode = 0
   end if

   return lr_erro.*

#=======================================================
end function # Fim da funcao cty22g03_libera_inconsistencia
#=======================================================

#=======================================================
function cty22g03_libera_inconsistencia2(lr_param) # Pela chave da inconsistencia
#=======================================================
   define lr_param record
      itaasiarqvrsnum   like datmresitaarqcrgic.vrscod
     ,pcsseqnum         like datmresitaarqcrgic.pcmnum
     ,itaasiarqlnhnum   like datmresitaarqcrgic.linnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null


   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   #let g_issk.funmat = 5849
   #let g_issk.empcod = 1
   #let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO


   whenever error continue
   execute p_cty22g03_052b using g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,lr_param.itaasiarqvrsnum
                                ,lr_param.pcsseqnum
                                ,lr_param.itaasiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") na liberacao da INCONSISTENCIA (2). Tabela: <datmresitaarqcrgic>."
   else
      let lr_erro.sqlcode = 0
   end if

   return lr_erro.*

#=======================================================
end function # Fim da funcao cty22g03_libera_inconsistencia2
#=======================================================

#=======================================================
function cty22g03_busca_sequencia_continua(lr_apolice_atual)
#=======================================================
   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_sequencia   like datmresitaapl.aplseqnum
   define l_count       smallint

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   open c_cty22g03_080 using lr_apolice_atual.ciacod
                          ,lr_apolice_atual.ramcod
                          ,lr_apolice_atual.aplnum
   fetch c_cty22g03_080 into l_sequencia
   whenever error stop
   close c_cty22g03_080

   let lr_erro.sqlcode = sqlca.sqlcode

   if lr_erro.sqlcode = notfound then
      return lr_erro.*, 0
   end if

   if lr_erro.sqlcode <> 0 then
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar a sequencia da APOLICE. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   whenever error continue
   open c_cty22g03_053 using lr_apolice_atual.ciacod
                          ,lr_apolice_atual.ramcod
                          ,lr_apolice_atual.aplnum
                          ,l_sequencia
                          ,lr_apolice_atual.aplitmnum
   fetch c_cty22g03_053 into l_count
   whenever error stop
   close c_cty22g03_053

   let lr_erro.sqlcode = sqlca.sqlcode

   if lr_erro.sqlcode <> 0 then
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar a sequencia da APOLICE. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   if l_count > 0 then
      return lr_erro.*, 0
   end if

   return lr_erro.*, l_sequencia

#=======================================================
end function # Fim da funcao cty22g03_busca_sequencia_continua
#=======================================================

#=================================================================
function cty22g03_carrega_cancelamento(lr_apolice_atual, lr_hist_process)
#=================================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
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

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   # Recupera a ultima sequencia da apolice a ser cancelada
   whenever error continue
   open c_cty22g03_075 using lr_apolice_atual.ciacod
                            ,lr_apolice_atual.ramcod
                            ,lr_apolice_atual.aplnum
   fetch c_cty22g03_075 into lr_apolice_atual.aplseqnum
   whenever error stop
   close c_cty22g03_075

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na recuperacao da sequencial atual CANCELAMENTO. Tabela: <datmitaapl>."
      return lr_erro.*, 0
   end if

   if lr_apolice_atual.aplseqnum is null then
      # Ignora os casos que nгo foram encontrados

      let lr_erro.sqlcode = 0
      return lr_erro.*, 0
   end if

   # Cria nova sequencia copiando os dados de apolice da sequencia anterior
   whenever error continue
   execute p_cty22g03_076 using lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no CANCELAMENTO da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   # Atualiza o numero de processamento da apolice
   whenever error continue
   execute p_cty22g03_077 using lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
                               ,lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na atualizacao do processamento da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   # Cria nova sequencia copiando os dados do item da sequencia anterior
   whenever error continue
   execute p_cty22g03_078 using lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no CANCELAMENTO do item da apolice (1). Tabela <datmitaaplitm>."
      return lr_erro.*, 0
   end if

      whenever error continue
      execute p_cty22g03_079b using lr_apolice_atual.ciacod
                                   ,lr_apolice_atual.ramcod
                                   ,lr_apolice_atual.aplnum
                                   ,lr_apolice_atual.aplseqnum
                                   ,lr_apolice_atual.aplitmnum
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_erro.sqlcode = sqlca.sqlcode
         let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") no CANCELAMENTO do item da apolice (3). Tabela <datmitaaplitm>."
         return lr_erro.*, 0
      end if

   #end if

   # Soma 1 pois o cancelamento do item X gera a sequencia X+1
   let lr_apolice_atual.aplseqnum = lr_apolice_atual.aplseqnum + 1

   return lr_erro.*, lr_apolice_atual.aplseqnum

#=================================================================
end function # Fim da Funзгo cty22g03_carrega_cancelamento
#=================================================================

#=======================================================
function cty22g03_carrega_tabela_item(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record


   define lr_dados record
       itaasiarqvrsnum  	 like datmresitaarqdet.vrscod
      ,itaasiarqlnhnum  	 like datmresitaarqdet.linnum
      ,itaciacod        	 like datmresitaarqdet.ciacod
      ,itaramcod        	 like datmresitaarqdet.ramcod
      ,itaaplnum        	 like datmresitaarqdet.aplnum
      ,itaaplitmnum     	 like datmresitaarqdet.aplitmnum
      ,itaaplvigincdat  	 like datmresitaarqdet.viginidat
      ,itaaplvigfnldat  	 like datmresitaarqdet.vigfimdat
      ,itaprpnum        	 like datmresitaarqdet.prpnum
      ,itaprdcod        	 like datmresitaarqdet.prdcod
      ,itaplncod        	 like datmresitaarqdet.plncod
      ,itaempasicod     	 like datmresitaarqdet.empcod
      ,itaasisrvcod     	 like datmresitaarqdet.srvcod
      ,segnom           	 like datmresitaarqdet.segnom
      ,pestipcod        	 like datmresitaarqdet.pestipcod
      ,segcgccpfnum     	 like datmresitaarqdet.cpjcpfcod
      ,seglgdnom        	 like datmresitaarqdet.seglgdnom
      ,seglgdnum        	 like datmresitaarqdet.seglgdnum
      ,segendcmpdes     	 like datmresitaarqdet.seglcacplnom
      ,segbrrnom        	 like datmresitaarqdet.segbrrnom
      ,segcidnom        	 like datmresitaarqdet.segcidnom
      ,segufdsgl        	 like datmresitaarqdet.segestsgl
      ,segcepnum        	 like datmresitaarqdet.segcepcod
      ,segresteldddnum  	 like datmresitaarqdet.dddcod
      ,segrestelnum     	 like datmresitaarqdet.telnum
      ,rsclcllgdnom     	 like datmresitaarqdet.rsclgdnom
      ,rsclcllgdnum     	 like datmresitaarqdet.rsclgdnum
      ,rsclclendcmpdes  	 like datmresitaarqdet.rsclcacpldes
      ,rsclclbrrnom     	 like datmresitaarqdet.rscbrrnom
      ,rsclclcidnom     	 like datmresitaarqdet.rsccidnom
      ,rsclclufdsgl     	 like datmresitaarqdet.rscestsgl
      ,rsclclcepnum     	 like datmresitaarqdet.rsccepcod
      ,itacobsegcod     	 like datmresitaarqdet.rscsegcbttipcod
      ,itaressegcod     	 like datmresitaarqdet.restipcod
      ,itamrdsegcod     	 like datmresitaarqdet.imvtipcod
      ,mvtsttcod        	 like datmresitaarqdet.movsttcod
      ,adniclhordat     	 like datmresitaarqdet.adnicldat
      ,itapcshordat     	 like datmresitaarqdet.pcmdat
      ,itasegtipcod     	 like datmresitaarqdet.sgmtipcod
      ,corsus           	 like datmresitaarqdet.suscod
      ,itaasiarqvrsnumre	 like datmresitaarqdet.vrscod
      ,auxprdcod       like datmresitaaplitm.prdcod       # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod    like datmresitaaplitm.plncod
      ,auxempasicod    like datmresitaaplitm.empcod
      ,auxasisrvcod    like datmresitaaplitm.srvcod
      ,auxsegtipcod    like datmresitaapl.sgmcod
   end record

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

   define lr_item record
       ciacod           like datmresitaaplitm.itaciacod
      ,ramcod           like datmresitaaplitm.itaramcod
      ,aplnum           like datmresitaaplitm.aplnum
      ,aplseqnum        like datmresitaaplitm.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,itaprdcod        like datmresitaaplitm.prdcod
      ,itaplncod        like datmresitaaplitm.plncod
      ,itaempasicod     like datmresitaaplitm.empcod
      ,itaasisrvcod     like datmresitaaplitm.srvcod
      ,itacobsegcod     like datmresitaaplitm.rscsegcbttipcod
      ,itaressegcod     like datmresitaaplitm.rscsegrestipcod
      ,itamrdsegcod     like datmresitaaplitm.rscsegimvtipcod
      ,rsclcllgdnom     like datmresitaaplitm.rsclgdnom
      ,rsclcllgdnum     like datmresitaaplitm.rsclgdnum
      ,rsclclendcmpdes  like datmresitaaplitm.rsccpldes
      ,rsclclbrrnom     like datmresitaaplitm.rscbrrnom
      ,rsclclcidnom     like datmresitaaplitm.rsccidnom
      ,rsclclufdsgl     like datmresitaaplitm.rscestsgl
      ,rsclclcepnum     like datmresitaaplitm.rsccepcod
      ,rsclclcepcmpnum  like datmresitaaplitm.rsccepcplcod

   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null
   initialize lr_item.* to null


   let lr_item.ciacod            = lr_apolice_atual.ciacod
   let lr_item.ramcod            = lr_apolice_atual.ramcod
   let lr_item.aplnum            = lr_apolice_atual.aplnum
   let lr_item.aplseqnum         = lr_apolice_atual.aplseqnum
   let lr_item.aplitmnum         = lr_apolice_atual.aplitmnum
   let lr_item.aplitmsttcod      = lr_dados.mvtsttcod
   let lr_item.itaprdcod         = lr_dados.itaprdcod
   let lr_item.itaplncod         = lr_dados.itaplncod
   let lr_item.itaempasicod      = lr_dados.itaempasicod
   let lr_item.itaasisrvcod      = lr_dados.itaasisrvcod
   let lr_item.itacobsegcod      = lr_dados.itacobsegcod
   let lr_item.itaressegcod      = lr_dados.itaressegcod
   let lr_item.itamrdsegcod      = lr_dados.itamrdsegcod
   let lr_item.rsclcllgdnom      = lr_dados.rsclcllgdnom
   let lr_item.rsclcllgdnum      = lr_dados.rsclcllgdnum
   let lr_item.rsclclendcmpdes   = lr_dados.rsclclendcmpdes
   let lr_item.rsclclbrrnom      = lr_dados.rsclclbrrnom
   let lr_item.rsclclcidnom      = lr_dados.rsclclcidnom
   let lr_item.rsclclufdsgl      = lr_dados.rsclclufdsgl
   let lr_item.rsclclcepnum      = lr_dados.rsclclcepnum[1,5]
   let lr_item.rsclclcepcmpnum   = lr_dados.rsclclcepnum[6,8]



   #display "lr_dados.itaasisrvcod = ",lr_dados.itaasisrvcod
   whenever error continue
     open c_cty22g03_093 using lr_dados.itaasisrvcod
     fetch c_cty22g03_093 into lr_item.itaasisrvcod
   whenever error stop
   #isplay "lr_item.itaasisrvcod  = ",lr_item.itaasisrvcod








   # Se a data de inicio de assistencia vier em branco, assumir a data de inicio de vigencia
   #if lr_item.asiincdat is null or
   #   lr_item.asiincdat = " " then
   #   let lr_item.asiincdat = lr_dados.aplvigincdat
   #end if

   #

   #display "lr_item.ciacod           = ",lr_item.ciacod
   #display "lr_item.ramcod           = ",lr_item.ramcod
   #display "lr_item.aplnum           = ",lr_item.aplnum
   #display "lr_item.aplseqnum        = ",lr_item.aplseqnum
   #display "lr_item.aplitmnum        = ",lr_item.aplitmnum
   #display "lr_item.aplitmsttcod     = ",lr_item.aplitmsttcod
   #display "lr_item.itaprdcod        = ",lr_item.itaprdcod
   #display "lr_item.itaplncod        = ",lr_item.itaplncod
   #display "lr_item.itaempasicod     = ",lr_item.itaempasicod
   #display "lr_item.itaasisrvcod     = ",lr_item.itaasisrvcod
   #display "lr_item.itacobsegcod     = ",lr_item.itacobsegcod
   #display "lr_item.itaressegcod     = ",lr_item.itaressegcod
   #display "lr_item.itamrdsegcod     = ",lr_item.itamrdsegcod
   #display "lr_item.rsclcllgdnom     = ",lr_item.rsclcllgdnom
   #display "lr_item.rsclcllgdnum     = ",lr_item.rsclcllgdnum
   #display "lr_item.rsclclendcmpdes  = ",lr_item.rsclclendcmpdes
   #display "lr_item.rsclclbrrnom     = ",lr_item.rsclclbrrnom
   #display "lr_item.rsclclcidnom     = ",lr_item.rsclclcidnom
   #display "lr_item.rsclclufdsgl     = ",lr_item.rsclclufdsgl
   #display "lr_item.rsclclcepnum     = ",lr_item.rsclclcepnum
   #display "lr_item.rsclclcepcmpnum  = ",lr_item.rsclclcepcmpnum
   #prompt "<ENTER>" for lr_erro.mens
   #

   whenever error continue
   execute p_cty22g03_069 using lr_item.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do ITEM DA APOLICE. Tabela <datmitaaplitm> - ",lr_item.itaasisrvcod
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#=======================================================
end function  # Fim funcao cty22g03_carrega_tabela_item
#=======================================================
#========================================================================
function cty22g03_gera_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   open c_cty22g03_062 using lr_hist_process.asiarqvrsnum
   fetch c_cty22g03_062 into lr_hist_process.pcsseqnum
   whenever error stop
   close c_cty22g03_062

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar sequencia do PROCESSAMENTO. Tabela <datmitaarqpcshst>."
      return lr_erro.*
   end if

   whenever error continue
   execute p_cty22g03_063 using lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
                               ,lr_hist_process.lnhtotqtd
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao inserir PROCESSAMENTO. Tabela <datmitaarqpcshst>."
      return lr_erro.*, 0
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*, lr_hist_process.pcsseqnum
#========================================================================
end function # Fim da funcao cty22g03_gera_processamento
#========================================================================

#========================================================================
function cty22g03_encerra_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   execute p_cty22g03_081 using lr_hist_process.lnhtotqtd
                               ,lr_hist_process.pcslnhqtd
                               ,lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao encerrar PROCESSAMENTO. Tabela <datmitaarqpcshst>."
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*
#========================================================================
end function # Fim da funcao cty22g03_encerra_processamento
#========================================================================
#========================================================================
function cty22g03_atualiza_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null
   #
   #
   #display "lr_hist_process.lnhtotqtd    = ",lr_hist_process.lnhtotqtd
   #display "lr_hist_process.pcslnhqtd    = ",lr_hist_process.pcslnhqtd
   #display "lr_hist_process.asiarqvrsnum = ",lr_hist_process.asiarqvrsnum
   #display "lr_hist_process.pcsseqnum    = ",lr_hist_process.pcsseqnum
   #




   whenever error continue
   execute p_cty22g03_082 using lr_hist_process.lnhtotqtd
                               ,lr_hist_process.pcslnhqtd
                               ,lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao atualizar PROCESSAMENTO. Tabela <datmitaarqpcshst>."
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0
   return lr_erro.*
#========================================================================
end function # Fim da funcao cty22g03_atualiza_processamento
#========================================================================

#=======================================================
function cty22g03_gera_sequencia_apolice(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record

   define l_sequencia   like datmitaapl.aplseqnum

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   whenever error continue
   open c_cty22g03_067 using lr_apolice_atual.ciacod,
                            lr_apolice_atual.ramcod,
                            lr_apolice_atual.aplnum
   fetch c_cty22g03_067 into l_sequencia
   whenever error stop
   close c_cty22g03_067

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no calculo da sequencia para CARGA da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*, l_sequencia

#=======================================================
end function  # Fim funcao cty22g03_gera_sequencia_apolice
#=======================================================

#=======================================================
function cty22g03_carrega_tabela_apolice(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
   end record


   define lr_dados record
       itaasiarqvrsnum  	 like datmresitaarqdet.vrscod
      ,itaasiarqlnhnum  	 like datmresitaarqdet.linnum
      ,itaciacod        	 like datmresitaarqdet.ciacod
      ,itaramcod        	 like datmresitaarqdet.ramcod
      ,itaaplnum        	 like datmresitaarqdet.aplnum
      ,itaaplitmnum     	 like datmresitaarqdet.aplitmnum
      ,itaaplvigincdat  	 like datmresitaarqdet.viginidat
      ,itaaplvigfnldat  	 like datmresitaarqdet.vigfimdat
      ,itaprpnum        	 like datmresitaarqdet.prpnum
      ,itaprdcod        	 like datmresitaarqdet.prdcod
      ,itaplncod        	 like datmresitaarqdet.plncod
      ,itaempasicod     	 like datmresitaarqdet.empcod
      ,itaasisrvcod     	 like datmresitaarqdet.srvcod
      ,segnom           	 like datmresitaarqdet.segnom
      ,pestipcod        	 like datmresitaarqdet.pestipcod
      ,segcgccpfnum     	 like datmresitaarqdet.cpjcpfcod
      ,seglgdnom        	 like datmresitaarqdet.seglgdnom
      ,seglgdnum        	 like datmresitaarqdet.seglgdnum
      ,segendcmpdes     	 like datmresitaarqdet.seglcacplnom
      ,segbrrnom        	 like datmresitaarqdet.segbrrnom
      ,segcidnom        	 like datmresitaarqdet.segcidnom
      ,segufdsgl        	 like datmresitaarqdet.segestsgl
      ,segcepnum        	 like datmresitaarqdet.segcepcod
      ,segresteldddnum  	 like datmresitaarqdet.dddcod
      ,segrestelnum     	 like datmresitaarqdet.telnum
      ,rsclcllgdnom     	 like datmresitaarqdet.rsclgdnom
      ,rsclcllgdnum     	 like datmresitaarqdet.rsclgdnum
      ,rsclclendcmpdes  	 like datmresitaarqdet.rsclcacpldes
      ,rsclclbrrnom     	 like datmresitaarqdet.rscbrrnom
      ,rsclclcidnom     	 like datmresitaarqdet.rsccidnom
      ,rsclclufdsgl     	 like datmresitaarqdet.rscestsgl
      ,rsclclcepnum     	 like datmresitaarqdet.rsccepcod
      ,itacobsegcod     	 like datmresitaarqdet.rscsegcbttipcod
      ,itaressegcod     	 like datmresitaarqdet.restipcod
      ,itamrdsegcod     	 like datmresitaarqdet.imvtipcod
      ,mvtsttcod        	 like datmresitaarqdet.movsttcod
      ,adniclhordat     	 like datmresitaarqdet.adnicldat
      ,itapcshordat     	 like datmresitaarqdet.pcmdat
      ,itasegtipcod     	 like datmresitaarqdet.sgmtipcod
      ,corsus           	 like datmresitaarqdet.suscod
      ,itaasiarqvrsnumre	 like datmresitaarqdet.vrscod
      ,auxprdcod           like datmresitaaplitm.prdcod       # DAQUI PRA BAIXO SAO AUXILIARES #
      ,auxsgrplncod        like datmresitaaplitm.plncod
      ,auxempasicod        like datmresitaaplitm.empcod
      ,auxasisrvcod        like datmresitaaplitm.srvcod
      ,auxsegtipcod        like datmresitaapl.sgmcod

   end record

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

   define lr_apolice record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,prpnum           like datmresitaapl.prpnum
      ,aplvigincdat     like datmresitaapl.incvigdat
      ,aplvigfnldat     like datmresitaapl.fnlvigdat
      ,segnom           like datmresitaapl.segnom
      ,pestipcod        like datmresitaapl.pestipcod
      ,segcgccpfnum     like datmresitaapl.segcpjcpfnum
      ,segcgcordnum     like datmresitaapl.cpjordnum
      ,segcgccpfdig     like datmresitaapl.cpjcpfdignum
      ,seglgdnom        like datmresitaapl.seglgdnom
      ,seglgdnum        like datmresitaapl.seglgdnum
      ,segendcmpdes     like datmresitaapl.seglcacpldes
      ,segbrrnom        like datmresitaapl.brrnom
      ,segcidnom        like datmresitaapl.segcidnom
      ,segufdsgl        like datmresitaapl.estsgl
      ,segcepnum        like datmresitaapl.cepcod
      ,segcepcmpnum     like datmresitaapl.cepcplcod
      ,segresteldddnum  like datmresitaapl.dddcod
      ,segrestelnum     like datmresitaapl.telnum
      ,adniclhordat     like datmresitaapl.adnicldat
      ,segsgmcod        like datmresitaapl.sgmcod
      ,asiarqvrsnum     like datmresitaapl.vrsnum
      ,pcsseqnum        like datmresitaapl.pcmnum
      ,succod           like datmresitaapl.succod
      ,corsus           like datmresitaapl.suscod
      ,vipsegflg        like datmresitaapl.eslsegflg
      ,segmaiend        like datmresitaapl.segemanom
   end record

   define lr_cgccpf record
       tipoPessoa   char(1)
      ,cgccpfnumdig char(20)
   end record

   define lr_sucursal    record
      inpcod            like gcaksusep.inpcod
     ,succod            smallint #like pcgksuc.succod
     ,msgerr            char(78)
   end record

   define l_prompt char(50)


   define l_data_hora char(20)

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null
   initialize lr_apolice.* to null
   initialize lr_cgccpf.* to null
   initialize lr_sucursal.* to null

   let l_data_hora = lr_dados.adniclhordat[5,8], "-", lr_dados.adniclhordat[3,4], "-", lr_dados.adniclhordat[1,2], " ",
                     lr_dados.adniclhordat[9,10], ":", lr_dados.adniclhordat[11,12], ":", lr_dados.adniclhordat[13,14]

   let lr_apolice.ciacod            = lr_apolice_atual.ciacod
   let lr_apolice.ramcod            = lr_apolice_atual.ramcod
   let lr_apolice.aplnum            = lr_apolice_atual.aplnum
   let lr_apolice.aplseqnum         = lr_apolice_atual.aplseqnum
   let lr_apolice.prpnum            = lr_dados.itaprpnum
   let lr_apolice.aplvigincdat      = lr_dados.itaaplvigincdat
   let lr_apolice.aplvigfnldat      = lr_dados.itaaplvigfnldat
   let lr_apolice.segnom            = lr_dados.segnom
   let lr_apolice.pestipcod         = lr_dados.pestipcod
   let lr_apolice.seglgdnom         = lr_dados.seglgdnom
   let lr_apolice.seglgdnum         = lr_dados.seglgdnum
   let lr_apolice.segendcmpdes      = lr_dados.segendcmpdes
   let lr_apolice.segbrrnom         = lr_dados.segbrrnom
   let lr_apolice.segcidnom         = lr_dados.segcidnom
   let lr_apolice.segufdsgl         = lr_dados.segufdsgl
   let lr_apolice.segcepnum         = lr_dados.segcepnum[1,5]
   let lr_apolice.segcepcmpnum      = lr_dados.segcepnum[6,8]
   let lr_apolice.segresteldddnum   = lr_dados.segresteldddnum
   let lr_apolice.segrestelnum      = lr_dados.segrestelnum
   let lr_apolice.adniclhordat      = l_data_hora
   let lr_apolice.asiarqvrsnum      = lr_hist_process.asiarqvrsnum
   let lr_apolice.segsgmcod         = lr_dados.itasegtipcod
   let lr_apolice.pcsseqnum         = lr_hist_process.pcsseqnum
   let lr_apolice.succod            = 0 # O CODIGO DEVE SER BUSCADO
   let lr_apolice.corsus            = lr_dados.corsus
   let lr_apolice.vipsegflg         = "N" # Buscar do ultimo sequencial da apolice, se houver
   let lr_apolice.segmaiend         = " " # Buscar do ultimo sequencial da apolice, se houver




   # Buscar flag de VIP e Endereco de E-mail da apolice quando for atualizacao
   # Considero apenas acima de 1 pois o primeiro sequencial significa que eh apolice nova
   if lr_apolice_atual.aplseqnum > 1 then

      whenever error continue
      open c_cty22g03_072 using lr_apolice_atual.ciacod,
                                lr_apolice_atual.ramcod,
                                lr_apolice_atual.aplnum,
                                lr_apolice_atual.aplseqnum
      fetch c_cty22g03_072 into lr_apolice.vipsegflg,
                                lr_apolice.segmaiend
      whenever error stop
      close c_cty22g03_072

      if sqlca.sqlcode <> 0 then # Ignora se der erro e assume os valores padrao
         let lr_apolice.vipsegflg = "N"
         let lr_apolice.segmaiend = " "
      end if
   end if


   # Trata CEP
   if lr_apolice.segcepnum is null then
      let lr_apolice.segcepnum = 0
   end if

   if lr_apolice.segcepcmpnum is null then
      let lr_apolice.segcepcmpnum = 0
   end if


   # Quebra CPF/CNPJ
   let lr_cgccpf.tipoPessoa = lr_dados.pestipcod
   let lr_cgccpf.cgccpfnumdig = lr_dados.segcgccpfnum

   call cty22g03_desmembra_cgccpf(lr_cgccpf.*)
   returning lr_apolice.segcgccpfnum
            ,lr_apolice.segcgcordnum
            ,lr_apolice.segcgccpfdig


   # Busca codigo da sucursal a partir da SUSEP do corretor
   #display "lr_apolice.corsus ",lr_apolice.corsus
   call fpcgc052_suc_susep(lr_apolice.corsus)
   returning lr_sucursal.inpcod
            ,lr_sucursal.succod
            ,lr_sucursal.msgerr

   if lr_sucursal.succod is not null and
      lr_sucursal.succod > 0 then
      let lr_apolice.succod = lr_sucursal.succod
   end if

   # RETIRAR
   # Se a data de inicio de assistencia vier em branco, assumir a data de inicio de vigencia
   #if lr_apolice.asiincdat is null or
   #   lr_apolice.asiincdat = " " then
   #   let lr_apolice.asiincdat = lr_apolice.aplvigincdat
   #end if


   #display "ciacod          : ", lr_apolice.ciacod
   #display "ramcod          : ", lr_apolice.ramcod
   #display "aplnum          : ", lr_apolice.aplnum
   #display "aplseqnum       : ", lr_apolice.aplseqnum
   #display "prpnum          : ", lr_apolice.prpnum
   #display "aplvigincdat    : ", lr_apolice.aplvigincdat
   #display "aplvigfnldat    : ", lr_apolice.aplvigfnldat
   #display "segnom          : ", lr_apolice.segnom
   #display "pestipcod       : ", lr_apolice.pestipcod
   #display "segcgccpfnum    : ", lr_apolice.segcgccpfnum
   #display "segcgcordnum    : ", lr_apolice.segcgcordnum
   #display "segcgccpfdig    : ", lr_apolice.segcgccpfdig
   #display "prdcod          : ", lr_apolice.prdcod
   #display "cliscocod       : ", lr_apolice.cliscocod
   #display "corsuscod       : ", lr_apolice.corsuscod
   #display "seglgdnom       : ", lr_apolice.seglgdnom
   #display "seglgdnum       : ", lr_apolice.seglgdnum
   #display "segendcmpdes    : ", lr_apolice.segendcmpdes
   #display "segbrrnom       : ", lr_apolice.segbrrnom
   #display "segcidnom       : ", lr_apolice.segcidnom
   #display "segufdsgl       : ", lr_apolice.segufdsgl
   #display "segcepnum       : ", lr_apolice.segcepnum
   #display "segcepcmpnum    : ", lr_apolice.segcepcmpnum
   #display "segresteldddnum : ", lr_apolice.segresteldddnum
   #display "segrestelnum    : ", lr_apolice.segrestelnum
   #display "adniclhordat    : ", lr_apolice.adniclhordat
   #display "asiarqvrsnum    : ", lr_apolice.asiarqvrsnum
   #display "pcsseqnum       : ", lr_apolice.pcsseqnum
   #display "succod          : ", lr_apolice.succod
   #display "corsus          : ", lr_apolice.corsus
   #display "vipsegflg       : ", lr_apolice.vipsegflg
   #display "segmaiend       : ", lr_apolice.segmaiend
   #prompt "<ENTER>" for lr_erro.mens

   #display "ciacod          = ",lr_apolice.ciacod
   #display "ramcod          = ",lr_apolice.ramcod
   #display "aplnum          = ",lr_apolice.aplnum
   #display "aplseqnum       = ",lr_apolice.aplseqnum
   #display "prpnum          = ",lr_apolice.prpnum
   #display "aplvigincdat    = ",lr_apolice.aplvigincdat
   #display "aplvigfnldat    = ",lr_apolice.aplvigfnldat
   #display "segnom          = ",lr_apolice.segnom
   #display "pestipcod       = ",lr_apolice.pestipcod
   #display "segcgccpfnum    = ",lr_apolice.segcgccpfnum
   #display "segcgcordnum    = ",lr_apolice.segcgcordnum
   #display "segcgccpfdig    = ",lr_apolice.segcgccpfdig
   #display "seglgdnom       = ",lr_apolice.seglgdnom
   #display "seglgdnum       = ",lr_apolice.seglgdnum
   #display "segendcmpdes    = ",lr_apolice.segendcmpdes
   #display "segbrrnom       = ",lr_apolice.segbrrnom
   #display "segcidnom       = ",lr_apolice.segcidnom
   #display "segufdsgl       = ",lr_apolice.segufdsgl
   #display "segcepnum       = ",lr_apolice.segcepnum
   #display "segcepcmpnum    = ",lr_apolice.segcepcmpnum
   #display "segresteldddnum = ",lr_apolice.segresteldddnum
   #display "segrestelnum    = ",lr_apolice.segrestelnum
   #display "adniclhordat    = ",lr_apolice.adniclhordat
   #display "segsgmcod       = ",lr_apolice.segsgmcod
   #display "asiarqvrsnum    = ",lr_apolice.asiarqvrsnum
   #display "pcsseqnum       = ",lr_apolice.pcsseqnum
   #display "succod          = ",lr_apolice.succod
   #display "corsus          = ",lr_apolice.corsus
   #display "vipsegflg       = ",lr_apolice.vipsegflg
   #display "segmaiend       = ",lr_apolice.segmaiend
   #prompt "<ENTER>" for l_prompt

   if lr_apolice.succod is null or
      lr_apolice.succod = 0 then
      #display "sucursal"
      let lr_apolice.succod = 1
   end if

   whenever error continue
      execute p_cty22g03_068 using lr_apolice.*,lr_dados.itaempasicod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao de APOLICE. Tabela <datmitaapl>."
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function  # Fim funcao cty22g03_carrega_tabela_apolice
#========================================================================


#========================================================================
function cty22g03_atualiza_inconsistencia(lr_apolice_atual, lr_arquivo)
#========================================================================
   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
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

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   execute p_cty22g03_073 using lr_apolice_atual.aplseqnum
                               ,lr_arquivo.asiarqvrsnum
                               ,lr_arquivo.pcsseqnum
                               ,lr_arquivo.asiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao atualizar INCONSISTENCIA <datmresitaarqcrgic>. ",
                         "Apolice/Item: ", lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*



#========================================================================
end function  # Fim funcao cty22g03_atualiza_inconsistencia
#========================================================================


#========================================================================
function cty22g03_carrega_inconsistencia(lr_apolice_atual, lr_valida, lr_arquivo)
#========================================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,qtdinconsist     smallint
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

   define lr_inconsistencia record
       asiarqvrsnum     like datmresitaarqcrgic.vrscod
      ,pcsseqnum        like datmresitaarqcrgic.pcmnum
      ,itaasiarqlnhnum  like datmresitaarqcrgic.linnum
      ,icoseqnum        like datmresitaarqcrgic.iconum
      ,asiarqicotipcod  like datmresitaarqcrgic.itaasiarqicotipcod
      ,icocponom        like datmresitaarqcrgic.icocponom
      ,icocpocntdes     like datmresitaarqcrgic.icocpocuddes
      ,ciacod           like datmresitaarqcrgic.itaciacod
      ,ramcod           like datmresitaarqcrgic.itaramcod
      ,aplnum           like datmresitaarqcrgic.aplnum
      ,aplitmnum        like datmresitaarqcrgic.itmnum
      ,libicoflg        like datmresitaarqcrgic.livicoflg
      ,aplseqnum        like datmresitaarqcrgic.aplseqnum
      ,impicoflg        like datmresitaarqcrgic.ipvicoflg
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if

   initialize lr_inconsistencia.* to null
   initialize lr_erro.* to null

   let lr_inconsistencia.asiarqvrsnum     = lr_arquivo.asiarqvrsnum
   let lr_inconsistencia.pcsseqnum        = lr_arquivo.pcsseqnum
   let lr_inconsistencia.itaasiarqlnhnum  = lr_arquivo.asiarqlnhnum
   let lr_inconsistencia.icoseqnum        = 0 # Sera buscado a seguir
   let lr_inconsistencia.asiarqicotipcod  = lr_valida.codigo
   let lr_inconsistencia.icocponom        = lr_valida.campo
   let lr_inconsistencia.icocpocntdes     = lr_valida.valor
   let lr_inconsistencia.ciacod           = lr_apolice_atual.ciacod
   let lr_inconsistencia.ramcod           = lr_apolice_atual.ramcod
   let lr_inconsistencia.aplnum           = lr_apolice_atual.aplnum
   let lr_inconsistencia.aplitmnum        = lr_apolice_atual.aplitmnum
   let lr_inconsistencia.libicoflg        = 'N'
   let lr_inconsistencia.aplseqnum        = lr_apolice_atual.aplseqnum
   let lr_inconsistencia.impicoflg        = 'N' # Inicia como nao impeditiva


   if lr_valida.erro >= 1 then
      let lr_inconsistencia.impicoflg = 'S' # Marca como impeditiva
   end if

   whenever error continue
   open c_cty22g03_064 using lr_arquivo.*
   fetch c_cty22g03_064 into lr_inconsistencia.icoseqnum
   whenever error stop
   close c_cty22g03_064

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar sequencia da INCONSISTENCIA. Tabela <datmresitaarqcrgic>."
      return lr_erro.*
   end if

   if lr_inconsistencia.icocpocntdes is null then
      let lr_inconsistencia.icocpocntdes = '[VAZIO]'
   end if

   #display "VERSAO      : ",lr_inconsistencia.asiarqvrsnum
   #display "PROCESS     : ",lr_inconsistencia.pcsseqnum
   #display "LINHA       : ",lr_inconsistencia.itaasiarqlnhnum
   #display "SEQUENCIA   : ",lr_inconsistencia.icoseqnum
   #display "TIPO INCONS : ",lr_inconsistencia.asiarqicotipcod
   #display "CAMPO       : ",lr_inconsistencia.icocponom
   #display "CONTEUDO    : ",lr_inconsistencia.icocpocntdes
   #display "COMPANHIA   : ",lr_inconsistencia.ciacod
   #display "RAMO        : ",lr_inconsistencia.ramcod
   #display "APOLICE     : ",lr_inconsistencia.aplnum
   #display "ITEM        : ",lr_inconsistencia.aplitmnum
   #display "SEQ         : ",lr_inconsistencia.aplseqnum
   #display "LIBERADO    : ",lr_inconsistencia.libicoflg
   #display "IMPEDITIVA  : ",lr_inconsistencia.impicoflg
   #prompt "<ENTER>" for lr_erro.mens

   whenever error continue
   execute p_cty22g03_065 using lr_inconsistencia.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao inserir INCONSISTENCIA <datmresitaarqcrgic>. ",
                         "Apolice/Item: ", lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped
      return lr_erro.*
   end if
  
   if mr_retorno.processo then
      
      call cty22g03_carrega_relatorio(lr_inconsistencia.pcsseqnum        ,                    
                                      lr_inconsistencia.asiarqvrsnum     ,                     
                                      lr_inconsistencia.asiarqicotipcod  ,      
                                      lr_inconsistencia.ramcod           ,                   
                                      lr_inconsistencia.ciacod           ,              
                                      lr_inconsistencia.itaasiarqlnhnum  ,                    
                                      lr_inconsistencia.icoseqnum        ,                  
                                      lr_inconsistencia.icocponom        ,          
                                      lr_inconsistencia.icocpocntdes     ,          
                                      lr_inconsistencia.aplnum           ,               
                                      lr_inconsistencia.aplitmnum        ,               
                                      lr_inconsistencia.aplseqnum        ,               
                                      lr_inconsistencia.libicoflg        ,               
                                      lr_inconsistencia.impicoflg        )               
    end if
   

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function # Fim da funcao cty22g03_carrega_inconsistencia
#========================================================================

#========================================================================
function cty22g03_desmembra_cgccpf(lr_param)
#========================================================================
   define lr_param record
         tipoPessoa   char(1)
        ,cgccpfnumdig char(20)
   end record

   define lr_retorno record
          cgccpfnum    like datmitaapl.segcgccpfnum
         ,cgcord       like datmitaapl.segcgcordnum
         ,cgccpfdig    like datmitaapl.segcgccpfdig
   end record


   define l_total   integer
   define l_ordem   integer
   define l_digito  integer


   let l_total   = null
   let l_ordem   = null
   let l_digito = null

   initialize lr_retorno.* to null

   let l_total   = length(lr_param.cgccpfnumdig clipped)
   let l_digito  = l_total - 2
   let l_ordem   = l_total - 6

   if lr_param.tipoPessoa = "F" then
      let lr_retorno.cgcord = 0
      let lr_retorno.cgccpfnum = lr_param.cgccpfnumdig[1,l_digito]
      let lr_retorno.cgccpfdig = lr_param.cgccpfnumdig[l_digito+1,l_total]
   else
      let lr_retorno.cgccpfnum = lr_param.cgccpfnumdig[1,l_ordem]
      let lr_retorno.cgccpfdig = lr_param.cgccpfnumdig[l_digito+1,l_total]
      let lr_retorno.cgcord =    lr_param.cgccpfnumdig[l_ordem+1,l_digito]
   end if

  return lr_retorno.*
#========================================================================
end function # Fim da funcao cty22g03_desmembra_cgccpf
#========================================================================

#========================================================================
function cty22g03_trim(l_param)
#========================================================================
   define l_param char(80)
   define l_posi smallint

   let l_posi = 1
   while l_posi <= 80
      if l_param[l_posi] = " " then
         let l_posi =  l_posi + 1
      else
         exit while
      end if
   end while

   let l_param = l_param[l_posi,80]

   return l_param clipped
#========================================================================
end function # Fim da funcao cty22g03_trim
#========================================================================

#========================================================================
function cty22g03_retira_acentos(l_param)
#========================================================================
   define l_param char(100)
   define l_posi  smallint

   let l_posi = 1
   while l_posi <= 100
      case l_param[l_posi]
         when 'б' let l_param[l_posi] = 'a'
         when 'й' let l_param[l_posi] = 'e'
         when 'н' let l_param[l_posi] = 'i'
         when 'у' let l_param[l_posi] = 'o'
         when 'ъ' let l_param[l_posi] = 'u'
         when 'а' let l_param[l_posi] = 'a'
         when 'и' let l_param[l_posi] = 'e'
         when 'м' let l_param[l_posi] = 'i'
         when 'т' let l_param[l_posi] = 'o'
         when 'щ' let l_param[l_posi] = 'u'
         when 'в' let l_param[l_posi] = 'a'
         when 'к' let l_param[l_posi] = 'e'
         when 'о' let l_param[l_posi] = 'i'
         when 'ф' let l_param[l_posi] = 'o'
         when 'ы' let l_param[l_posi] = 'u'
         when 'д' let l_param[l_posi] = 'a'
         when 'л' let l_param[l_posi] = 'e'
         when 'п' let l_param[l_posi] = 'i'
         when 'ц' let l_param[l_posi] = 'o'
         when 'ь' let l_param[l_posi] = 'u'
         when 'г' let l_param[l_posi] = 'a'
         when 'х' let l_param[l_posi] = 'o'
         when 'с' let l_param[l_posi] = 'n'
         when 'з' let l_param[l_posi] = 'c'
         when 'Б' let l_param[l_posi] = 'A'
         when 'Й' let l_param[l_posi] = 'E'
         when 'Н' let l_param[l_posi] = 'I'
         when 'У' let l_param[l_posi] = 'O'
         when 'Ъ' let l_param[l_posi] = 'U'
         when 'А' let l_param[l_posi] = 'A'
         when 'И' let l_param[l_posi] = 'E'
         when 'М' let l_param[l_posi] = 'I'
         when 'Т' let l_param[l_posi] = 'O'
         when 'Щ' let l_param[l_posi] = 'U'
         when 'В' let l_param[l_posi] = 'A'
         when 'К' let l_param[l_posi] = 'E'
         when 'О' let l_param[l_posi] = 'I'
         when 'Ф' let l_param[l_posi] = 'O'
         when 'Ы' let l_param[l_posi] = 'U'
         when 'Д' let l_param[l_posi] = 'A'
         when 'Л' let l_param[l_posi] = 'E'
         when 'П' let l_param[l_posi] = 'I'
         when 'Ц' let l_param[l_posi] = 'O'
         when 'Ь' let l_param[l_posi] = 'U'
         when 'Г' let l_param[l_posi] = 'A'
         when 'Х' let l_param[l_posi] = 'O'
         when 'С' let l_param[l_posi] = 'N'
         when 'З' let l_param[l_posi] = 'C'
      end case
      let l_posi = l_posi + 1
   end while

   return l_param clipped

#========================================================================
end function # Fim da funcao cty22g03_retira_acentos
#========================================================================

#=================================================================
function cty22g03_carrega_Atualizacao(lr_apolice_atual, lr_dados,lr_hist_process)
#=================================================================

   define lr_apolice_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
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

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

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


     define lr_apol_atual record
       ciacod           like datmresitaapl.itaciacod
      ,ramcod           like datmresitaapl.itaramcod
      ,aplnum           like datmresitaapl.aplnum
      ,aplseqnum        like datmresitaapl.aplseqnum
      ,prpnum           like datmresitaapl.prpnum
      ,aplvigincdat     like datmresitaapl.incvigdat
      ,aplvigfnldat     like datmresitaapl.fnlvigdat
      ,segnom           like datmresitaapl.segnom
      ,pestipcod        like datmresitaapl.pestipcod
      ,segcgccpfnum     like datmresitaapl.segcpjcpfnum
      ,segcgcordnum     like datmresitaapl.cpjordnum
      ,segcgccpfdig     like datmresitaapl.cpjcpfdignum
      ,seglgdnom        like datmresitaapl.seglgdnom
      ,seglgdnum        like datmresitaapl.seglgdnum
      ,segendcmpdes     like datmresitaapl.seglcacpldes
      ,segbrrnom        like datmresitaapl.brrnom
      ,segcidnom        like datmresitaapl.segcidnom
      ,segufdsgl        like datmresitaapl.estsgl
      ,segcepnum        like datmresitaapl.cepcod
      ,segcepcmpnum     like datmresitaapl.cepcplcod
      ,segresteldddnum  like datmresitaapl.dddcod
      ,segrestelnum     like datmresitaapl.telnum
      ,adniclhordat     like datmresitaapl.adnicldat
      ,segsgmcod        like datmresitaapl.sgmcod
      ,asiarqvrsnum     like datmresitaapl.vrsnum
      ,pcsseqnum        like datmresitaapl.pcmnum
      ,succod           like datmresitaapl.succod
      ,corsus           like datmresitaapl.suscod
      ,vipsegflg        like datmresitaapl.eslsegflg
      ,segmaiend        like datmresitaapl.segemanom
   end record

   define lr_item_atual record
       ciacod           like datmresitaaplitm.itaciacod
      ,ramcod           like datmresitaaplitm.itaramcod
      ,aplnum           like datmresitaaplitm.aplnum
      ,aplseqnum        like datmresitaaplitm.aplseqnum
      ,aplitmnum        like datmresitaaplitm.aplitmnum
      ,aplitmsttcod     like datmresitaaplitm.itmsttcod
      ,itaprdcod        like datmresitaaplitm.prdcod
      ,itaplncod        like datmresitaaplitm.plncod
      ,itaempasicod     like datmresitaaplitm.empcod
      ,itaasisrvcod     like datmresitaaplitm.srvcod
      ,itacobsegcod     like datmresitaaplitm.rscsegcbttipcod
      ,itaressegcod     like datmresitaaplitm.rscsegrestipcod
      ,itamrdsegcod     like datmresitaaplitm.rscsegimvtipcod
      ,rsclcllgdnom     like datmresitaaplitm.rsclgdnom
      ,rsclcllgdnum     like datmresitaaplitm.rsclgdnum
      ,rsclclendcmpdes  like datmresitaaplitm.rsccpldes
      ,rsclclbrrnom     like datmresitaaplitm.rscbrrnom
      ,rsclclcidnom     like datmresitaaplitm.rsccidnom
      ,rsclclufdsgl     like datmresitaaplitm.rscestsgl
      ,rsclclcepnum     like datmresitaaplitm.rsccepcod
      ,rsclclcepcmpnum  like datmresitaaplitm.rsccepcplcod

   end record

   define lr_cgccpf record
       tipoPessoa   char(1)
      ,cgccpfnumdig char(20)
   end record

   define lr_sucursal    record
      inpcod            like gcaksusep.inpcod
     ,succod            smallint #like pcgksuc.succod
     ,msgerr            char(78)
   end record

   define l_data_hora char(20)
   define l_dt_ini  char(10)
   define l_dt_fin  char(10)


   define incvig date
   define finvig date


   initialize lr_erro.* to null
   initialize lr_item_atual.* to null
   initialize lr_apol_atual.* to null


   if m_prepare is null or
      m_prepare = false then
      call cty22g03_prepare()
   end if



   # Recupera a ultima sequencia da apolice a ser Atualizada
   whenever error continue
   open c_cty22g03_075 using lr_apolice_atual.ciacod
                            ,lr_apolice_atual.ramcod
                            ,lr_apolice_atual.aplnum
   fetch c_cty22g03_075 into lr_apolice_atual.aplseqnum
   whenever error stop
   close c_cty22g03_075

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na recuperacao da sequencial atual CANCELAMENTO. Tabela: <datmitaapl>."
      return lr_erro.*, 0
   end if

   if lr_apolice_atual.aplseqnum is null then
      # Ignora os casos que nгo foram encontrados

      let lr_erro.sqlcode = 0
      return lr_erro.*, 0
   end if

   # Cria nova sequencia copiando os dados de apolice da sequencia anterior
   whenever error continue
   execute p_cty22g03_076 using lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no Atualizada da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   # Atualiza o numero de processamento da apolice
   whenever error continue
   execute p_cty22g03_077 using lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
                               ,lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na Atualizacao do processamento da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   # Cria nova sequencia copiando os dados do item da sequencia anterior
   whenever error continue
   execute p_cty22g03_078 using lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no Atualizacao do item da apolice (1). Tabela <datmitaaplitm>."
      return lr_erro.*, 0
   end if

   # Buscar flag de VIP e Endereco de E-mail da apolice quando for atualizacao
   # Considero apenas acima de 1 pois o primeiro sequencial significa que eh apolice nova
   if lr_apolice_atual.aplseqnum > 1 then

      whenever error continue
      open c_cty22g03_072 using lr_apolice_atual.ciacod,
                                lr_apolice_atual.ramcod,
                                lr_apolice_atual.aplnum,
                                lr_apolice_atual.aplseqnum
      fetch c_cty22g03_072 into lr_apol_atual.vipsegflg,
                                lr_apol_atual.segmaiend
      whenever error stop
      close c_cty22g03_072

      if sqlca.sqlcode <> 0 then # Ignora se der erro e assume os valores padrao
         let lr_apol_atual.vipsegflg = "N"
         let lr_apol_atual.segmaiend = " "
      end if
   end if

   let lr_apol_atual.segcepnum         = lr_dados.segcepnum[1,5]
   let lr_apol_atual.segcepcmpnum      = lr_dados.segcepnum[6,8]
   let lr_item_atual.rsclclcepnum      = lr_dados.rsclclcepnum[1,5]
   let lr_item_atual.rsclclcepcmpnum   = lr_dados.rsclclcepnum[6,8]


   # Trata CEP
   if lr_apol_atual.segcepnum is null then
      let lr_apol_atual.segcepnum = 0
   end if

   if lr_apol_atual.segcepcmpnum is null then
      let lr_apol_atual.segcepcmpnum = 0
   end if

   if lr_item_atual.rsclclcepnum is null then
      let lr_item_atual.rsclclcepnum  = 0
   end if

   if lr_item_atual.rsclclcepcmpnum is null then
      let lr_item_atual.rsclclcepcmpnum  = 0
   end if

   # Quebra CPF/CNPJ
   let lr_cgccpf.tipoPessoa = lr_dados.pestipcod
   let lr_cgccpf.cgccpfnumdig = lr_dados.segcgccpfnum

   call cty22g03_desmembra_cgccpf(lr_cgccpf.*)
   returning lr_apol_atual.segcgccpfnum
            ,lr_apol_atual.segcgcordnum
            ,lr_apol_atual.segcgccpfdig


   # Busca codigo da sucursal a partir da SUSEP do corretor
   call fpcgc052_suc_susep(lr_dados.corsus)
   returning lr_sucursal.inpcod
            ,lr_sucursal.succod
            ,lr_sucursal.msgerr

   if lr_sucursal.succod is not null and
      lr_sucursal.succod > 0 then
      let lr_apol_atual.succod = lr_sucursal.succod
   end if

   whenever error continue
    open c_cty22g03_093 using lr_dados.asisrvcod
    fetch c_cty22g03_093 into lr_item_atual.itaasisrvcod
   whenever error stop


   let l_data_hora = lr_dados.adniclhordat[1,2],"-",lr_dados.adniclhordat[3,4], "-",lr_dados.adniclhordat[5,8]
   let l_data_hora = l_data_hora clipped

   let l_dt_ini = lr_dados.aplvigincdat[1,2],"-",lr_dados.aplvigincdat[3,4], "-",lr_dados.aplvigincdat[5,8]
   let l_dt_ini = l_dt_ini clipped

   let l_dt_fin = lr_dados.aplvigfnldat[1,2],"-",lr_dados.aplvigfnldat[3,4], "-",lr_dados.aplvigfnldat[5,8]
   let l_dt_fin = l_dt_fin clipped


   let lr_apol_atual.prpnum           = lr_dados.prpnum
   let lr_apol_atual.aplvigincdat     = l_dt_ini #lr_dados.aplvigincdat clipped
   let lr_apol_atual.aplvigfnldat     = l_dt_fin #lr_dados.aplvigfnldat clipped
   let lr_apol_atual.segnom           = lr_dados.segnom
   let lr_apol_atual.pestipcod        = lr_dados.pestipcod
   let lr_apol_atual.seglgdnom        = lr_dados.seglgdnom
   let lr_apol_atual.seglgdnum        = lr_dados.seglgdnum
   let lr_apol_atual.segendcmpdes     = lr_dados.segendcmpdes
   let lr_apol_atual.segbrrnom        = lr_dados.segbrrnom
   let lr_apol_atual.segcidnom        = lr_dados.segcidnom
   let lr_apol_atual.segufdsgl        = lr_dados.segufdsgl
   let lr_apol_atual.segresteldddnum  = lr_dados.segresteldddnum
   let lr_apol_atual.segrestelnum     = lr_dados.segrestelnum
   let lr_apol_atual.adniclhordat     = l_data_hora
   let lr_apol_atual.segsgmcod        = lr_dados.itasegtipcod
   let lr_apol_atual.corsus           = lr_dados.corsus
   let lr_item_atual.aplitmsttcod     = lr_dados.mvtsttcod
   let lr_item_atual.itaprdcod        = lr_dados.prdcod
   let lr_item_atual.itaplncod        = lr_dados.plncod
   let lr_item_atual.itaempasicod     = lr_dados.empasicod
   let lr_item_atual.itacobsegcod     = lr_dados.itacobsegcod
   let lr_item_atual.itaressegcod     = lr_dados.itaressegcod
   let lr_item_atual.itamrdsegcod     = lr_dados.itamrdsegcod
   let lr_item_atual.rsclcllgdnom     = lr_dados.rsclcllgdnom
   let lr_item_atual.rsclcllgdnum     = lr_dados.rsclcllgdnum
   let lr_item_atual.rsclclendcmpdes  = lr_dados.rsclclendcmpdes
   let lr_item_atual.rsclclbrrnom     = lr_dados.rsclclbrrnom
   let lr_item_atual.rsclclcidnom     = lr_dados.rsclclcidnom
   let lr_item_atual.rsclclufdsgl     = lr_dados.rsclclufdsgl


   whenever error continue
   execute p_cty22g03_094 using lr_apol_atual.prpnum
                               ,lr_apol_atual.aplvigincdat
                               ,lr_apol_atual.aplvigfnldat
                               ,lr_apol_atual.segnom
                               ,lr_apol_atual.pestipcod
                               ,lr_apol_atual.segcgccpfnum
                               ,lr_apol_atual.segcgcordnum
                               ,lr_apol_atual.segcgccpfdig
                               ,lr_apol_atual.seglgdnom
                               ,lr_apol_atual.seglgdnum
                               ,lr_apol_atual.segendcmpdes
                               ,lr_apol_atual.segbrrnom
                               ,lr_apol_atual.segcidnom
                               ,lr_apol_atual.segufdsgl
                               ,lr_apol_atual.segcepnum
                               ,lr_apol_atual.segcepcmpnum
                               ,lr_apol_atual.segresteldddnum
                               ,lr_apol_atual.segrestelnum
                               ,lr_apol_atual.adniclhordat
                               ,lr_apol_atual.segsgmcod
                               ,lr_hist_process.asiarqvrsnum
                               ,lr_hist_process.pcsseqnum
                               ,lr_apol_atual.succod
                               ,lr_apol_atual.corsus
                               ,lr_apol_atual.vipsegflg
                               ,lr_apol_atual.segmaiend
                               ,lr_apol_atual.ciacod
                               ,lr_apol_atual.ramcod
                               ,lr_apol_atual.aplnum
                               ,lr_apol_atual.aplseqnum

   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no ATUALIZACAO da apolice. Tabela <datmitaapl>."
      call errorlog(lr_erro.mens)
      return lr_erro.*,0
   end if

   whenever error continue
   execute p_cty22g03_095 using lr_item_atual.aplitmsttcod
                               ,lr_item_atual.itaprdcod
                               ,lr_item_atual.itaplncod
                               ,lr_item_atual.itaempasicod
                               ,lr_item_atual.itaasisrvcod
                               ,lr_item_atual.itacobsegcod
                               ,lr_item_atual.itaressegcod
                               ,lr_item_atual.itamrdsegcod
                               ,lr_item_atual.rsclcllgdnom
                               ,lr_item_atual.rsclcllgdnum
                               ,lr_item_atual.rsclclendcmpdes
                               ,lr_item_atual.rsclclbrrnom
                               ,lr_item_atual.rsclclcidnom
                               ,lr_item_atual.rsclclufdsgl
                               ,lr_item_atual.rsclclcepnum
                               ,lr_item_atual.rsclclcepcmpnum
                               ,lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
                               ,lr_apolice_atual.aplitmnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") no Atualizacao do item da apolice (3). Tabela <datmitaaplitm>."
      call errorlog(lr_erro.mens)
      return lr_erro.*,0
   end if

   #end if

   # Soma 1 pois o cancelamento do item X gera a sequencia X+1
   let lr_apolice_atual.aplseqnum = lr_apolice_atual.aplseqnum + 1

   return lr_erro.*,lr_apolice_atual.aplseqnum

#=================================================================
end function # Fim da Funзгo
#=================================================================

#========================================================================
function cty22g03_cria_arquivos(lr_param)
#========================================================================
 
define lr_param record
	vrscod 	 like datmresitaarqdet.vrscod     
end record	  

  
  initialize mr_retorno.* to null
  let mr_retorno.flg_arq1 = false
  let mr_retorno.flg_arq2 = false 
  let mr_retorno.processo = true    
  
  call f_path("DAT", "RELATO")
  returning mr_retorno.diretorio
  
  let mr_retorno.arquivo1 = mr_retorno.diretorio clipped, "/Impeditivas_", lr_param.vrscod using '&&&&&&', ".xls"
  let mr_retorno.arquivo2 = mr_retorno.diretorio clipped, "/naoImpeditivas_",lr_param.vrscod using '&&&&&&', ".xls"
  
  start report  rep1_cty22g03  to mr_retorno.arquivo1
  start report  rep2_cty22g03  to mr_retorno.arquivo2
  
  
#========================================================================
end function # Fim da funcao cty22g03_cria_arquivos
#========================================================================

#========================================================================
report rep1_cty22g03(lr_param)
#========================================================================

define lr_param record
   pcmnum                 like datmresitaarqcrgic.pcmnum              ,   
   vrscod                 like datmresitaarqcrgic.vrscod              ,
   itaasiarqicotipcod     like datmresitaarqcrgic.itaasiarqicotipcod  ,
   itaramcod              like datmresitaarqcrgic.itaramcod           ,
   itaciacod              like datmresitaarqcrgic.itaciacod           ,
   linnum                 like datmresitaarqcrgic.linnum              ,
   iconum                 like datmresitaarqcrgic.iconum              ,
   icocponom              like datmresitaarqcrgic.icocponom           ,
   icocpocuddes           like datmresitaarqcrgic.icocpocuddes        ,
   aplnum                 like datmresitaarqcrgic.aplnum              ,
   itmnum                 like datmresitaarqcrgic.itmnum              ,
   aplseqnum              like datmresitaarqcrgic.aplseqnum           ,
   livicoflg              like datmresitaarqcrgic.livicoflg           ,
   coluna                 char(30)       
end record

		 output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan=17 align='center'>RELATORIO DE INCONSISTENCIAS IMPEDITIVAS - REFERENTE A DATA DE (",today,") </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>VERSAO</th>"
		             ,"<th align='center' bgcolor='gray'>PROCESSO</th>"
		             ,"<th align='center' bgcolor='gray'>LINHA</th>"
                 ,"<th align='center' bgcolor='gray'>SEQUENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>TIPO DE INCONSISTENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>CAMPO</th>"
                 ,"<th align='center' bgcolor='gray'>CONTEUDO</th>"   
                 ,"<th align='center' bgcolor='gray'>POSICAO ARQUIVO</th>"   
                 ,"<th align='center' bgcolor='gray'>COMPANHIA</th>"
                 ,"<th align='center' bgcolor='gray'>RAMO</th>"
                 ,"<th align='center' bgcolor='gray'>APOLICE</th>"
                 ,"<th align='center' bgcolor='gray'>ITEM</th>"
                 ,"<th align='center' bgcolor='gray'>SEQUENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>LIBERADO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",lr_param.vrscod             , "</td>"                              
		              ,"<td width=80 align='center'>",lr_param.pcmnum             , "</td>"                           
		              ,"<td width=80 align='center'>",lr_param.linnum             , "</td>"                 
		              ,"<td width=80 align='center'>",lr_param.iconum             , "</td>"                       
		              ,"<td width=80 align='center'>",lr_param.itaasiarqicotipcod , "</td>"                   
		              ,"<td width=80 align='center'>",lr_param.icocponom          , "</td>"                        
		              ,"<td width=80 align='center'>",lr_param.icocpocuddes       , "</td>" 
		              ,"<td width=80 align='center'>",lr_param.coluna             , "</td>"                                    
		              ,"<td width=80 align='center'>",lr_param.itaciacod          , "</td>"                        
		              ,"<td width=80 align='center'>",lr_param.itaramcod          , "</td>"                     
		              ,"<td width=80 align='center'>",lr_param.aplnum             , "</td>"                            
		              ,"<td width=80 align='center'>",lr_param.itmnum             , "</td>"                           
		              ,"<td width=80 align='center'>",lr_param.aplseqnum          , "</td>"                  
		              ,"<td width=80 align='center'>",lr_param.livicoflg          , "</td></tr>" 
		              
		     let mr_retorno.flg_arq1 = true        
        
#========================================================================
end report
#========================================================================  

#========================================================================
report rep2_cty22g03(lr_param)
#========================================================================

define lr_param record
   pcmnum                 like datmresitaarqcrgic.pcmnum              ,   
   vrscod                 like datmresitaarqcrgic.vrscod              ,
   itaasiarqicotipcod     like datmresitaarqcrgic.itaasiarqicotipcod  ,
   itaramcod              like datmresitaarqcrgic.itaramcod           ,
   itaciacod              like datmresitaarqcrgic.itaciacod           ,
   linnum                 like datmresitaarqcrgic.linnum              ,
   iconum                 like datmresitaarqcrgic.iconum              ,
   icocponom              like datmresitaarqcrgic.icocponom           ,
   icocpocuddes           like datmresitaarqcrgic.icocpocuddes        ,
   aplnum                 like datmresitaarqcrgic.aplnum              ,
   itmnum                 like datmresitaarqcrgic.itmnum              ,
   aplseqnum              like datmresitaarqcrgic.aplseqnum           ,
   livicoflg              like datmresitaarqcrgic.livicoflg           ,
   coluna                 char(30)      
end record

		 output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan=17 align='center'>RELATORIO DE INCONSISTENCIAS NAO IMPEDITIVAS - REFERENTE A DATA DE (",today,") </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>VERSAO</th>"
		             ,"<th align='center' bgcolor='gray'>PROCESSO</th>"
		             ,"<th align='center' bgcolor='gray'>LINHA</th>"
                 ,"<th align='center' bgcolor='gray'>SEQUENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>TIPO DE INCONSISTENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>CAMPO</th>"
                 ,"<th align='center' bgcolor='gray'>CONTEUDO</th>"
                 ,"<th align='center' bgcolor='gray'>POSICAO ARQUIVO</th>"   
                 ,"<th align='center' bgcolor='gray'>COMPANHIA</th>"
                 ,"<th align='center' bgcolor='gray'>RAMO</th>"
                 ,"<th align='center' bgcolor='gray'>APOLICE</th>"
                 ,"<th align='center' bgcolor='gray'>ITEM</th>"
                 ,"<th align='center' bgcolor='gray'>SEQUENCIA</th>"
                 ,"<th align='center' bgcolor='gray'>LIBERADO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",lr_param.vrscod             , "</td>"                              
		              ,"<td width=80 align='center'>",lr_param.pcmnum             , "</td>"                           
		              ,"<td width=80 align='center'>",lr_param.linnum             , "</td>"                 
		              ,"<td width=80 align='center'>",lr_param.iconum             , "</td>"                       
		              ,"<td width=80 align='center'>",lr_param.itaasiarqicotipcod , "</td>"                   
		              ,"<td width=80 align='center'>",lr_param.icocponom          , "</td>"                        
		              ,"<td width=80 align='center'>",lr_param.icocpocuddes       , "</td>" 
		              ,"<td width=80 align='center'>",lr_param.coluna             , "</td>"                                 
		              ,"<td width=80 align='center'>",lr_param.itaciacod          , "</td>"                        
		              ,"<td width=80 align='center'>",lr_param.itaramcod          , "</td>"                     
		              ,"<td width=80 align='center'>",lr_param.aplnum             , "</td>"                            
		              ,"<td width=80 align='center'>",lr_param.itmnum             , "</td>"                           
		              ,"<td width=80 align='center'>",lr_param.aplseqnum          , "</td>"                  
		              ,"<td width=80 align='center'>",lr_param.livicoflg          , "</td></tr>"   
		              
		     let mr_retorno.flg_arq2 = true          

#========================================================================
end report
#======================================================================== 

#========================================================================
function cty22g03_carrega_relatorio(lr_param)
#========================================================================

define lr_param record
   pcmnum                 like datmresitaarqcrgic.pcmnum              ,   
   vrscod                 like datmresitaarqcrgic.vrscod              ,
   itaasiarqicotipcod     like datmresitaarqcrgic.itaasiarqicotipcod  ,
   itaramcod              like datmresitaarqcrgic.itaramcod           ,
   itaciacod              like datmresitaarqcrgic.itaciacod           ,
   linnum                 like datmresitaarqcrgic.linnum              ,
   iconum                 like datmresitaarqcrgic.iconum              ,
   icocponom              like datmresitaarqcrgic.icocponom           ,
   icocpocuddes           like datmresitaarqcrgic.icocpocuddes        ,
   aplnum                 like datmresitaarqcrgic.aplnum              ,
   itmnum                 like datmresitaarqcrgic.itmnum              ,
   aplseqnum              like datmresitaarqcrgic.aplseqnum           ,
   livicoflg              like datmresitaarqcrgic.livicoflg           ,
   ipvicoflg              like datmresitaarqcrgic.ipvicoflg             
end record

define lr_retorno record        
  coluna char(30)               
end record                      
                                
initialize lr_retorno.* to null
 
   
   call cty22g03_carrega_coluna(lr_param.icocponom)
   returning lr_retorno.coluna
      
   case lr_param.ipvicoflg
   	 when "S"
   	 	  output to report rep1_cty22g03(lr_param.pcmnum             ,   
                                       lr_param.vrscod             , 
                                       lr_param.itaasiarqicotipcod , 
                                       lr_param.itaramcod          , 
                                       lr_param.itaciacod          , 
                                       lr_param.linnum             , 
                                       lr_param.iconum             , 
                                       lr_param.icocponom          , 
                                       lr_param.icocpocuddes       , 
                                       lr_param.aplnum             , 
                                       lr_param.itmnum             , 
                                       lr_param.aplseqnum          , 
                                       lr_param.livicoflg          ,
                                       lr_retorno.coluna           )    
      when "N"                                                                                             
      	  output to report rep2_cty22g03(lr_param.pcmnum             ,                                     
                                         lr_param.vrscod             ,                                      
                                         lr_param.itaasiarqicotipcod ,                                      
                                         lr_param.itaramcod          ,                                      
                                         lr_param.itaciacod          ,                                      
                                         lr_param.linnum             ,                                      
                                         lr_param.iconum             ,                                      
                                         lr_param.icocponom          ,                                      
                                         lr_param.icocpocuddes       ,                                      
                                         lr_param.aplnum             ,                                      
                                         lr_param.itmnum             ,                                      
                                         lr_param.aplseqnum          ,                                      
                                         lr_param.livicoflg          ,
                                         lr_retorno.coluna           )                                      
   end case                                  
                                       
                                        
#========================================================================
end function # Fim da funcao cty22g03_carrega_relatorio
#======================================================================== 

#========================================================================           
function cty22g03_finaliza_relatorio()                                                   
#========================================================================                                                                               
                                                                                        
   finish report  rep1_cty22g03   
   finish report  rep2_cty22g03
   
   let mr_retorno.processo = false                                                                                    
                                                                                                             
#========================================================================           
end function # Fim da funcao cty22g03_finaliza_relatorio                               
#========================================================================  

#========================================================================                                                      
function cty22g03_carrega_coluna(lr_param)                                                                             
#========================================================================                                             

define lr_param record                                                                                                                      
  icocponom  like datmresitaarqcrgic.icocponom                                                                   
end record 

define lr_retorno record                            
  coluna char(30)                                                           
end record 

initialize lr_retorno.* to null

   case lr_param.icocponom 
   	 when "NUMERO DO CPF/CNPJ (segcgccpfnum)"
   	 	  let lr_retorno.coluna = "Coluna[105,124]"   
   	 when "CIA, RAMO, APOL, ITEM"       	  
   	 	  let lr_retorno.coluna = "Coluna[1,24]"   	  
   	 when "CODIGO DA COMPANHIA (itaciacod)"       	      
   	 	  let lr_retorno.coluna = "Coluna[1,2]"	  
   	 when "CODIGO DA EMPRESA (itaempasicod)"       	    	  
   	 	  let lr_retorno.coluna = "Coluna[53,55]"	  
   	 when "CODIGO DO PLANO (plncod)"       	    
   	 	  let lr_retorno.coluna = "Coluna[51,52]"	  
   	 when "CODIGO DO PRODUTO (itaprdcod)"      	                    
   	 	  let lr_retorno.coluna = "Coluna[47,50]"	   	  
   	 when "CODIGO DO RAMO (itaramcod)"     	  
   	 	  let lr_retorno.coluna = "Coluna[3,5]"	 	  
   	 when "SEGMENTO DO CLIENTE (itasgmcod)"       	     	  
   	 	  let lr_retorno.coluna = "Coluna[505,506]"	
   	 when "CODIGO DO SERVICO PRESTADO (itaasisrvcod)"       	  
   	 	  let lr_retorno.coluna = "Coluna[56,58]"		   	     	 	  
   end case	
   
   return lr_retorno.coluna  	                                                                                                                                          
                                                                                                                      
#========================================================================                                             
end function # Fim da funcao cty22g03_carrega_coluna                                                                   
#========================================================================  

#========================================================================                                             
function cty22g03_recupera_arquivos()                                      
#========================================================================  
                                                                           
                                                                           
  return mr_retorno.arquivo1,                                              
         mr_retorno.arquivo2,                                              
         mr_retorno.flg_arq1,                                              
         mr_retorno.flg_arq2                                               
                                                                           
#========================================================================  
end function # Fim da funcao cty22g03_cria_arquivos                        
#======================================================================== 

#========================================================================       
function cty22g03_acerta_servico_prestado(lr_param)                                          
#========================================================================      
                                                                               
define lr_param record
   asisrvcod    like datmresitaarqdet.srvcod ,
   itaressegcod like datmresitaaplitm.rscsegrestipcod   
end record

define lr_retorno record                            
  asisrvcod like datmresitaarqdet.srvcod                                                           
end record 

initialize lr_retorno.* to null 

    let lr_retorno.asisrvcod = lr_param.asisrvcod   


    if lr_param.asisrvcod = 'AC' then 
    	
    	if lr_param.itaressegcod = 2 then       
    		  let lr_retorno.asisrvcod = 'PAP'      
    	else                                 
    	    let lr_retorno.asisrvcod = 'PLC'       
    	end if	                             

    end if

                                                                            
    return lr_retorno.asisrvcod                                          
                                                                               
#========================================================================      
end function # Fim da funcao cty22g03_cria_arquivos                            
#========================================================================      