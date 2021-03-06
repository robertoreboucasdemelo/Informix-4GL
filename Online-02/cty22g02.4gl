#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cty22g02                                                  #
# Objetivo.......: Funcoes Itau                                              #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Marcos Goes                                               #
# Liberacao      : 07/06/2011                                                #
#                : 24/11/2014 Alberto - liberacao pelo RTC                   #
#............................................................................#
#............................................................................#
database porto

#globals "/fontes/controle_ct24h/ct24h_geral/glct.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint

define mr_retorno record
	diretorio char(100) ,
  arquivo1  char(100) ,
  arquivo2  char(100) ,
  flg_arq1  smallint  ,
  flg_arq2  smallint  ,
  processo  smallint
end record

#------------------------------------------------------------------------------
function cty22g02_prepare()
#------------------------------------------------------------------------------

define l_sql char(2000)

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitaaplcanmtv ",
               "WHERE itaaplcanmtvcod = ? "
   prepare p_cty22g02_051 from l_sql
   declare c_cty22g02_051 cursor with hold for p_cty22g02_051


   let l_sql = "UPDATE datmitaasiarqico ",
               "SET libicoflg = 'S' ",
               "   ,icolibdat = today ",
               "   ,icolibusrtip = ? ",
               "   ,icolibemp = ? ",
               "   ,icolibmat = ? ",
               "WHERE itaaplnum = ? ",
               "AND   libicoflg = 'N' ",
               "AND   impicoflg = 'S' "
   prepare p_cty22g02_052 from l_sql

   let l_sql = "UPDATE datmitaasiarqico ",
               "SET libicoflg = 'S' ",
               "   ,icolibdat = today ",
               "   ,icolibusrtip = ? ",
               "   ,icolibemp    = ? ",
               "   ,icolibmat    = ? ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   pcsseqnum       = ? ",
               "AND   itaasiarqlnhnum = ? ",
               "AND   libicoflg = 'N' ",
               "AND   impicoflg = 'N' "
   prepare p_cty22g02_052b from l_sql

   let l_sql = "SELECT count(*) ",
               "FROM datmitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? ",
               "AND   itaaplitmnum = ? "
   prepare p_cty22g02_053 from l_sql
   declare c_cty22g02_053 cursor with hold for p_cty22g02_053

   let l_sql = "select count(*) from datkitacia ",
              " where itaciacod = ? "
   prepare p_cty22g02_054 from l_sql
   declare c_cty22g02_054 cursor with hold for p_cty22g02_054

   let l_sql = "SELECT itaclisgmcod ",
               "FROM datkitaclisgm ",
               "WHERE itasgmcod = ? "
   prepare p_cty22g02_055 from l_sql
   declare c_cty22g02_055 cursor with hold for p_cty22g02_055

   let l_sql = "select count(*) from datkitaprd ",
              " where itaprdcod = ? "
   prepare p_cty22g02_056 from l_sql
   declare c_cty22g02_056 cursor with hold for p_cty22g02_056

   let l_sql = "select count(*) from datkitasgrpln ",
              " where itasgrplncod = ? "
   prepare p_cty22g02_057 from l_sql
   declare c_cty22g02_057 cursor with hold for p_cty22g02_057

   let l_sql = "select count(*) from datkitaempasi ",
              " where itaempasicod = ? "
   prepare p_cty22g02_058 from l_sql
   declare c_cty22g02_058 cursor with hold for p_cty22g02_058

   let l_sql = "SELECT itavclcrgtipcod ",
               "FROM datkitavclcrgtip ",
               "WHERE itavclcrgtipdes = ? "
   prepare p_cty22g02_059 from l_sql
   declare c_cty22g02_059 cursor with hold for p_cty22g02_059

   let l_sql = "SELECT itacliscocod ",
               "FROM datkitaclisco ",
               "WHERE UPPER(itacliscodes) = ? "
   prepare p_cty22g02_060 from l_sql
   declare c_cty22g02_060 cursor with hold for p_cty22g02_060

   let l_sql = "SELECT COUNT(*) ",
               "FROM datmitaasiarqico ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   libicoflg = 'N' ",  #nao liberadas
               "AND   impicoflg = 'S' ",  #impeditivas
               "AND   itaasiarqvrsnum <> ? "
   prepare p_cty22g02_061 from l_sql
   declare c_cty22g02_061 cursor with hold for p_cty22g02_061

   let l_sql = "select NVL(MAX(pcsseqnum),0)+1 ",
               " from datmitaarqpcshst ",
               " where itaasiarqvrsnum = ? "
   prepare p_cty22g02_062 from l_sql
   declare c_cty22g02_062 cursor with hold for p_cty22g02_062

   let l_sql = "insert into datmitaarqpcshst ",
               "(itaasiarqvrsnum, pcsseqnum, arqpcsinchordat, ",
               " arqpcsfnlhordat, lnhtotqtd, pcslnhqtd, fnzpcsflg) ",
               "values (?, ?, current, NULL, ?, 0, 'N')"
   prepare p_cty22g02_063 from l_sql


   let l_sql = "SELECT NVL(MAX(icoseqnum),0)+1 ",
               "FROM datmitaasiarqico ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND pcsseqnum = ? ",
               "AND itaasiarqlnhnum = ? "
   prepare p_cty22g02_064 from l_sql
   declare c_cty22g02_064 cursor with hold for p_cty22g02_064

   let l_sql = "INSERT INTO datmitaasiarqico ",
               "(itaasiarqvrsnum,pcsseqnum,itaasiarqlnhnum,icoseqnum, ",
               "itaasiarqicotipcod,icocponom,icocpocntdes,itaciacod, ",
               "itaramcod,itaaplnum,itaaplitmnum,libicoflg,aplseqnum, ",
               "impicoflg) ",
               "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_cty22g02_065 from l_sql

   let l_sql = "SELECT COUNT(*) FROM datmdetitaasiarq ",
               "WHERE itaasiarqvrsnum = ? "
   prepare p_cty22g02_066 from l_sql
   declare c_cty22g02_066 cursor with hold for p_cty22g02_066

   let l_sql = "SELECT NVL(MAX(aplseqnum),0) + 1 ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? "
   prepare p_cty22g02_067 from l_sql
   declare c_cty22g02_067 cursor with hold for p_cty22g02_067

   let l_sql = "insert into datmitaapl ",
               "(itaciacod,itaramcod,itaaplnum,aplseqnum,itaprpnum, ",
               " itaaplvigincdat,itaaplvigfnldat,segnom,pestipcod, ",
               " segcgccpfnum,segcgcordnum,segcgccpfdig,itaprdcod, ",
               " itacliscocod,itacorsuscod, ",
               " seglgdnom,seglgdnum,segendcmpdes,segbrrnom,segcidnom,segufdsgl, ",
               " segcepnum,segcepcmpnum,segresteldddnum,segrestelnum, ",
               " adniclhordat,itaasiarqvrsnum,pcsseqnum,succod,corsus, ",
               " vipsegflg,segmaiend,frtmdlcod,vndcnlcod) ",
               "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?, ",
               " ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_cty22g02_068 from l_sql


   let l_sql = "insert into datmitaaplitm ",
               "(itaciacod,itaramcod,itaaplnum,aplseqnum,itaaplitmnum, ",
               " itaaplitmsttcod,autchsnum,autplcnum,autfbrnom,autlnhnom, ",
               " autmodnom,itavclcrgtipcod,autfbrano,autmodano,autcmbnom, ",
               " autcornom,autpintipdes,okmflg,impautflg,casfrqvlr, ",
               " rsclclcepnum,rcslclcepcmpnum,porvclcod, ",
               " itaasisrvcod,itarsrcaosrvcod,rsrcaogrtcod,ubbcod,itasgrplncod, ",
               " itaempasicod,asiincdat,itaaplcanmtvcod,itaclisgmcod, ",
               " vcltipcod,bldflg ) ",
               "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,",
               "        ?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_cty22g02_069 from l_sql

{
   let l_sql = "SELECT NVL(MAX(itaasiarqvrsnum),0)+1 ",
               "FROM datmhdritaasiarq"
   prepare p_cty22g02_070 from l_sql
   declare c_cty22g02_070 cursor with hold for p_cty22g02_070

   let l_sql = "INSERT INTO datmhdritaasiarq ",
               "(itaasiarqvrsnum, mvtdat, arqgerinchordat, prsnom) ",
               "VALUES (?,?,?,?) "
   prepare p_cty22g02_071 from l_sql
}

   let l_sql = "SELECT vipsegflg, segmaiend ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? - 1"
   prepare p_cty22g02_072 from l_sql
   declare c_cty22g02_072 cursor with hold for p_cty22g02_072

   let l_sql = "UPDATE datmitaasiarqico ",
               "SET   aplseqnum = ? ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   pcsseqnum       = ? ",
               "AND   itaasiarqlnhnum = ? ",
               "AND   impicoflg       = 'N'  "
   prepare p_cty22g02_073 from l_sql
   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitarsrcaosrv ",
               "WHERE itarsrcaosrvcod = ? "
   prepare p_cty22g02_074 from l_sql
   declare c_cty22g02_074 cursor with hold for p_cty22g02_074

   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? "
   prepare p_cty22g02_075 from l_sql
   declare c_cty22g02_075 cursor with hold for p_cty22g02_075


   let l_sql = "INSERT INTO datmitaapl ",
               "(itaciacod,itaramcod,itaaplnum,aplseqnum,itaprpnum, ",
               "itaaplvigincdat,itaaplvigfnldat,segnom,pestipcod,segcgccpfnum, ",
               "segcgcordnum,segcgccpfdig,itaprdcod,itacliscocod, ",
               "itacorsuscod,seglgdnom,seglgdnum,segendcmpdes, ",
               "segbrrnom,segcidnom,segufdsgl,segcepnum,segcepcmpnum,segresteldddnum, ",
               "segrestelnum,adniclhordat,itaasiarqvrsnum,pcsseqnum,succod,corsus, ",
               "vipsegflg,segmaiend,frtmdlcod,vndcnlcod) ",
               "SELECT itaciacod,itaramcod,itaaplnum,(aplseqnum + 1),itaprpnum, ",
               "itaaplvigincdat,itaaplvigfnldat,segnom,pestipcod,segcgccpfnum, ",
               "segcgcordnum,segcgccpfdig,itaprdcod,itacliscocod, ",
               "itacorsuscod,seglgdnom,seglgdnum,segendcmpdes, ",
               "segbrrnom,segcidnom,segufdsgl,segcepnum,segcepcmpnum,segresteldddnum, ",
               "segrestelnum,adniclhordat,itaasiarqvrsnum,pcsseqnum,succod,corsus, ",
               "vipsegflg,segmaiend,frtmdlcod,vndcnlcod ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_cty22g02_076 from l_sql

   let l_sql = "UPDATE datmitaapl ",
               "SET itaasiarqvrsnum = ?, ",
               "    pcsseqnum       = ?  ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? + 1 "
   prepare p_cty22g02_077 from l_sql

   let l_sql = "INSERT INTO datmitaaplitm ",
               "(itaciacod,itaramcod,itaaplnum,aplseqnum,itaaplitmnum,itaaplitmsttcod, ",
               "autchsnum,autplcnum,autfbrnom,autlnhnom,autmodnom,itavclcrgtipcod, ",
               "autfbrano,autmodano,autcmbnom,autcornom,autpintipdes,okmflg,impautflg, ",
               "casfrqvlr,rsclclcepnum,rcslclcepcmpnum,porvclcod, ",
               "itaasisrvcod,itarsrcaosrvcod,rsrcaogrtcod,ubbcod,itasgrplncod,itaempasicod, ",
               "asiincdat,itaaplcanmtvcod,itaclisgmcod,vcltipcod,bldflg) ",
               "SELECT itaciacod,itaramcod,itaaplnum,(aplseqnum + 1),itaaplitmnum,itaaplitmsttcod, ",
               "autchsnum,autplcnum,autfbrnom,autlnhnom,autmodnom,itavclcrgtipcod, ",
               "autfbrano,autmodano,autcmbnom,autcornom,autpintipdes,okmflg,impautflg, ",
               "casfrqvlr,rsclclcepnum,rcslclcepcmpnum,porvclcod, ",
               "itaasisrvcod,itarsrcaosrvcod,rsrcaogrtcod,ubbcod,itasgrplncod,itaempasicod, ",
               "asiincdat,itaaplcanmtvcod,itaclisgmcod,vcltipcod,bldflg ",
               "FROM datmitaaplitm ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? "
   prepare p_cty22g02_078 from l_sql

   let l_sql = "UPDATE datmitaaplitm ",
               "SET itaaplitmsttcod = 'C' ",
               "   ,itaaplcanmtvcod = ?   ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? + 1 "
   prepare p_cty22g02_079 from l_sql

   let l_sql = "UPDATE datmitaaplitm ",
               "SET itaaplitmsttcod = 'C' ",
               "   ,itaaplcanmtvcod = ?   ",
               "WHERE itaciacod = ? ",
               "AND   itaramcod = ? ",
               "AND   itaaplnum = ? ",
               "AND   aplseqnum = ? + 1 " ,
               "AND   itaaplitmnum = ? "
   prepare p_cty22g02_079b from l_sql

   let l_sql = "SELECT MAX(aplseqnum) ",
               "FROM datmitaapl ",
               "WHERE itaciacod = ? ",
               "AND itaramcod = ? ",
               "AND itaaplnum = ? "
   prepare p_cty22g02_080 from l_sql
   declare c_cty22g02_080 cursor with hold for p_cty22g02_080

   let l_sql = "UPDATE datmitaarqpcshst ",
               "SET arqpcsfnlhordat = current ",
               "   ,lnhtotqtd = ? ",
               "   ,pcslnhqtd = ? ",
               "   ,arqpcsfnlhordat = current ",
               "   ,fnzpcsflg = 'S' ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   pcsseqnum = ? "
   prepare p_cty22g02_081 from l_sql

   let l_sql = "UPDATE datmitaarqpcshst ",
               "SET lnhtotqtd = ? ",
               "   ,pcslnhqtd = ? ",
               "WHERE itaasiarqvrsnum = ? ",
               "AND   pcsseqnum = ? "
   prepare p_cty22g02_082 from l_sql

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitaram ",
               "WHERE itaramcod = ? "
   prepare p_cty22g02_083 from l_sql
   declare c_cty22g02_083 cursor with hold for p_cty22g02_083

   let l_sql = "SELECT rsrcaogrtcod ",
               "FROM datkitarsrcaogar ",
               "WHERE itarsrcaogrtcod = ? "
   prepare p_cty22g02_084 from l_sql
   declare c_cty22g02_084 cursor with hold for p_cty22g02_084

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkubbvcltip ",
               "WHERE ubbcod = ? "
   prepare p_cty22g02_085 from l_sql
   declare c_cty22g02_085 cursor with hold for p_cty22g02_085

   let l_sql = "  select cornom               ",
               "  from gcaksusep a,           ",
               "       gcakcorr b             ",
               "where a.corsus  = ?           ",
               "and a.corsuspcp = b.corsuspcp "
   prepare p_cty22g02_086  from l_sql
   declare c_cty22g02_086  cursor for p_cty22g02_086

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitaclisco ",
               "WHERE itacliscocod = ? "
   prepare p_cty22g02_087 from l_sql
   declare c_cty22g02_087 cursor with hold for p_cty22g02_087

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitaclisgm ",
               "WHERE itaclisgmcod = ? "
   prepare p_cty22g02_088 from l_sql
   declare c_cty22g02_088 cursor with hold for p_cty22g02_088

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitarsrcaogar ",
               "WHERE rsrcaogrtcod = ? "
   prepare p_cty22g02_089 from l_sql
   declare c_cty22g02_089 cursor with hold for p_cty22g02_089

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitavclcrgtip ",
               "WHERE itavclcrgtipcod = ? "
   prepare p_cty22g02_090 from l_sql
   declare c_cty22g02_090 cursor with hold for p_cty22g02_090

   let l_sql = "select count(*) from datkitaasisrv ",
              " where itaasisrvcod = ? "
   prepare p_cty22g02_091 from l_sql
   declare c_cty22g02_091 cursor with hold for p_cty22g02_091

   let l_sql = "SELECT itasgrplncod ",
               "FROM datkitasgrpln ",
               "WHERE UPPER(itasgrplndes) = ? "
   prepare p_cty22g02_092 from l_sql
   declare c_cty22g02_092 cursor with hold for p_cty22g02_092

   let l_sql = "SELECT frtmdlcod ",
               "FROM datkitafrtmdl ",
               "WHERE UPPER(frtmdldes) = ? "
   prepare p_cty22g02_093 from l_sql
   declare c_cty22g02_093 cursor with hold for p_cty22g02_093

   let l_sql = "SELECT vndcnlcod ",
               "FROM datkitavndcnl ",
               "WHERE UPPER(vndcnldes) = ? "
   prepare p_cty22g02_094 from l_sql
   declare c_cty22g02_094 cursor with hold for p_cty22g02_094

   let l_sql = "SELECT vcltipcod ",
               "FROM datkitavcltip ",
               "WHERE UPPER(vcltipdes) = ? "
   prepare p_cty22g02_095 from l_sql
   declare c_cty22g02_095 cursor with hold for p_cty22g02_095

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitavndcnl ",
               "WHERE vndcnlcod = ? "
   prepare p_cty22g02_096 from l_sql
   declare c_cty22g02_096 cursor with hold for p_cty22g02_096

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitavcltip ",
               "WHERE vcltipcod = ? "
   prepare p_cty22g02_097 from l_sql
   declare c_cty22g02_097 cursor with hold for p_cty22g02_097

   let l_sql = "SELECT COUNT(*) ",
               "FROM datkitafrtmdl ",
               "WHERE frtmdlcod = ? "
   prepare p_cty22g02_098 from l_sql
   declare c_cty22g02_098 cursor with hold for p_cty22g02_098

   let l_sql = "SELECT itaclisgmcod,    ",
               "       aplseqnum        ",
               "FROM datmitaaplitm      ",
               "WHERE itaciacod     = ? ",
               "AND   itaramcod     = ? ",
               "AND   itaaplnum     = ? ",
               "AND   itaaplitmnum  = ? ",
               "AND   aplseqnum  IN(SELECT min(aplseqnum) FROM datmitaaplitm ",
                                   "WHERE itaciacod     = ? ",
                                   "AND   itaramcod     = ? ",
                                   "AND   itaaplnum     = ? ",
                                   "AND   itaaplitmnum  = ?)"
   prepare p_cty22g02_099 from l_sql
   declare c_cty22g02_099 cursor with hold for p_cty22g02_099


   let l_sql = "SELECT itaaplvigincdat  ",
               "FROM datmitaapl         ",
               "WHERE itaciacod     = ? ",
               "AND   itaramcod     = ? ",
               "AND   itaaplnum     = ? ",
               "AND   aplseqnum     = ? "
   prepare p_cty22g02_100 from l_sql
   declare c_cty22g02_100 cursor with hold for p_cty22g02_100


   let m_prepare = true

end function

#=======================================================
function cty22g02_verifica_inconsistencias2(lr_apolice)
#=======================================================
# Verifica inconsistencias da recarga (APOLICE -> APOLICE)

   define lr_apolice record
       itaaplnum       like datmitaapl.itaaplnum
      ,itaaplitmnum    like datmitaaplitm.itaaplitmnum
      ,aplseqnum       like datmitaapl.aplseqnum
      ,itaciacod       like datmitaapl.itaciacod
      ,itaramcod       like datmitaapl.itaramcod
      ,segcgccpfnum    like datmitaapl.segcgccpfnum
      ,segcgcordnum    like datmitaapl.segcgcordnum
      ,segcgccpfdig    like datmitaapl.segcgccpfdig
      ,itaprdcod       like datmitaapl.itaprdcod
      ,itacliscocod    like datmitaapl.itacliscocod
      ,vndcnlcod       like datmitaapl.vndcnlcod
      ,frtmdlcod       like datmitaapl.frtmdlcod
      ,itaasisrvcod    like datmitaaplitm.itaasisrvcod
      ,itarsrcaosrvcod like datmitaaplitm.itarsrcaosrvcod
      ,rsrcaogrtcod    like datmitaaplitm.rsrcaogrtcod
      ,ubbcod          like datmitaaplitm.ubbcod
      ,itasgrplncod    like datmitaaplitm.itasgrplncod
      ,itaempasicod    like datmitaaplitm.itaempasicod
      ,itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod
      ,itaclisgmcod    like datmitaaplitm.itaclisgmcod
      ,itavclcrgtipcod like datmitaaplitm.itavclcrgtipcod
      ,vcltipcod       like datmitaaplitm.vcltipcod
      ,operacao        char(1)
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_cont_nimpedit smallint #Qtd inconsistencias nao impeditivas de gravacao

   initialize lr_valida.* to null
   let l_cont_nimpedit = 0


   case lr_apolice.operacao

      when 'C'  # Verificacoes exclusivas para Cancelamentos

         # VALIDA MOTIVO DE CANCELAMENTO
         call cty22g02_valida_motivo_cancel(lr_apolice.itaaplcanmtvcod)
         returning lr_valida.*, lr_apolice.itaaplcanmtvcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

      when 'I'  # Verificacoes exclusivas para Inclusoes

         # VALIDA PRODUTO
         call cty22g02_valida_produto(lr_apolice.itaprdcod)
         returning lr_valida.*, lr_apolice.itaprdcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA PLANO
         call cty22g02_valida_plano(lr_apolice.itasgrplncod)
         returning lr_valida.*, lr_apolice.itasgrplncod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA SERVICO PRESTADO
         call cty22g02_valida_servico_prestado(lr_apolice.itaasisrvcod)
         returning lr_valida.*, lr_apolice.itaasisrvcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA EMPRESA ASSISTENCIA
         call cty22g02_valida_empresa(lr_apolice.itaempasicod)
         returning lr_valida.*, lr_apolice.itaempasicod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA SCORE DO CLIENTE
         call cty22g02_valida_score2(lr_apolice.itacliscocod)
         returning lr_valida.*, lr_apolice.itacliscocod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn


         # RECUPERA O PRIMEIRO SEGMENTO DA APOLICE
         call cty22g02_recupera_segmento_sequencia(lr_apolice.itaciacod    ,
                                                   lr_apolice.itaramcod    ,
                                                   lr_apolice.itaaplnum    ,
                                                   lr_apolice.itaaplitmnum ,
                                                   lr_apolice.itaclisgmcod )
         returning lr_apolice.itaclisgmcod


         # ACERTA O SEGMENTO DA APOLICE
         call cty22g02_acerta_segmento (lr_apolice.itaciacod    ,
                                        lr_apolice.itaramcod    ,
                                        lr_apolice.itaaplnum    ,
                                        lr_apolice.itaaplitmnum ,
                                        lr_apolice.aplseqnum    ,
                                        lr_apolice.itaclisgmcod )
         returning lr_apolice.itaclisgmcod

         # VALIDA SEGMENTO
         call cty22g02_valida_segmento2(lr_apolice.itaclisgmcod)
         returning lr_valida.*, lr_apolice.itaclisgmcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA SERVICO DE CARRO RESERVA
         call cty22g02_valida_servico_carro_reserva(lr_apolice.itarsrcaosrvcod)
         returning lr_valida.*, lr_apolice.itarsrcaosrvcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA GARANTIA DE CARRO RESERVA
         call cty22g02_valida_garantia_carro_reserva2(lr_apolice.rsrcaogrtcod)
         returning lr_valida.*, lr_apolice.rsrcaogrtcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA CPF/CNPJ
         #call cty22g02_valida_cgccpf(lr_apolice.segcgccpfnum)
         #returning lr_valida.*
         #let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA TIPO DE CARGA
         call cty22g02_valida_tipo_carga2(lr_apolice.itavclcrgtipcod)
         returning lr_valida.*, lr_apolice.itavclcrgtipcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA UBB - TIPO VEICULO UNIBANCO
         call cty22g02_valida_ubb(lr_apolice.ubbcod)
         returning lr_valida.*, lr_apolice.ubbcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn


         # VALIDA MODALIDADE DA FROTA
         call cty22g02_valida_modalidade_frota2(lr_apolice.frtmdlcod)
         returning lr_valida.*, lr_apolice.frtmdlcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA CANAL DE VENDA
         call cty22g02_valida_canal_venda2(lr_apolice.vndcnlcod)
         returning lr_valida.*, lr_apolice.vndcnlcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

         # VALIDA TIPO DE VEICULO
         call cty22g02_valida_tipo_veiculo2(lr_apolice.vcltipcod)
         returning lr_valida.*, lr_apolice.vcltipcod
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn

      otherwise
         let l_cont_nimpedit = l_cont_nimpedit + 1

   end case

   return l_cont_nimpedit
#=======================================================
end function  # Fim funcao cty22g02_verifica_inconsistencias2
#=======================================================

#=======================================================
function cty22g02_verifica_inconsistencias(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================
# Verifica inconsistencias da carga (MOVIMENTO -> APOLICE)

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

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

   define l_cont_impedit smallint  #Qtd inconsistencias impeditivas de gravacao
   define l_cont_nimpedit smallint #Qtd inconsistencias nao impeditivas de gravacao

   initialize lr_arquivo.* to null
   initialize lr_erro.* to null
   let l_cont_impedit = 0
   let l_cont_nimpedit = 0

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   let lr_arquivo.asiarqvrsnum = lr_dados.asiarqvrsnum
   let lr_arquivo.asiarqlnhnum = lr_dados.asiarqlnhnum
   let lr_arquivo.pcsseqnum = lr_hist_process.pcsseqnum

   # Validacoes comuns para Inclusoes e Cancelamentos

   # VALIDA INCONSISTENCIAS ARQUIVO DE CARGA ATUAL
   if lr_apolice_atual.aplseqnum is null then
      # Este if valida se � o primeiro item. Os demais itens seguirao o primeiro.

      call cty22g02_valida_inconsist_atual(lr_apolice_atual.*)
      returning lr_valida.*
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
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
      # Verifica cargas anteriores apenas se n�o existir inconsistencia no arquivo atual

      call cty22g02_valida_inconsist_anterior(lr_apolice_atual.*, lr_arquivo.*)
      returning lr_valida.*
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if
   end if


   # VALIDA CHAVE DA APOLICE
   call cty22g02_valida_chave_apolice(lr_apolice_atual.*)
   returning lr_valida.*
   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if


   # VALIDA COMPANHIA
   call cty22g02_valida_companhia(lr_dados.ciacod)
   returning lr_valida.*, lr_dados.ciacod
   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if

   # VALIDA RAMO
   call cty22g02_valida_ramo(lr_dados.ramcod)
   returning lr_valida.*, lr_dados.ramcod
   if lr_valida.erro = 1 or lr_valida.warn = 1 then
      if l_cont_impedit > 0 then
         let lr_valida.erro = 1
      end if
      call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
      returning lr_erro.*
      if lr_erro.sqlcode <> 0 then
         return lr_erro.*, 0, 0, lr_dados.*
      end if
      let l_cont_impedit = l_cont_impedit + lr_valida.erro
      let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
   end if


   if lr_dados.mvtsttcod = 'C' then
      # Verificacoes exclusivas para Cancelamentos

      # VALIDA MOTIVO DE CANCELAMENTO
      call cty22g02_valida_motivo_cancel(lr_dados.aplcanmtvcod)
      returning lr_valida.*, lr_dados.auxaplcanmtvcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

   end if


   if lr_dados.mvtsttcod = 'I' then
      # Verificacoes exclusivas para Inclusoes

{
      # VALIDA DATAS
      call cty22g02_valida_datas(lr_dados.aplvigincdat
                                ,lr_dados.aplvigfnldat
                                ,lr_dados.adniclhordat
                                ,lr_dados.pcshordat
                                ,lr_dados.asiincdat   )
      returning lr_valida.*
      if lr_valida.erro = 1 then
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_contador = l_contador + 1
      end if
 }

      # VALIDA PRODUTO
      call cty22g02_valida_produto(lr_dados.prdcod)
      returning lr_valida.*, lr_dados.auxprdcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA PLANO
      call cty22g02_valida_plano2(lr_dados.plndes)
      returning lr_valida.*, lr_dados.auxsgrplncod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA SERVICO PRESTADO
      call cty22g02_valida_servico_prestado(lr_dados.asisrvcod)
      returning lr_valida.*, lr_dados.auxasisrvcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA EMPRESA ASSISTENCIA
      call cty22g02_valida_empresa(lr_dados.empasicod)
      returning lr_valida.*, lr_dados.auxempasicod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA SCORE DO CLIENTE
      call cty22g02_valida_score(lr_dados.cliscocod)
      returning lr_valida.*, lr_dados.auxcliscocod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

     # VALIDA SEGMENTO COM GARANTIA
      call cty22g02_valida_segmento_garantia(lr_dados.clisgmcod,
                                             lr_dados.rsrcaogrtcod)
            returning lr_dados.auxclisgmcod,
                      lr_dados.auxrsrcaogrtcod


      if lr_dados.auxclisgmcod is null then

          # RECUPERA O PRIMEIRO SEGMENTO DA APOLICE
          call cty22g02_recupera_segmento_sequencia(lr_apolice_atual.ciacod    ,
                                                    lr_apolice_atual.ramcod    ,
                                                    lr_apolice_atual.aplnum    ,
                                                    lr_apolice_atual.aplitmnum ,
                                                    lr_dados.clisgmcod         )
          returning lr_dados.clisgmcod

          # ACERTA O SEGMENTO DA APOLICE
          call cty22g02_acerta_segmento(lr_apolice_atual.ciacod    ,
                                        lr_apolice_atual.ramcod    ,
                                        lr_apolice_atual.aplnum    ,
                                        lr_apolice_atual.aplitmnum ,
                                        lr_apolice_atual.aplseqnum ,
                                        lr_dados.clisgmcod         )
          returning lr_dados.clisgmcod

          # VALIDA SEGMENTO
          call cty22g02_valida_segmento(lr_dados.clisgmcod)
          returning lr_valida.*, lr_dados.auxclisgmcod
          if lr_valida.erro = 1 or lr_valida.warn = 1 then
             if l_cont_impedit > 0 then
                let lr_valida.erro = 1
             end if

             call cty22g02_carrega_inconsistencia(lr_apolice_atual.*
                                                 ,lr_valida.*
                                                 ,lr_arquivo.*)
             returning lr_erro.*
             if lr_erro.sqlcode <> 0 then
                return lr_erro.*, 0, 0, lr_dados.*
             end if
             let l_cont_impedit = l_cont_impedit + lr_valida.erro
             let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
          end if
      end if
      # VALIDA SERVICO DE CARRO RESERVA
      call cty22g02_valida_servico_carro_reserva(lr_dados.rsrcaosrvcod)
      returning lr_valida.*, lr_dados.auxrsrcaosrvcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      if lr_dados.auxrsrcaogrtcod is null then

         # VALIDA GARANTIA DE CARRO RESERVA
         call cty22g02_valida_garantia_carro_reserva(lr_dados.rsrcaogrtcod)
         returning lr_valida.*, lr_dados.auxrsrcaogrtcod
         if lr_valida.erro = 1 or lr_valida.warn = 1 then
            if l_cont_impedit > 0 then
               let lr_valida.erro = 1
            end if

            call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
            returning lr_erro.*
            if lr_erro.sqlcode <> 0 then
               return lr_erro.*, 0, 0, lr_dados.*
            end if
            let l_cont_impedit = l_cont_impedit + lr_valida.erro
            let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
         end if
      end if

{
      # VALIDA CPF/CNPJ
      call cty22g02_valida_cgccpf(lr_dados.segcgccpfnum)
      returning lr_valida.*
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if
}
      # VALIDA TIPO DE CARGA
      call cty22g02_valida_tipo_carga(lr_dados.vclcrgtipcod)
      returning lr_valida.*, lr_dados.auxvclcrgtipcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA UBB - TIPO VEICULO UNIBANCO
      call cty22g02_valida_ubb(lr_dados.ubbcod)
      returning lr_valida.*, lr_dados.auxubbcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if



      # VALIDA MODALIDADE DA FROTA
      call cty22g02_valida_modalidade_frota(lr_dados.frtmdlnom)
      returning lr_valida.*, lr_dados.auxfrtmdlcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA CANAL DE VENDA
      call cty22g02_valida_canal_venda(lr_dados.vndcnldes)
      returning lr_valida.*, lr_dados.auxvndcnlcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
         returning lr_erro.*
         if lr_erro.sqlcode <> 0 then
            return lr_erro.*, 0, 0, lr_dados.*
         end if
         let l_cont_impedit = l_cont_impedit + lr_valida.erro
         let l_cont_nimpedit = l_cont_nimpedit + lr_valida.warn
      end if

      # VALIDA TIPO DE VEICULO
      call cty22g02_valida_tipo_veiculo(lr_dados.vcltipnom)
      returning lr_valida.*, lr_dados.auxvcltipcod
      if lr_valida.erro = 1 or lr_valida.warn = 1 then
         if l_cont_impedit > 0 then
            let lr_valida.erro = 1
         end if
         call cty22g02_carrega_inconsistencia(lr_apolice_atual.*, lr_valida.*, lr_arquivo.*)
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
end function  # Fim funcao cty22g02_verifica_inconsistencias
#===========================================================

#=======================================================
function cty22g02_valida_companhia(lr_param)
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
      call cty22g02_prepare()
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
   open c_cty22g02_054 using lr_param.ciacod
   fetch c_cty22g02_054 into l_count
   whenever error stop
   close c_cty22g02_054

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
end function # Fim funcao cty22g02_valida_companhia
#========================================================================
#=======================================================
function cty22g02_valida_ramo(lr_param)
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
      call cty22g02_prepare()
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
   open c_cty22g02_083 using lr_param.ramcod
   fetch c_cty22g02_083 into l_count
   whenever error stop
   close c_cty22g02_083

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
end function # Fim funcao cty22g02_valida_ramo
#========================================================================
#=======================================================
function cty22g02_valida_motivo_cancel(lr_param)
#=======================================================

   define lr_param record
      aplcanmtvcod like datkitaaplcanmtv.itaaplcanmtvcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO MOTIVO DE CANCELAMENTO (itaaplcanmtvcod)"
   let lr_valida.valor  = lr_param.aplcanmtvcod clipped
   let l_count = 0

   if lr_param.aplcanmtvcod clipped = "" or
      lr_param.aplcanmtvcod is null then
      let lr_param.aplcanmtvcod = 0 #NENHUM
   end if

   if lr_param.aplcanmtvcod = 9999 then
      let lr_valida.warn = 1
      let lr_param.aplcanmtvcod = 9999 #NAO INFORMADO
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.aplcanmtvcod
   end if

   whenever error continue
   open c_cty22g02_051 using lr_param.aplcanmtvcod
   fetch c_cty22g02_051 into l_count
   whenever error stop
   close c_cty22g02_051

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaaplcanmtv>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.aplcanmtvcod
   end if

   if l_count <= 0 then
      let lr_param.aplcanmtvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
   end if

  return lr_valida.*, lr_param.aplcanmtvcod

#========================================================================
end function # Fim funcao cty22g02_valida_motivo_cancel
#========================================================================

#=======================================================
function cty22g02_valida_produto(lr_param)
#=======================================================

   define lr_param record
      prdcod like datkitaprd.itaprdcod
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
      call cty22g02_prepare()
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
   open c_cty22g02_056 using lr_param.prdcod
   fetch c_cty22g02_056 into l_count
   whenever error stop
   close c_cty22g02_056

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
end function # Fim funcao cty22g02_valida_produto
#========================================================================

#=======================================================
function cty22g02_valida_inconsist_anterior(lr_apolice_atual, lr_arquivo)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_arquivo record
       asiarqvrsnum  like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum     like datmitaasiarqico.pcsseqnum
      ,asiarqlnhnum  like datmitaasiarqico.itaasiarqlnhnum
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.codigo = 7 # ENCONTRADAS INCONSISTENCIAS DA MESMA APOLICE
   let lr_valida.campo = "ARQUIVO DE CARGA ANTERIOR"
   let l_count = 0

   whenever error continue
   open c_cty22g02_061 using lr_apolice_atual.ciacod
                           ,lr_apolice_atual.ramcod
                           ,lr_apolice_atual.aplnum
                           ,lr_arquivo.asiarqvrsnum
   fetch c_cty22g02_061 into l_count
   whenever error stop
   close c_cty22g02_061

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datmitaasiarqico>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*
   end if

  if l_count >= 1 then
      let lr_valida.erro = 1
      call cty22g02_trim(l_count)
      returning lr_valida.valor
      let lr_valida.valor = lr_valida.valor clipped, " INCONSISTENCIA(S)."
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g02_valida_inconsist_anterior
#========================================================================
#=======================================================
function cty22g02_valida_inconsist_atual(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.codigo = 7 # ENCONTRADAS INCONSISTENCIAS DA MESMA APOLICE
   let lr_valida.campo = "PROCESSAMENTO DE CARGA ATUAL"

  if lr_apolice_atual.qtdinconsist >= 1 then
      let lr_valida.erro = 1
      call cty22g02_trim(lr_apolice_atual.qtdinconsist)
      returning lr_valida.valor
      let lr_valida.valor = lr_valida.valor clipped, " INCONSISTENCIA(S)."
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g02_valida_inconsist_atual
#========================================================================
#=======================================================
function cty22g02_valida_score(lr_param)
#=======================================================

   define lr_param record
      cliscodes like datkitaclisco.itacliscodes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_cliscocod like datkitaclisco.itacliscocod
   let l_cliscocod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.cliscodes)
   returning lr_param.cliscodes

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "SCORE DO CLIENTE (itacliscodes)"
   let lr_valida.valor  = lr_param.cliscodes clipped

   if lr_param.cliscodes clipped = " " or
      lr_param.cliscodes is null then

      let l_cliscocod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_cliscocod
   end if

   let lr_param.cliscodes = upshift(lr_param.cliscodes)

   whenever error continue
   open c_cty22g02_060 using lr_param.cliscodes
   fetch c_cty22g02_060 into l_cliscocod
   whenever error stop
   close c_cty22g02_060

   if sqlca.sqlcode = notfound or l_cliscocod is null or l_cliscocod = 0 then
      let l_cliscocod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_cliscocod
   end if

   if sqlca.sqlcode < 0 then
      let l_cliscocod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaclisco>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

  return lr_valida.*, l_cliscocod

#========================================================================
end function # Fim funcao cty22g02_valida_score
#========================================================================

#=======================================================
function cty22g02_valida_score2(lr_param)
#=======================================================

   define lr_param record
      cliscocod like datkitaclisco.itacliscocod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "SCORE DO CLIENTE (itacliscocod)"
   let lr_valida.valor  = lr_param.cliscocod clipped
   let l_count = 0

   if lr_param.cliscocod is null or
      lr_param.cliscocod = 9999 then

      let lr_param.cliscocod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, lr_param.cliscocod
   end if

   whenever error continue
   open c_cty22g02_087 using lr_param.cliscocod
   fetch c_cty22g02_087 into l_count
   whenever error stop
   close c_cty22g02_087

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaclisco>."
      return lr_valida.*, lr_param.cliscocod
   end if

   if l_count <= 0 then
      let lr_param.cliscocod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.cliscocod

#========================================================================
end function # Fim funcao cty22g02_valida_score2
#========================================================================

#=======================================================
function cty22g02_valida_segmento(lr_param)
#=======================================================

   define lr_param record
      itasgmcod like datkitaclisgm.itasgmcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_itaclisgmcod like datkitaclisgm.itaclisgmcod
   let l_itaclisgmcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
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
   open c_cty22g02_055 using lr_param.itasgmcod
   fetch c_cty22g02_055 into l_itaclisgmcod
   whenever error stop
   close c_cty22g02_055

   if sqlca.sqlcode = notfound or l_itaclisgmcod is null then
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
end function # Fim funcao cty22g02_valida_segmento
#========================================================================

#=======================================================
function cty22g02_valida_segmento2(lr_param)
#=======================================================

   define lr_param record
      itaclisgmcod like datkitaclisgm.itaclisgmcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "SEGMENTO DO CLIENTE (itaclisgmcod)"
   let lr_valida.valor  = lr_param.itaclisgmcod clipped
   let l_count = 0

   if lr_param.itaclisgmcod is null or
      lr_param.itaclisgmcod = " " or
      lr_param.itaclisgmcod = 9999 then
      let lr_param.itaclisgmcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.itaclisgmcod
   end if

   whenever error continue
   open c_cty22g02_088 using lr_param.itaclisgmcod
   fetch c_cty22g02_088 into l_count
   whenever error stop
   close c_cty22g02_088

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitaclisgm>."
      return lr_valida.*, lr_param.itaclisgmcod
   end if

   if l_count <= 0 then
      let lr_param.itaclisgmcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.itaclisgmcod

#========================================================================
end function # Fim funcao cty22g02_valida_segmento2
#========================================================================

#=======================================================
function cty22g02_valida_chave_apolice(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
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
      call cty22g02_prepare()
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
end function # Fim funcao cty22g02_valida_chave_apolice
#========================================================================

#=======================================================
function cty22g02_valida_tipo_carga(lr_param)
#=======================================================

   define lr_param record
      vclcrgtipdes like datkitavclcrgtip.itavclcrgtipdes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_vclcrgtipcod like datkitavclcrgtip.itavclcrgtipcod
   let l_vclcrgtipcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.vclcrgtipdes)
   returning lr_param.vclcrgtipdes

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "TIPO DE CARGA (itavclcrgtipdes)"
   let lr_valida.valor  = lr_param.vclcrgtipdes clipped


   if lr_param.vclcrgtipdes clipped = " " or
      lr_param.vclcrgtipdes is null then

      let l_vclcrgtipcod = 9999 #NAO INFORMADO
      #let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_vclcrgtipcod
   end if

   whenever error continue
   open c_cty22g02_059 using lr_param.vclcrgtipdes
   fetch c_cty22g02_059 into l_vclcrgtipcod
   whenever error stop
   close c_cty22g02_059

   if sqlca.sqlcode = notfound or l_vclcrgtipcod is null or l_vclcrgtipcod = 0 then
      let l_vclcrgtipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_vclcrgtipcod
   end if

   if sqlca.sqlcode < 0 then
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavclcrgtip>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

   return lr_valida.*, l_vclcrgtipcod

#========================================================================
end function # Fim funcao cty22g02_valida_tipo_carga
#========================================================================

#=======================================================
function cty22g02_valida_tipo_carga2(lr_param)
#=======================================================

   define lr_param record
      itavclcrgtipcod like datkitavclcrgtip.itavclcrgtipcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "TIPO DE CARGA (itavclcrgtipcod)"
   let lr_valida.valor  = lr_param.itavclcrgtipcod clipped
   let l_count = 0

   if lr_param.itavclcrgtipcod is null or
      lr_param.itavclcrgtipcod = " " or
      lr_param.itavclcrgtipcod = 9999 then
      let lr_param.itavclcrgtipcod = 9999 #NAO INFORMADO
      #let lr_valida.warn = 1
      #let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      #return lr_valida.*, lr_param.itavclcrgtipcod
   end if

   whenever error continue
   open c_cty22g02_090 using lr_param.itavclcrgtipcod
   fetch c_cty22g02_090 into l_count
   whenever error stop
   close c_cty22g02_090

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavclcrgtip>."
      return lr_valida.*, lr_param.itavclcrgtipcod
   end if

   if l_count <= 0 then
      let lr_param.itavclcrgtipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.itavclcrgtipcod

#========================================================================
end function # Fim funcao cty22g02_valida_tipo_carga2
#========================================================================

#=======================================================
function cty22g02_valida_ubb(lr_param)
#=======================================================

   define lr_param record
      ubbcod         like datkubbvcltip.ubbcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_count    smallint

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "UBB - VEICULO UNIBANCO (ubbcod)"
   let lr_valida.valor  = lr_param.ubbcod clipped
   let l_count = 0

   if lr_param.ubbcod clipped = " " or
      lr_param.ubbcod is null then

      let lr_param.ubbcod = 0
   end if

   whenever error continue
   open c_cty22g02_085 using lr_param.ubbcod
   fetch c_cty22g02_085 into l_count
   whenever error stop
   close c_cty22g02_085

   if sqlca.sqlcode <> 0 then
      let lr_param.ubbcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkubbvcltip>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.ubbcod
   end if

   if l_count <= 0 then
      let lr_param.ubbcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

   return lr_valida.*, lr_param.ubbcod

#========================================================================
end function # Fim funcao cty22g02_valida_ubb
#========================================================================

#=======================================================
function cty22g02_valida_modalidade_frota(lr_param)
#=======================================================

   define lr_param record
      frtmdldes like datkitafrtmdl.frtmdldes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_frtmdlcod like datkitafrtmdl.frtmdlcod
   let l_frtmdlcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.frtmdldes)
   returning lr_param.frtmdldes

   let lr_param.frtmdldes = upshift(lr_param.frtmdldes)

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "MODALIDADE DE FROTA (frtmdldes)"
   let lr_valida.valor  = lr_param.frtmdldes clipped


   if lr_param.frtmdldes clipped = " " or
      lr_param.frtmdldes is null then

      let l_frtmdlcod = 0 #NENHUMA
      return lr_valida.*, l_frtmdlcod
   end if

   whenever error continue
   open c_cty22g02_093 using lr_param.frtmdldes
   fetch c_cty22g02_093 into l_frtmdlcod
   whenever error stop
   close c_cty22g02_093

   if sqlca.sqlcode = notfound or l_frtmdlcod is null then
      let l_frtmdlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_frtmdlcod
   end if

   if sqlca.sqlcode < 0 then
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitafrtmdl>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

   return lr_valida.*, l_frtmdlcod

#========================================================================
end function # Fim funcao cty22g02_valida_modalidade_frota
#========================================================================

#=======================================================
function cty22g02_valida_modalidade_frota2(lr_param)
#=======================================================

   define lr_param record
      frtmdlcod like datkitafrtmdl.frtmdlcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "MODALIDADE DE FROTA (frtmdlcod)"
   let lr_valida.valor  = lr_param.frtmdlcod clipped
   let l_count = 0

   if lr_param.frtmdlcod is null or
      lr_param.frtmdlcod = " " or
      lr_param.frtmdlcod = 9999 then

      let lr_param.frtmdlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, lr_param.frtmdlcod
   end if

   whenever error continue
   open c_cty22g02_098 using lr_param.frtmdlcod
   fetch c_cty22g02_098 into l_count
   whenever error stop
   close c_cty22g02_098

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitafrtmdl>."
      return lr_valida.*, lr_param.frtmdlcod
   end if

   if l_count <= 0 then
      let lr_param.frtmdlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.frtmdlcod

#========================================================================
end function # Fim funcao cty22g02_valida_modalidade_frota2
#========================================================================



#=======================================================
function cty22g02_valida_garantia_carro_reserva(lr_param)
#=======================================================

   define lr_param record
      rsrcaogrtcod like datkitarsrcaogar.itarsrcaogrtcod
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_rsrcaogrtcod like datkitarsrcaogar.rsrcaogrtcod
   let l_rsrcaogrtcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "GARANTIA DE CARRO RESERVA (rsrcaogrtcod)"
   let lr_valida.valor  = lr_param.rsrcaogrtcod clipped

   whenever error continue
   open c_cty22g02_084 using lr_param.rsrcaogrtcod
   fetch c_cty22g02_084 into l_rsrcaogrtcod
   whenever error stop
   close c_cty22g02_084

   if sqlca.sqlcode = notfound or l_rsrcaogrtcod is null or l_rsrcaogrtcod = 0 then
      #let l_rsrcaogrtcod = 0
      let l_rsrcaogrtcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_rsrcaogrtcod
   end if

   if sqlca.sqlcode < 0 then
      let l_rsrcaogrtcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitarsrcaogar>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

   return lr_valida.*, l_rsrcaogrtcod

#========================================================================
end function # Fim funcao cty22g02_valida_garantia_carro_reserva
#========================================================================

#=======================================================
function cty22g02_valida_garantia_carro_reserva2(lr_param)
#=======================================================

   define lr_param record
      rsrcaogrtcod like datkitarsrcaogar.rsrcaogrtcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "GARANTIA DE CARRO RESERVA (rsrcaogrtcod)"
   let lr_valida.valor  = lr_param.rsrcaogrtcod clipped
   let l_count = 0

   if lr_param.rsrcaogrtcod is null or
      lr_param.rsrcaogrtcod = " " or
      lr_param.rsrcaogrtcod = 9999 then
      let lr_param.rsrcaogrtcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.rsrcaogrtcod
   end if

   whenever error continue
   open c_cty22g02_089 using lr_param.rsrcaogrtcod
   fetch c_cty22g02_089 into l_count
   whenever error stop
   close c_cty22g02_089

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitarsrcaogar>."
      return lr_valida.*, lr_param.rsrcaogrtcod
   end if

   if l_count <= 0 then
      let lr_param.rsrcaogrtcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.rsrcaogrtcod

#========================================================================
end function # Fim funcao cty22g02_valida_garantia_carro_reserva2
#========================================================================


#=======================================================
function cty22g02_valida_servico_carro_reserva(lr_param)
#=======================================================

   define lr_param record
      rsrcaosrvcod like datkitarsrcaosrv.itarsrcaosrvcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO SERVICO DE CARRO RESERVA (itarsrcaosrvcod)"
   let lr_valida.valor  = lr_param.rsrcaosrvcod clipped
   let l_count = 0

   if lr_param.rsrcaosrvcod is null or
      lr_param.rsrcaosrvcod = 9999 then

      let lr_param.rsrcaosrvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, lr_param.rsrcaosrvcod
   end if

   whenever error continue
   open c_cty22g02_074 using lr_param.rsrcaosrvcod
   fetch c_cty22g02_074 into l_count
   whenever error stop
   close c_cty22g02_074

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitarsrcaosrv>."
      return lr_valida.*, lr_param.rsrcaosrvcod
   end if

   if l_count <= 0 then
      let lr_param.rsrcaosrvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.rsrcaosrvcod

#========================================================================
end function # Fim funcao cty22g02_valida_servico_carro_reserva
#========================================================================

#=======================================================
function cty22g02_valida_plano(lr_param)
#=======================================================

   define lr_param record
      sgrplncod like datkitasgrpln.itasgrplncod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO PLANO (itasgrplncod)"
   let lr_valida.valor  = lr_param.sgrplncod clipped
   let l_count = 0

   if lr_param.sgrplncod is null or
      lr_param.sgrplncod clipped = "" or
      lr_param.sgrplncod = 0 or
      lr_param.sgrplncod = 9999 then

      let lr_param.sgrplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.sgrplncod
   end if

   whenever error continue
   open c_cty22g02_057 using lr_param.sgrplncod
   fetch c_cty22g02_057 into l_count
   whenever error stop
   close c_cty22g02_057

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitasgrpln>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*, lr_param.sgrplncod
   end if

  if l_count <= 0 then
      let lr_param.sgrplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*, lr_param.sgrplncod

#========================================================================
end function # Fim funcao cty22g02_valida_plano
#========================================================================

#=======================================================
function cty22g02_valida_plano2(lr_param)
#=======================================================

   define lr_param record
      sgrplndes like datkitasgrpln.itasgrplndes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_sgrplncod like datkitasgrpln.itasgrplncod
   let l_sgrplncod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.sgrplndes)
   returning lr_param.sgrplndes

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "DESCRICAO DO PLANO (itasgrplndes)"
   let lr_valida.valor  = lr_param.sgrplndes clipped

   if lr_param.sgrplndes clipped = " " or
      lr_param.sgrplndes is null then

      let l_sgrplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_sgrplncod
   end if

   let lr_param.sgrplndes = upshift(lr_param.sgrplndes)

   whenever error continue
   open c_cty22g02_092 using lr_param.sgrplndes
   fetch c_cty22g02_092 into l_sgrplncod
   whenever error stop
   close c_cty22g02_092

   if sqlca.sqlcode = notfound or l_sgrplncod is null or l_sgrplncod = 0 then
      let l_sgrplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_sgrplncod
   end if

   if sqlca.sqlcode < 0 then
      let l_sgrplncod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitasgrpln>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

  return lr_valida.*, l_sgrplncod

#========================================================================
end function # Fim funcao cty22g02_valida_plano2
#========================================================================

#=======================================================
function cty22g02_valida_tipo_veiculo(lr_param)
#=======================================================

   define lr_param record
      vcltipdes like datkitavcltip.vcltipdes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_vcltipcod like datkitavcltip.vcltipcod
   let l_vcltipcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.vcltipdes)
   returning lr_param.vcltipdes

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "TIPO DE VEICULO (vcltipdes)"
   let lr_valida.valor  = lr_param.vcltipdes clipped

   if lr_param.vcltipdes clipped = " " or
      lr_param.vcltipdes is null then

      let l_vcltipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_vcltipcod
   end if

   let lr_param.vcltipdes = upshift(lr_param.vcltipdes)

   whenever error continue
   open c_cty22g02_095 using lr_param.vcltipdes
   fetch c_cty22g02_095 into l_vcltipcod
   whenever error stop
   close c_cty22g02_095

   if sqlca.sqlcode = notfound or l_vcltipcod is null or l_vcltipcod = 0 then
      let l_vcltipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_vcltipcod
   end if

   if sqlca.sqlcode < 0 then
      let l_vcltipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavcltip>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

  return lr_valida.*, l_vcltipcod

#========================================================================
end function # Fim funcao cty22g02_valida_tipo_veiculo
#========================================================================

#=======================================================
function cty22g02_valida_tipo_veiculo2(lr_param)
#=======================================================

   define lr_param record
      vcltipcod like datkitavcltip.vcltipcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "TIPO DE VEICULO (vcltipcod)"
   let lr_valida.valor  = lr_param.vcltipcod clipped
   let l_count = 0

   if lr_param.vcltipcod is null or
      lr_param.vcltipcod = " " or
      lr_param.vcltipcod = 9999 then

      let lr_param.vcltipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, lr_param.vcltipcod
   end if

   whenever error continue
   open c_cty22g02_097 using lr_param.vcltipcod
   fetch c_cty22g02_097 into l_count
   whenever error stop
   close c_cty22g02_097

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavcltip>."
      return lr_valida.*, lr_param.vcltipcod
   end if

   if l_count <= 0 then
      let lr_param.vcltipcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.vcltipcod

#========================================================================
end function # Fim funcao cty22g02_valida_tipo_veiculo2
#========================================================================

#=======================================================
function cty22g02_valida_canal_venda(lr_param)
#=======================================================

   define lr_param record
      vndcnldes like datkitavndcnl.vndcnldes
   end record

   define lr_valida record
       erro          smallint
      ,warn          smallint
      ,codigo        smallint
      ,campo         char(50)
      ,valor         char(50)
   end record

   define l_vndcnlcod like datkitavndcnl.vndcnlcod
   let l_vndcnlcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   call cty22g02_retira_acentos(lr_param.vndcnldes)
   returning lr_param.vndcnldes

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CANAL DE VENDA (vndcnldes)"
   let lr_valida.valor  = lr_param.vndcnldes clipped

   if lr_param.vndcnldes clipped = " " or
      lr_param.vndcnldes is null then

      let l_vndcnlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, l_vndcnlcod
   end if

   let lr_param.vndcnldes = upshift(lr_param.vndcnldes)

   whenever error continue
   open c_cty22g02_094 using lr_param.vndcnldes
   fetch c_cty22g02_094 into l_vndcnlcod
   whenever error stop
   close c_cty22g02_094

   if sqlca.sqlcode = notfound or l_vndcnlcod is null or l_vndcnlcod = 0 then
      let l_vndcnlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, l_vndcnlcod
   end if

   if sqlca.sqlcode < 0 then
      let l_vndcnlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavndcnl>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
   end if

  return lr_valida.*, l_vndcnlcod

#========================================================================
end function # Fim funcao cty22g02_valida_canal_venda
#========================================================================


#=======================================================
function cty22g02_valida_canal_venda2(lr_param)
#=======================================================

   define lr_param record
      vndcnlcod like datkitavndcnl.vndcnlcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CANAL DE VENDA (vndcnlcod)"
   let lr_valida.valor  = lr_param.vndcnlcod clipped
   let l_count = 0

   if lr_param.vndcnlcod is null or
      lr_param.vndcnlcod = " " or
      lr_param.vndcnlcod = 9999 then

      let lr_param.vndcnlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 6 #VALOR INVALIDO - NENHUM CODIGO FOI ENCONTRADO
      return lr_valida.*, lr_param.vndcnlcod
   end if

   whenever error continue
   open c_cty22g02_096 using lr_param.vndcnlcod
   fetch c_cty22g02_096 into l_count
   whenever error stop
   close c_cty22g02_096

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitavndcnl>."
      return lr_valida.*, lr_param.vndcnlcod
   end if

   if l_count <= 0 then
      let lr_param.vndcnlcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO CADASTRADO
   end if

  return lr_valida.*, lr_param.vndcnlcod

#========================================================================
end function # Fim funcao cty22g02_valida_canal_venda2
#========================================================================



#=======================================================
function cty22g02_valida_servico_prestado(lr_param)
#=======================================================

   define lr_param record
      asisrvcod like datkitaasisrv.itaasisrvcod
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.warn = 0
   let lr_valida.campo = "CODIGO DO SERVICO PRESTADO (itaasisrvcod)"
   let lr_valida.valor  = lr_param.asisrvcod clipped
   let l_count = 0

   if lr_param.asisrvcod is null or
      lr_param.asisrvcod clipped = "" or
      lr_param.asisrvcod = 9999 then

      let lr_param.asisrvcod = 9999 #NAO INFORMADO
      let lr_valida.warn = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*, lr_param.asisrvcod
   end if

   whenever error continue
   open c_cty22g02_091 using lr_param.asisrvcod
   fetch c_cty22g02_091 into l_count
   whenever error stop
   close c_cty22g02_091

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
end function # Fim funcao cty22g02_valida_servico_prestado
#========================================================================

{
#=======================================================
function cty22g02_valida_datas(lr_param)
#=======================================================

   define lr_param record
       aplvigincdat     like datmdetitaasiarq.itaaplvigincdat
      ,aplvigfnldat     like datmdetitaasiarq.itaaplvigfnldat
      ,adniclhordat     like datmdetitaasiarq.adniclhordat
      ,pcshordat        like datmdetitaasiarq.itapcshordat
      ,asiincdat        like datmdetitaasiarq.asiincdat
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
      call cty22g02_prepare()
   end if

   initialize lr_valida.* to null
   let lr_valida.erro = 0
   let lr_valida.campo = "CODIGO DO PLANO (itasgrplncod)"
   let lr_valida.valor  = lr_param.sgrplncod clipped
   let l_count = 0

   if lr_param.sgrplncod is null or
      lr_param.sgrplncod clipped = "" or
      lr_param.sgrplncod = 0 then

      let lr_valida.erro = 1
      let lr_valida.codigo = 2 #CAMPO VAZIO (NAO INFORMADO)
      return lr_valida.*
   end if

   whenever error continue
   open c_cty22g02_057 using lr_param.sgrplncod
   fetch c_cty22g02_057 into l_count
   whenever error stop
   close c_cty22g02_057

   if sqlca.sqlcode <> 0 then
      let lr_valida.erro = 1
      let lr_valida.valor  = "Erro (",sqlca.sqlcode clipped, ") ao acessar a tabela <datkitasgrpln>."
      let lr_valida.codigo = 5 #ERRO DE BANCO DE DADOS
      return lr_valida.*
   end if

  if l_count <= 0 then
      let lr_valida.erro = 1
      let lr_valida.codigo = 1 #CODIGO INVALIDO - NAO ENCONTRADO
  end if

  return lr_valida.*

#========================================================================
end function # Fim funcao cty22g02_valida_datas
#========================================================================
}
#=======================================================
function cty22g02_valida_empresa(lr_param)
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
      call cty22g02_prepare()
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
   open c_cty22g02_058 using lr_param.empasidcod
   fetch c_cty22g02_058 into l_count
   whenever error stop
   close c_cty22g02_058

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
end function # Fim funcao cty22g02_valida_empresa
#========================================================================
#=======================================================
function cty22g02_valida_cgccpf(lr_param)
#=======================================================

   define lr_param record
      segcgccpfnum like datmdetitaasiarq.segcgccpfnum
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
      call cty22g02_prepare()
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
end function # Fim funcao cty22g02_valida_cgccpf
#========================================================================


#=======================================================
function cty22g02_libera_inconsistencia(lr_param) # Por numero de apolice
#=======================================================
   define lr_param record
      apolice     like datmitaasiarqico.itaaplnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null


   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   #let g_issk.funmat = 5849
   #let g_issk.empcod = 1
   #let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO


   whenever error continue
   execute p_cty22g02_052 using g_issk.usrtip
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,lr_param.apolice
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") na liberacao da INCONSISTENCIA (1). Tabela: <datmitaasiarqico>."
   else
      let lr_erro.sqlcode = 0
   end if

   return lr_erro.*

#=======================================================
end function # Fim da funcao cty22g02_libera_inconsistencia
#=======================================================

#=======================================================
function cty22g02_libera_inconsistencia2(lr_param) # Pela chave da inconsistencia
#=======================================================
   define lr_param record
      itaasiarqvrsnum   like datmitaasiarqico.itaasiarqvrsnum
     ,pcsseqnum         like datmitaasiarqico.pcsseqnum
     ,itaasiarqlnhnum   like datmitaasiarqico.itaasiarqlnhnum
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null


   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
   #let g_issk.funmat = 5849
   #let g_issk.empcod = 1
   #let g_issk.usrtip = 'F'
   # GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO


   whenever error continue
   execute p_cty22g02_052b using g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,lr_param.itaasiarqvrsnum
                                ,lr_param.pcsseqnum
                                ,lr_param.itaasiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") na liberacao da INCONSISTENCIA (2). Tabela: <datmitaasiarqico>."
   else
      let lr_erro.sqlcode = 0
   end if

   return lr_erro.*

#=======================================================
end function # Fim da funcao cty22g02_libera_inconsistencia2
#=======================================================

#=======================================================
function cty22g02_busca_sequencia_continua(lr_apolice_atual)
#=======================================================
   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   define l_sequencia   like datmitaapl.aplseqnum
   define l_count       smallint

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   open c_cty22g02_080 using lr_apolice_atual.ciacod
                          ,lr_apolice_atual.ramcod
                          ,lr_apolice_atual.aplnum
   fetch c_cty22g02_080 into l_sequencia
   whenever error stop
   close c_cty22g02_080

   let lr_erro.sqlcode = sqlca.sqlcode

   if lr_erro.sqlcode = notfound then
      return lr_erro.*, 0
   end if

   if lr_erro.sqlcode <> 0 then
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar a sequencia da APOLICE. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   whenever error continue
   open c_cty22g02_053 using lr_apolice_atual.ciacod
                          ,lr_apolice_atual.ramcod
                          ,lr_apolice_atual.aplnum
                          ,l_sequencia
                          ,lr_apolice_atual.aplitmnum
   fetch c_cty22g02_053 into l_count
   whenever error stop
   close c_cty22g02_053

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
end function # Fim da funcao cty22g02_busca_sequencia_continua
#=======================================================

#=================================================================
function cty22g02_carrega_cancelamento(lr_apolice_atual, lr_hist_process, lr_param)
#=================================================================

   define lr_apolice_atual record
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

   define lr_param record
      aplcanmtvcod      like datmitaaplitm.itaaplcanmtvcod
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   initialize lr_erro.* to null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   # Recupera a ultima sequencia da apolice a ser cancelada
   whenever error continue
   open c_cty22g02_075 using lr_apolice_atual.ciacod
                            ,lr_apolice_atual.ramcod
                            ,lr_apolice_atual.aplnum
   fetch c_cty22g02_075 into lr_apolice_atual.aplseqnum
   whenever error stop
   close c_cty22g02_075

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na recuperacao da sequencial atual CANCELAMENTO. Tabela: <datmitaapl>."
      return lr_erro.*, 0
   end if

   if lr_apolice_atual.aplseqnum is null then
      # Ignora os casos que n�o foram encontrados

      let lr_erro.sqlcode = 0
      return lr_erro.*, 0
   end if

   # Cria nova sequencia copiando os dados de apolice da sequencia anterior
   whenever error continue
   execute p_cty22g02_076 using lr_apolice_atual.ciacod
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
   execute p_cty22g02_077 using lr_hist_process.asiarqvrsnum
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
   execute p_cty22g02_078 using lr_apolice_atual.ciacod
                               ,lr_apolice_atual.ramcod
                               ,lr_apolice_atual.aplnum
                               ,lr_apolice_atual.aplseqnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no CANCELAMENTO do item da apolice (1). Tabela <datmitaaplitm>."
      return lr_erro.*, 0
   end if

   if lr_apolice_atual.aplitmnum is null or
      lr_apolice_atual.aplitmnum = 0 then
      # Se nao tiver indicando o item, cancela todos

      whenever error continue
      execute p_cty22g02_079 using lr_param.aplcanmtvcod
                                  ,lr_apolice_atual.ciacod
                                  ,lr_apolice_atual.ramcod
                                  ,lr_apolice_atual.aplnum
                                  ,lr_apolice_atual.aplseqnum
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_erro.sqlcode = sqlca.sqlcode
         let lr_erro.mens = "Erro (", sqlca.sqlcode clipped, ") no CANCELAMENTO do item da apolice (2). Tabela <datmitaaplitm>."
         return lr_erro.*, 0
      end if

   else # Cancela o item individualmente

      whenever error continue
      execute p_cty22g02_079b using lr_param.aplcanmtvcod
                                   ,lr_apolice_atual.ciacod
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

   end if

   # Soma 1 pois o cancelamento do item X gera a sequencia X+1
   let lr_apolice_atual.aplseqnum = lr_apolice_atual.aplseqnum + 1

   return lr_erro.*, lr_apolice_atual.aplseqnum

#=================================================================
end function # Fim da Fun��o cty22g02_carrega_cancelamento
#=================================================================

#=======================================================
function cty22g02_carrega_tabela_item(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record


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

   define lr_item record
       ciacod           like datmitaaplitm.itaciacod
      ,ramcod           like datmitaaplitm.itaramcod
      ,aplnum           like datmitaaplitm.itaaplnum
      ,aplseqnum        like datmitaaplitm.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,autchsnum        like datmitaaplitm.autchsnum
      ,autplcnum        like datmitaaplitm.autplcnum
      ,autfbrnom        like datmitaaplitm.autfbrnom
      ,autlnhnom        like datmitaaplitm.autlnhnom
      ,autmodnom        like datmitaaplitm.autmodnom
      ,vclcrgtipcod     like datmitaaplitm.itavclcrgtipcod
      ,autfbrano        like datmitaaplitm.autfbrano
      ,autmodano        like datmitaaplitm.autmodano
      ,autcmbnom        like datmitaaplitm.autcmbnom
      ,autcornom        like datmitaaplitm.autcornom
      ,autpintipdes     like datmitaaplitm.autpintipdes
      ,okmflg           like datmitaaplitm.okmflg
      ,impautflg        like datmitaaplitm.impautflg
      ,casfrqvlr        like datmitaaplitm.casfrqvlr
      ,rsclclcepnum     like datmitaaplitm.rsclclcepnum
      ,rcslclcepcmpnum  like datmitaaplitm.rcslclcepcmpnum
      ,porvclcod        like datmitaaplitm.porvclcod
      ,itaasisrvcod     like datmitaaplitm.itaasisrvcod
      ,itarsrcaosrvcod  like datmitaaplitm.itarsrcaosrvcod
      ,rsrcaogrtcod     like datmitaaplitm.rsrcaogrtcod
      ,ubbcod           like datmitaaplitm.ubbcod
      ,itasgrplncod     like datmitaaplitm.itasgrplncod
      ,itaempasicod     like datmitaaplitm.itaempasicod
      ,asiincdat        like datmitaaplitm.asiincdat
      ,itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod
      ,itaclisgmcod     like datmitaaplitm.itaclisgmcod
      ,vcltipcod        like datmitaaplitm.vcltipcod
      ,bldflg           like datmitaaplitm.bldflg
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null
   initialize lr_item.* to null

   let lr_item.ciacod            = lr_apolice_atual.ciacod
   let lr_item.ramcod            = lr_apolice_atual.ramcod
   let lr_item.aplnum            = lr_apolice_atual.aplnum
   let lr_item.aplseqnum         = lr_apolice_atual.aplseqnum
   let lr_item.aplitmnum         = lr_apolice_atual.aplitmnum
   let lr_item.aplitmsttcod      = lr_dados.mvtsttcod
   let lr_item.autchsnum         = lr_dados.autchsnum
   let lr_item.autplcnum         = lr_dados.autplcnum
   let lr_item.autfbrnom         = lr_dados.autfbrnom
   let lr_item.autlnhnom         = lr_dados.autlnhnom
   let lr_item.autmodnom         = lr_dados.autmodnom
   let lr_item.vclcrgtipcod      = lr_dados.auxvclcrgtipcod #0 # O CODIGO DEVE SER BUSCADO
   let lr_item.autfbrano         = lr_dados.autfbrano
   let lr_item.autmodano         = lr_dados.autmodano
   let lr_item.autcmbnom         = lr_dados.autcmbnom
   let lr_item.autcornom         = lr_dados.autcornom
   let lr_item.autpintipdes      = lr_dados.autpintipdes
   let lr_item.okmflg            = lr_dados.okmflg
   let lr_item.impautflg         = lr_dados.impautflg
   let lr_item.casfrqvlr         = lr_dados.casfrqvlr/100
   let lr_item.rsclclcepnum      = lr_dados.rsclclcepnum[1,5]
   let lr_item.rcslclcepcmpnum   = lr_dados.rsclclcepnum[6,8]
   let lr_item.porvclcod         = lr_dados.porvclcod
   let lr_item.itaasisrvcod      = lr_dados.auxasisrvcod
   let lr_item.itarsrcaosrvcod   = lr_dados.auxrsrcaosrvcod
   let lr_item.rsrcaogrtcod      = lr_dados.auxrsrcaogrtcod
   let lr_item.ubbcod            = lr_dados.auxubbcod
   let lr_item.itasgrplncod      = lr_dados.auxsgrplncod
   let lr_item.itaempasicod      = lr_dados.auxempasicod
   let lr_item.asiincdat         = lr_dados.asiincdat
   let lr_item.itaaplcanmtvcod   = lr_dados.auxaplcanmtvcod
   let lr_item.itaclisgmcod      = lr_dados.auxclisgmcod
   let lr_item.vcltipcod         = lr_dados.auxvcltipcod
   let lr_item.bldflg            = lr_dados.bldflg


   # Se a data de inicio de assistencia vier em branco, assumir a data de inicio de vigencia
   if lr_item.asiincdat is null or
      lr_item.asiincdat = " " then
      let lr_item.asiincdat = lr_dados.aplvigincdat
   end if

   #
   #display "ciacod         : ", lr_item.ciacod
   #display "ramcod         : ", lr_item.ramcod
   #display "aplnum         : ", lr_item.aplnum
   #display "aplseqnum      : ", lr_item.aplseqnum
   #display "aplitmnum      : ", lr_item.aplitmnum
   #display "aplitmsttcod   : ", lr_item.aplitmsttcod
   #display "autchsnum      : ", lr_item.autchsnum
   #display "autplcnum      : ", lr_item.autplcnum
   #display "autfbrnom      : ", lr_item.autfbrnom
   #display "autlnhnom      : ", lr_item.autlnhnom
   #display "autmodnom      : ", lr_item.autmodnom
   #display "vclcrgtipcod   : ", lr_item.vclcrgtipcod
   #display "autfbrano      : ", lr_item.autfbrano
   #display "autmodano      : ", lr_item.autmodano
   #display "autcmbnom      : ", lr_item.autcmbnom
   #display "autcornom      : ", lr_item.autcornom
   #display "autpintipdes   : ", lr_item.autpintipdes
   #display "okmflg         : ", lr_item.okmflg
   #display "impautflg      : ", lr_item.impautflg
   #display "casfrqvlr      : ", lr_item.casfrqvlr
   #display "rsclclcepnum   : ", lr_item.rsclclcepnum
   #display "rcslclcepcmpnum: ", lr_item.rcslclcepcmpnum
   #display "porvclcod      : ", lr_item.porvclcod
   #display "itaasisrvcod   : ", lr_item.itaasisrvcod
   #display "itarsrcaosrvcod: ", lr_item.itarsrcaosrvcod
   #display "rsrcaogrtcod   : ", lr_item.rsrcaogrtcod
   #display "ubbcod         : ", lr_item.ubbcod
   #display "itasgrplncod   : ", lr_item.itasgrplncod
   #display "itaempasicod   : ", lr_item.itaempasicod
   #display "asiincdat      : ", lr_item.asiincdat
   #display "itaaplcanmtvcod: ", lr_item.itaaplcanmtvcod
   #display "itaclisgmcod   : ", lr_item.itaclisgmcod
   #display "vcltipcod      : ", lr_item.vcltipcod
   #display "bldflg         : ", lr_item.bldflg
   #prompt "<ENTER>" for lr_erro.mens
   #

   whenever error continue
   execute p_cty22g02_069 using lr_item.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao do ITEM DA APOLICE. Tabela <datmitaaplitm>."
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#=======================================================
end function  # Fim funcao cty22g02_carrega_tabela_item
#=======================================================
#========================================================================
function cty22g02_gera_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   open c_cty22g02_062 using lr_hist_process.asiarqvrsnum
   fetch c_cty22g02_062 into lr_hist_process.pcsseqnum
   whenever error stop
   close c_cty22g02_062

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar sequencia do PROCESSAMENTO. Tabela <datmitaarqpcshst>."
      return lr_erro.*
   end if

   whenever error continue
   execute p_cty22g02_063 using lr_hist_process.asiarqvrsnum
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
end function # Fim da funcao cty22g02_gera_processamento
#========================================================================

#========================================================================
function cty22g02_encerra_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   execute p_cty22g02_081 using lr_hist_process.lnhtotqtd
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
end function # Fim da funcao cty22g02_encerra_processamento
#========================================================================
#========================================================================
function cty22g02_atualiza_processamento(lr_hist_process)
#========================================================================

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

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   execute p_cty22g02_082 using lr_hist_process.lnhtotqtd
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
end function # Fim da funcao cty22g02_atualiza_processamento
#========================================================================

#=======================================================
function cty22g02_gera_sequencia_apolice(lr_apolice_atual)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
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
      call cty22g02_prepare()
   end if

   whenever error continue
   open c_cty22g02_067 using lr_apolice_atual.ciacod,
                            lr_apolice_atual.ramcod,
                            lr_apolice_atual.aplnum
   fetch c_cty22g02_067 into l_sequencia
   whenever error stop
   close c_cty22g02_067

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") no calculo da sequencia para CARGA da apolice. Tabela <datmitaapl>."
      return lr_erro.*, 0
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*, l_sequencia

#=======================================================
end function  # Fim funcao cty22g02_gera_sequencia_apolice
#=======================================================

#=======================================================
function cty22g02_carrega_tabela_apolice(lr_apolice_atual, lr_dados, lr_hist_process)
#=======================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
   end record


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

   define lr_apolice record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,prpnum           like datmitaapl.itaprpnum
      ,aplvigincdat     like datmitaapl.itaaplvigincdat
      ,aplvigfnldat     like datmitaapl.itaaplvigfnldat
      ,segnom           like datmitaapl.segnom
      ,pestipcod        like datmitaapl.pestipcod
      ,segcgccpfnum     like datmitaapl.segcgccpfnum
      ,segcgcordnum     like datmitaapl.segcgcordnum
      ,segcgccpfdig     like datmitaapl.segcgccpfdig
      ,prdcod           like datmitaapl.itaprdcod
      #,sgrplncod        like datmitaapl.itasgrplncod   # RETIRAR
      #,empasicod        like datmitaapl.itaempasicod   # RETIRAR
      #,asisrvcod        like datmitaapl.itaasisrvcod   # RETIRAR
      ,cliscocod        like datmitaapl.itacliscocod
      #,rsrcaosrvcod     like datmitaapl.itarsrcaosrvcod   # RETIRAR
      #,clisgmcod        like datmitaapl.itaclisgmcod   # RETIRAR
      #,aplcanmtvcod     like datmitaapl.itaaplcanmtvcod   # RETIRAR
      #,rsrcaogrtcod     like datmitaapl.rsrcaogrtcod   # RETIRAR
      #,asiincdat        like datmitaapl.asiincdat   # RETIRAR
      ,corsuscod        like datmitaapl.itacorsuscod
      ,seglgdnom        like datmitaapl.seglgdnom
      ,seglgdnum        like datmitaapl.seglgdnum
      ,segendcmpdes     like datmitaapl.segendcmpdes
      ,segbrrnom        like datmitaapl.segbrrnom
      ,segcidnom        like datmitaapl.segcidnom
      ,segufdsgl        like datmitaapl.segufdsgl
      ,segcepnum        like datmitaapl.segcepnum
      ,segcepcmpnum     like datmitaapl.segcepcmpnum
      ,segresteldddnum  like datmitaapl.segresteldddnum
      ,segrestelnum     like datmitaapl.segrestelnum
      ,adniclhordat     like datmitaapl.adniclhordat
      ,asiarqvrsnum     like datmitaapl.itaasiarqvrsnum
      ,pcsseqnum        like datmitaapl.pcsseqnum
      #,ubbcod           like datmitaapl.ubbcod   # RETIRAR
      ,succod           like datmitaapl.succod
      ,corsus           like datmitaapl.corsus
      ,vipsegflg        like datmitaapl.vipsegflg
      ,segmaiend        like datmitaapl.segmaiend
      ,frtmdlcod        like datmitaapl.frtmdlcod
      ,vndcnlcod        like datmitaapl.vndcnlcod
   end record

   define lr_cgccpf record
       tipoPessoa   char(1)
      ,cgccpfnumdig char(20)
   end record

   define lr_sucursal    record
      inpcod            like gcaksusep.inpcod
     ,succod            like pcgksuc.succod
     ,msgerr            char(78)
   end record

   define l_data_hora char(20)

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
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
   let lr_apolice.prpnum            = lr_dados.prpnum
   let lr_apolice.aplvigincdat      = lr_dados.aplvigincdat
   let lr_apolice.aplvigfnldat      = lr_dados.aplvigfnldat
   let lr_apolice.segnom            = lr_dados.segnom
   let lr_apolice.pestipcod         = lr_dados.pestipcod
   #let lr_apolice.segcgccpfnum      = 0 # Sera preenchido no proximo passo
   #let lr_apolice.segcgcordnum      = 0 # Sera preenchido no proximo passo
   #let lr_apolice.segcgccpfdig      = 0 # Sera preenchido no proximo passo
   let lr_apolice.prdcod            = lr_dados.auxprdcod
   #let lr_apolice.sgrplncod         = lr_dados.auxsgrplncod   # RETIRAR
   #let lr_apolice.empasicod         = lr_dados.auxempasicod   # RETIRAR
   #let lr_apolice.asisrvcod         = lr_dados.auxasisrvcod   # RETIRAR
   let lr_apolice.cliscocod         = lr_dados.auxcliscocod
   #let lr_apolice.rsrcaosrvcod      = lr_dados.auxrsrcaosrvcod   # RETIRAR
   #let lr_apolice.clisgmcod         = lr_dados.auxclisgmcod    # RETIRAR
   #let lr_apolice.aplcanmtvcod      = lr_dados.auxaplcanmtvcod   # RETIRAR
   #let lr_apolice.rsrcaogrtcod      = lr_dados.auxrsrcaogrtcod   # RETIRAR
   #let lr_apolice.asiincdat         = lr_dados.asiincdat   # RETIRAR
   let lr_apolice.corsuscod         = 0 # Novo campo criado: CORSUS
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
   let lr_apolice.pcsseqnum         = lr_hist_process.pcsseqnum
   #let lr_apolice.ubbcod            = lr_dados.auxubbcod   # RETIRAR
   let lr_apolice.succod            = 0 # O CODIGO DEVE SER BUSCADO
   let lr_apolice.corsus            = lr_dados.corsuscod
   let lr_apolice.vipsegflg         = "N" # Buscar do ultimo sequencial da apolice, se houver
   let lr_apolice.segmaiend         = " " # Buscar do ultimo sequencial da apolice, se houver
   let lr_apolice.frtmdlcod         = lr_dados.auxfrtmdlcod
   let lr_apolice.vndcnlcod         = lr_dados.auxvndcnlcod


   # Buscar flag de VIP e Endereco de E-mail da apolice quando for atualizacao
   # Considero apenas acima de 1 pois o primeiro sequencial significa que eh apolice nova
   if lr_apolice_atual.aplseqnum > 1 then

      whenever error continue
      open c_cty22g02_072 using lr_apolice_atual.ciacod,
                                lr_apolice_atual.ramcod,
                                lr_apolice_atual.aplnum,
                                lr_apolice_atual.aplseqnum
      fetch c_cty22g02_072 into lr_apolice.vipsegflg,
                                lr_apolice.segmaiend
      whenever error stop
      close c_cty22g02_072

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

   call cty22g02_desmembra_cgccpf(lr_cgccpf.*)
   returning lr_apolice.segcgccpfnum
            ,lr_apolice.segcgcordnum
            ,lr_apolice.segcgccpfdig


   # Busca codigo da sucursal a partir da SUSEP do corretor
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


   whenever error continue
      execute p_cty22g02_068 using lr_apolice.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") na insercao de APOLICE. Tabela <datmitaapl>."
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function  # Fim funcao cty22g02_carrega_tabela_apolice
#========================================================================


#========================================================================
function cty22g02_atualiza_inconsistencia(lr_apolice_atual, lr_arquivo)
#========================================================================
   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
      ,qtdinconsist     smallint
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

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   initialize lr_erro.* to null

   whenever error continue
   execute p_cty22g02_073 using lr_apolice_atual.aplseqnum
                               ,lr_arquivo.asiarqvrsnum
                               ,lr_arquivo.pcsseqnum
                               ,lr_arquivo.asiarqlnhnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao atualizar INCONSISTENCIA <datmitaasiarqico>. ",
                         "Apolice/Item: ", lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped
      return lr_erro.*
   end if

   let lr_erro.sqlcode = 0

   return lr_erro.*



#========================================================================
end function  # Fim funcao cty22g02_atualiza_inconsistencia
#========================================================================


#========================================================================
function cty22g02_carrega_inconsistencia(lr_apolice_atual, lr_valida, lr_arquivo)
#========================================================================

   define lr_apolice_atual record
       ciacod           like datmitaapl.itaciacod
      ,ramcod           like datmitaapl.itaramcod
      ,aplnum           like datmitaapl.itaaplnum
      ,aplseqnum        like datmitaapl.aplseqnum
      ,aplitmnum        like datmitaaplitm.itaaplitmnum
      ,aplitmsttcod     like datmitaaplitm.itaaplitmsttcod
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
       asiarqvrsnum  like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum     like datmitaasiarqico.pcsseqnum
      ,asiarqlnhnum  like datmitaasiarqico.itaasiarqlnhnum
   end record

   define lr_inconsistencia record
       asiarqvrsnum     like datmitaasiarqico.itaasiarqvrsnum
      ,pcsseqnum        like datmitaasiarqico.pcsseqnum
      ,itaasiarqlnhnum  like datmitaasiarqico.itaasiarqlnhnum
      ,icoseqnum        like datmitaasiarqico.icoseqnum
      ,asiarqicotipcod  like datmitaasiarqico.itaasiarqicotipcod
      ,icocponom        like datmitaasiarqico.icocponom
      ,icocpocntdes     like datmitaasiarqico.icocpocntdes
      ,ciacod           like datmitaasiarqico.itaciacod
      ,ramcod           like datmitaasiarqico.itaramcod
      ,aplnum           like datmitaasiarqico.itaaplnum
      ,aplitmnum        like datmitaasiarqico.itaaplitmnum
      ,libicoflg        like datmitaasiarqico.libicoflg
      ,aplseqnum        like datmitaasiarqico.aplseqnum
      ,impicoflg        like datmitaasiarqico.impicoflg
   end record

   define lr_erro record
       sqlcode  smallint
      ,mens     char(80)
   end record

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
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
   open c_cty22g02_064 using lr_arquivo.*
   fetch c_cty22g02_064 into lr_inconsistencia.icoseqnum
   whenever error stop
   close c_cty22g02_064

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao recuperar sequencia da INCONSISTENCIA. Tabela <datmitaasiarqico>."
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
   execute p_cty22g02_065 using lr_inconsistencia.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_erro.sqlcode = sqlca.sqlcode
      let lr_erro.mens = "Erro (", lr_erro.sqlcode clipped, ") ao inserir INCONSISTENCIA <datmitaasiarqico>. ",
                         "Apolice/Item: ", lr_apolice_atual.aplnum clipped, "/", lr_apolice_atual.aplitmnum clipped
      return lr_erro.*
   end if

   if mr_retorno.processo then

      call cty22g02_carrega_relatorio(lr_inconsistencia.pcsseqnum           ,
                                      lr_inconsistencia.asiarqvrsnum        ,
                                      lr_inconsistencia.asiarqicotipcod     ,
                                      lr_inconsistencia.ramcod              ,
                                      lr_inconsistencia.ciacod              ,
                                      lr_inconsistencia.itaasiarqlnhnum     ,
                                      lr_inconsistencia.icoseqnum           ,
                                      lr_inconsistencia.icocponom           ,
                                      lr_inconsistencia.icocpocntdes        ,
                                      lr_inconsistencia.aplnum              ,
                                      lr_inconsistencia.aplitmnum           ,
                                      lr_inconsistencia.aplseqnum           ,
                                      lr_inconsistencia.libicoflg           ,
                                      lr_inconsistencia.impicoflg           )
    end if

   let lr_erro.sqlcode = 0

   return lr_erro.*

#========================================================================
end function # Fim da funcao cty22g02_carrega_inconsistencia
#========================================================================

#========================================================================
function cty22g02_desmembra_cgccpf(lr_param)
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
end function # Fim da funcao cty22g02_desmembra_cgccpf
#========================================================================

#========================================================================
function cty22g02_trim(l_param)
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
end function # Fim da funcao cty22g02_trim
#========================================================================

#========================================================================
function cty22g02_retira_acentos(l_param)
#========================================================================
   define l_param char(100)
   define l_posi  smallint

   let l_posi = 1
   while l_posi <= 100
      case l_param[l_posi]
         when '�' let l_param[l_posi] = 'a'
         when '�' let l_param[l_posi] = 'e'
         when '�' let l_param[l_posi] = 'i'
         when '�' let l_param[l_posi] = 'o'
         when '�' let l_param[l_posi] = 'u'
         when '�' let l_param[l_posi] = 'a'
         when '�' let l_param[l_posi] = 'e'
         when '�' let l_param[l_posi] = 'i'
         when '�' let l_param[l_posi] = 'o'
         when '�' let l_param[l_posi] = 'u'
         when '�' let l_param[l_posi] = 'a'
         when '�' let l_param[l_posi] = 'e'
         when '�' let l_param[l_posi] = 'i'
         when '�' let l_param[l_posi] = 'o'
         when '�' let l_param[l_posi] = 'u'
         when '�' let l_param[l_posi] = 'a'
         when '�' let l_param[l_posi] = 'e'
         when '�' let l_param[l_posi] = 'i'
         when '�' let l_param[l_posi] = 'o'
         when '�' let l_param[l_posi] = 'u'
         when '�' let l_param[l_posi] = 'a'
         when '�' let l_param[l_posi] = 'o'
         when '�' let l_param[l_posi] = 'n'
         when '�' let l_param[l_posi] = 'c'
         when '�' let l_param[l_posi] = 'A'
         when '�' let l_param[l_posi] = 'E'
         when '�' let l_param[l_posi] = 'I'
         when '�' let l_param[l_posi] = 'O'
         when '�' let l_param[l_posi] = 'U'
         when '�' let l_param[l_posi] = 'A'
         when '�' let l_param[l_posi] = 'E'
         when '�' let l_param[l_posi] = 'I'
         when '�' let l_param[l_posi] = 'O'
         when '�' let l_param[l_posi] = 'U'
         when '�' let l_param[l_posi] = 'A'
         when '�' let l_param[l_posi] = 'E'
         when '�' let l_param[l_posi] = 'I'
         when '�' let l_param[l_posi] = 'O'
         when '�' let l_param[l_posi] = 'U'
         when '�' let l_param[l_posi] = 'A'
         when '�' let l_param[l_posi] = 'E'
         when '�' let l_param[l_posi] = 'I'
         when '�' let l_param[l_posi] = 'O'
         when '�' let l_param[l_posi] = 'U'
         when '�' let l_param[l_posi] = 'A'
         when '�' let l_param[l_posi] = 'O'
         when '�' let l_param[l_posi] = 'N'
         when '�' let l_param[l_posi] = 'C'
         otherwise call cty22g02_retira_simbolos(l_param[l_posi])
                   returning l_param[l_posi]
      end case
      let l_posi = l_posi + 1
   end while

   return l_param clipped

#========================================================================
end function # Fim da funcao cty22g02_retira_acentos
#========================================================================
#========================================================================
function cty22g02_retira_simbolos(l_param)
#========================================================================
   define l_param    char(100)
   define l_pos_ini  smallint
   define l_pos_fim  smallint
   let l_pos_ini = 128
   let l_pos_fim = 254
   while l_pos_ini <= l_pos_fim
   	  if l_param = ascii(l_pos_ini) then
   	      initialize l_param to null
   	  end if
   	  let l_pos_ini = l_pos_ini + 1
   end while
   return l_param
end function

#=======================================================
function cty22g02_valida_segmento_garantia(lr_param)
#=======================================================
   define lr_param     record
          itasgmcod    like datkitaclisgm.itasgmcod,
          rsrcaogrtcod like datkitarsrcaogar.itarsrcaogrtcod
   end record

   define l_itaclisgmcod like datkitaclisgm.itaclisgmcod
   define l_rsrcaogrtcod like datkitarsrcaogar.rsrcaogrtcod

   let l_rsrcaogrtcod = null
   let l_itaclisgmcod = null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

     whenever error continue
     open c_cty22g02_084 using lr_param.rsrcaogrtcod
     fetch c_cty22g02_084 into l_rsrcaogrtcod
     whenever error stop
     close c_cty22g02_084

     whenever error continue
     open c_cty22g02_055 using lr_param.itasgmcod
     fetch c_cty22g02_055 into l_itaclisgmcod
     whenever error stop
     close c_cty22g02_055

   if l_itaclisgmcod is null then
    if l_rsrcaogrtcod = 1 or l_rsrcaogrtcod = 2 then
         let l_itaclisgmcod = 0
    end if
   end if


  return l_itaclisgmcod,
         l_rsrcaogrtcod

#========================================================================
end function # Fim funcao cty22g02_valida_segmento_garantia
#========================================================================

#=======================================================
function cty22g02_recupera_segmento_sequencia(lr_param)
#=======================================================

define lr_param     record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,itasgmcod    like datkitaclisgm.itasgmcod
end record

define lr_retorno     record
   itasgmcod       like datkitaclisgm.itasgmcod,
   aplseqnum       like datmitaapl.aplseqnum   ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat
end record

initialize lr_retorno.* to null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if

   let lr_retorno.itasgmcod = lr_param.itasgmcod

   if lr_param.itasgmcod is null or
   	  lr_param.itasgmcod = " "   then

      #--------------------------------------------------------
      # Recupera o Segmento da Apolice Original
      #--------------------------------------------------------
      whenever error continue
      open c_cty22g02_099 using lr_param.itaciacod   ,
                                lr_param.itaramcod   ,
                                lr_param.itaaplnum   ,
                                lr_param.itaaplitmnum,
                                lr_param.itaciacod   ,
                                lr_param.itaramcod   ,
                                lr_param.itaaplnum   ,
                                lr_param.itaaplitmnum

      fetch c_cty22g02_099 into lr_retorno.itasgmcod,
                                lr_retorno.aplseqnum
      whenever error stop
      close c_cty22g02_099
      #--------------------------------------------------------------------------------
      # Se a Apolice Original for N�o Segmentado Recupera Data de Vigencia da Apolice
      #--------------------------------------------------------------------------------
      if  lr_retorno.itasgmcod = 9999 then
          whenever error continue
          open c_cty22g02_100 using lr_param.itaciacod   ,
                                    lr_param.itaramcod   ,
                                    lr_param.itaaplnum   ,
                                    lr_retorno.aplseqnum

          fetch c_cty22g02_100 into lr_retorno.itaaplvigincdat
          whenever error stop
          close c_cty22g02_100
          #---------------------------------------------------------------------------
          # Se Data de Vigencia for Anterior a Data de Corte Altera para Segmento 20
          #---------------------------------------------------------------------------
          if lr_retorno.itaaplvigincdat < "01/10/2014" then
             let lr_retorno.itasgmcod = 20
          end if
      end if

   end if

   return lr_retorno.itasgmcod

#========================================================================
end function # Fim funcao cty22g02_recupera_segmento_sequencia
#========================================================================

#=======================================================
function cty22g02_acerta_segmento(lr_param)
#=======================================================

define lr_param     record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,aplseqnum    like datmitaapl.aplseqnum
   ,itasgmcod    like datkitaclisgm.itasgmcod
end record

define lr_retorno     record
   itaaplvigincdat like datmitaapl.itaaplvigincdat
  ,itasgmcod       like datkitaclisgm.itasgmcod
end record

initialize lr_retorno.* to null

   if m_prepare is null or
      m_prepare = false then
      call cty22g02_prepare()
   end if
   let lr_retorno.itasgmcod = lr_param.itasgmcod

   if lr_param.itasgmcod is null or
   	  lr_param.itasgmcod = ""    or
   	  lr_param.itasgmcod = 9999  then


      #--------------------------------------------------------------------------------
      # Se a Apolice Original for N�o Segmentado Recupera Data de Vigencia da Apolice
      #--------------------------------------------------------------------------------

      whenever error continue
      open c_cty22g02_100 using lr_param.itaciacod   ,
                                lr_param.itaramcod   ,
                                lr_param.itaaplnum   ,
                                lr_param.aplseqnum

      fetch c_cty22g02_100 into lr_retorno.itaaplvigincdat
      whenever error stop
      close c_cty22g02_100

      #---------------------------------------------------------------------------
      # Se Data de Vigencia for Anterior a Data de Corte Altera para Segmento 20
      #---------------------------------------------------------------------------
      if lr_retorno.itaaplvigincdat < "01/10/2014" then
         let lr_retorno.itasgmcod = 20
      else
      	 let lr_retorno.itasgmcod = 9999
      end if


   end if

   return lr_retorno.itasgmcod

#========================================================================
end function # Fim funcao cty22g02_acerta_segmento
#========================================================================

#========================================================================
function cty22g02_cria_arquivos(lr_param)
#========================================================================

define lr_param record
	itaasiarqvrsnum 	 like datmdetitaasiarq.itaasiarqvrsnum
end record


  initialize mr_retorno.* to null
  let mr_retorno.flg_arq1 = false
  let mr_retorno.flg_arq2 = false
  let mr_retorno.processo = true

  call f_path("DAT", "RELATO")
  returning mr_retorno.diretorio

  let mr_retorno.arquivo1 = mr_retorno.diretorio clipped, "/Impede_", lr_param.itaasiarqvrsnum using '&&&&&&', ".xls"
  let mr_retorno.arquivo2 = mr_retorno.diretorio clipped, "/naoImpede_",lr_param.itaasiarqvrsnum using '&&&&&&', ".xls"

  start report  rep1_cty22g02  to mr_retorno.arquivo1
  start report  rep2_cty22g02  to mr_retorno.arquivo2


#========================================================================
end function # Fim da funcao cty22g02_cria_arquivos
#========================================================================

#========================================================================
report rep1_cty22g02(lr_param)
#========================================================================

define lr_param record
   pcsseqnum             like datmitaasiarqico.pcsseqnum             ,
   itaasiarqvrsnum       like datmitaasiarqico.itaasiarqvrsnum       ,
   itaasiarqicotipcod    like datmitaasiarqico.itaasiarqicotipcod    ,
   itaramcod             like datmitaasiarqico.itaramcod             ,
   itaciacod             like datmitaasiarqico.itaciacod             ,
   itaasiarqlnhnum       like datmitaasiarqico.itaasiarqlnhnum       ,
   icoseqnum             like datmitaasiarqico.icoseqnum             ,
   icocponom             like datmitaasiarqico.icocponom             ,
   icocpocntdes          like datmitaasiarqico.icocpocntdes          ,
   itaaplnum             like datmitaasiarqico.itaaplnum             ,
   itaaplitmnum          like datmitaasiarqico.itaaplitmnum          ,
   aplseqnum             like datmitaasiarqico.aplseqnum             ,
   libicoflg             like datmitaasiarqico.libicoflg             ,
   coluna                char(30)
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
		       				,"<td width=80 align='center'>",lr_param.itaasiarqvrsnum    , "</td>"
		              ,"<td width=80 align='center'>",lr_param.pcsseqnum          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaasiarqlnhnum    , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icoseqnum          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaasiarqicotipcod , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icocponom          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icocpocntdes       , "</td>"
		              ,"<td width=80 align='center'>",lr_param.coluna             , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaciacod          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaramcod          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaaplnum          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaaplitmnum       , "</td>"
		              ,"<td width=80 align='center'>",lr_param.aplseqnum          , "</td>"
		              ,"<td width=80 align='center'>",lr_param.libicoflg          , "</td></tr>"

		     let mr_retorno.flg_arq1 = true

#========================================================================
end report
#========================================================================

#========================================================================
report rep2_cty22g02(lr_param)
#========================================================================

define lr_param record
   pcsseqnum              like datmitaasiarqico.pcsseqnum            ,
   itaasiarqvrsnum        like datmitaasiarqico.itaasiarqvrsnum      ,
   itaasiarqicotipcod     like datmitaasiarqico.itaasiarqicotipcod   ,
   itaramcod              like datmitaasiarqico.itaramcod            ,
   itaciacod              like datmitaasiarqico.itaciacod            ,
   itaasiarqlnhnum        like datmitaasiarqico.itaasiarqlnhnum      ,
   icoseqnum              like datmitaasiarqico.icoseqnum            ,
   icocponom              like datmitaasiarqico.icocponom            ,
   icocpocntdes           like datmitaasiarqico.icocpocntdes         ,
   itaaplnum              like datmitaasiarqico.itaaplnum            ,
   itaaplitmnum           like datmitaasiarqico.itaaplitmnum         ,
   aplseqnum              like datmitaasiarqico.aplseqnum            ,
   libicoflg              like datmitaasiarqico.libicoflg            ,
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
		       				,"<td width=80 align='center'>",lr_param.itaasiarqvrsnum     , "</td>"
		              ,"<td width=80 align='center'>",lr_param.pcsseqnum           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaasiarqlnhnum     , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icoseqnum           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaasiarqicotipcod  , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icocponom           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.icocpocntdes        , "</td>"
		              ,"<td width=80 align='center'>",lr_param.coluna              , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaciacod           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaramcod           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaaplnum           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.itaaplitmnum        , "</td>"
		              ,"<td width=80 align='center'>",lr_param.aplseqnum           , "</td>"
		              ,"<td width=80 align='center'>",lr_param.libicoflg           , "</td></tr>"

		     let mr_retorno.flg_arq2 = true

#========================================================================
end report
#========================================================================

#========================================================================
function cty22g02_carrega_relatorio(lr_param)
#========================================================================

define lr_param record
   pcsseqnum            like datmitaasiarqico.pcsseqnum           ,
   itaasiarqvrsnum      like datmitaasiarqico.itaasiarqvrsnum     ,
   itaasiarqicotipcod   like datmitaasiarqico.itaasiarqicotipcod  ,
   itaramcod            like datmitaasiarqico.itaramcod           ,
   itaciacod            like datmitaasiarqico.itaciacod           ,
   itaasiarqlnhnum      like datmitaasiarqico.itaasiarqlnhnum     ,
   icoseqnum            like datmitaasiarqico.icoseqnum           ,
   icocponom            like datmitaasiarqico.icocponom           ,
   icocpocntdes         like datmitaasiarqico.icocpocntdes        ,
   itaaplnum            like datmitaasiarqico.itaaplnum           ,
   itaaplitmnum         like datmitaasiarqico.itaaplitmnum        ,
   aplseqnum            like datmitaasiarqico.aplseqnum           ,
   libicoflg            like datmitaasiarqico.libicoflg           ,
   impicoflg            like datmitaasiarqico.impicoflg
end record

define lr_retorno record
  coluna char(30)
end record

initialize lr_retorno.* to null


   call cty22g02_carrega_coluna(lr_param.icocponom)
   returning lr_retorno.coluna


   case lr_param.impicoflg
   	 when "S"
   	 	  output to report rep1_cty22g02(lr_param.pcsseqnum           ,
                                       lr_param.itaasiarqvrsnum     ,
                                       lr_param.itaasiarqicotipcod  ,
                                       lr_param.itaramcod           ,
                                       lr_param.itaciacod           ,
                                       lr_param.itaasiarqlnhnum     ,
                                       lr_param.icoseqnum           ,
                                       lr_param.icocponom           ,
                                       lr_param.icocpocntdes        ,
                                       lr_param.itaaplnum           ,
                                       lr_param.itaaplitmnum        ,
                                       lr_param.aplseqnum           ,
                                       lr_param.libicoflg           ,
                                       lr_retorno.coluna            )
      when "N"
      	  output to report rep2_cty22g02(lr_param.pcsseqnum          ,
                                         lr_param.itaasiarqvrsnum    ,
                                         lr_param.itaasiarqicotipcod ,
                                         lr_param.itaramcod          ,
                                         lr_param.itaciacod          ,
                                         lr_param.itaasiarqlnhnum    ,
                                         lr_param.icoseqnum          ,
                                         lr_param.icocponom          ,
                                         lr_param.icocpocntdes       ,
                                         lr_param.itaaplnum          ,
                                         lr_param.itaaplitmnum       ,
                                         lr_param.aplseqnum          ,
                                         lr_param.libicoflg          ,
                                         lr_retorno.coluna           )
   end case


#========================================================================
end function # Fim da funcao cty22g02_carrega_relatorio
#========================================================================

#========================================================================
function cty22g02_finaliza_relatorio()
#========================================================================

   finish report  rep1_cty22g02
   finish report  rep2_cty22g02

   let mr_retorno.processo = false

#========================================================================
end function # Fim da funcao cty22g02_finaliza_relatorio
#========================================================================

#========================================================================
function cty22g02_carrega_coluna(lr_param)
#========================================================================

define lr_param record
  icocponom  like datmitaasiarqico.icocponom
end record

define lr_retorno record
  coluna char(30)
end record

initialize lr_retorno.* to null

   case lr_param.icocponom
   	 when "CANAL DE VENDA (vndcnldes)"
   	 	  let lr_retorno.coluna = "Coluna[659,667]"
   	 when "NUMERO DO CPF/CNPJ (segcgccpfnum"
   	 	  let lr_retorno.coluna = "Coluna[107,126]"
   	 when "CIA, RAMO, APOL, ITEM"
   	 	  let lr_retorno.coluna = "Coluna[4,22]"
   	 when "CODIGO DA COMPANHIA (itaciacod)"
   	 	  let lr_retorno.coluna = "Coluna[2,3]"
   	 when "CODIGO DA EMPRESA (itaempasicod)"
   	 	  let lr_retorno.coluna = "Coluna[54,56]"
   	 when "GARANTIA DE CARRO RESERVA (rsrcaogrtcod)"
   	 	  let lr_retorno.coluna = "Coluna[60,60]"
   	 when "CODIGO DO MOTIVO DE CANCELAMENTO (itaaplcanmtvcod)"
   	 	  let lr_retorno.coluna = "Coluna[574,575]"
   	 when "CODIGO DO PLANO (itasgrplncod)"
   	 	  let lr_retorno.coluna = "Coluna[52,53]"
   	 when "DESCRICAO DO PLANO (itasgrplndes)"
   	 	  let lr_retorno.coluna = "Coluna[629,658]"
   	 when "CODIGO DO PRODUTO (itaprdcod)"
   	 	  let lr_retorno.coluna = "Coluna[48,51]"
   	 when "CODIGO DO RAMO (itaramcod)"
   	 	  let lr_retorno.coluna = "Coluna[4,6]"
   	 when "SCORE DO CLIENTE (itacliscocod)"
   	 	  let lr_retorno.coluna = "Coluna[549,573]"
   	 when "SEGMENTO DO CLIENTE (itasgmcod)"
   	 	  let lr_retorno.coluna = "Coluna[579,580]"
   	 when "CODIGO DO SERVICO DE CARRO RESERVA (itarsrcaosrvcod)"
   	 	  let lr_retorno.coluna = "Coluna[576,578]"
   	 when "CODIGO DO SERVICO PRESTADO (itaasisrvcod)"
   	 	  let lr_retorno.coluna = "Coluna[57,59]"
   	 when "TIPO DE CARGA (itavclcrgtipcod)"
   	 	  let lr_retorno.coluna = "Coluna[473,492]"
   	 when "TIPO DE VEICULO (vcltipcod)"
   	 	  let lr_retorno.coluna = "Coluna[669,698]"
   	 when "UBB - VEICULO UNIBANCO (ubbcod)"
   	 	  let lr_retorno.coluna = "Coluna[591,591]"
   end case

   return lr_retorno.coluna

#========================================================================
end function # Fim da funcao cty22g03_carrega_coluna
#========================================================================

#========================================================================
function cty22g02_recupera_arquivos()
#========================================================================


  return mr_retorno.arquivo1,
         mr_retorno.arquivo2,
         mr_retorno.flg_arq1,
         mr_retorno.flg_arq2

#========================================================================
end function # Fim da funcao cty22g02_cria_arquivos
#========================================================================