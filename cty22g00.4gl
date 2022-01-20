#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cty22g00                                                   #
# Objetivo.......: Funcoes Itau                                               #
# Analista Resp. : Roberto Melo                                               #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: Roberto Melo                                               #
# Liberacao      : 25/01/2011                                                 #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 08/09/2011   Marcos Goes                Adaptacao dos campos do novo layout #
#                                         do Itau adicionados a global.       #
#-----------------------------------------------------------------------------#
# 13/05/2015   Roberto                    PJ                                  #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare  smallint


#------------------------------------------------------------------------------
function cty22g00_prepare()
#------------------------------------------------------------------------------

define l_sql char(2000)

   let l_sql = " select count(*) "     ,
               " from datmitaapl "     ,
               " where itaciacod = ? " ,
               " and   itaramcod = ? " ,
               " and   itaaplnum = ? "
   prepare p_cty22g00_001  from l_sql
   declare c_cty22g00_001  cursor for p_cty22g00_001

   let l_sql = " select max(aplseqnum) " ,
               " from datmitaapl       " ,
               " where itaciacod = ?   " ,
               " and   itaramcod = ?   " ,
               " and   itaaplnum = ?   "
   prepare p_cty22g00_002  from l_sql
   declare c_cty22g00_002  cursor for p_cty22g00_002
   

   let l_sql = " select b.itaciacod,   ",
               "        b.itaramcod,   ",
               "        b.itaaplnum,   ",
               "        b.aplseqnum,   ",
               "        b.itaaplitmnum,",
               "        a.succod       ",
               " from datmitaapl a  ,  ",
               "      datmitaaplitm b  ",
               " where a.itaciacod  = b.itaciacod ",
               " and   a.itaramcod  = b.itaramcod ",
               " and   a.itaaplnum  = b.itaaplnum ",
               " and   a.aplseqnum  = b.aplseqnum ",
               " and   b.autplcnum  = ?           ",
               " order by a.itaaplvigfnldat desc, ",
               "          a.aplseqnum desc        "
   prepare p_cty22g00_003  from l_sql
   declare c_cty22g00_003  cursor for p_cty22g00_003



   let l_sql = " select distinct(a.itaciacod) ",
               " from datrligitaaplitm a  ,   ",
               "      datratdlig  b           ",
               " where a.lignum  = b.lignum   ",
               " and   b.atdnum  = ?          "
   prepare p_cty22g00_004  from l_sql
   declare c_cty22g00_004  cursor for p_cty22g00_004


   let l_sql = " select a.itaciacod  ,                    ",
               "        a.itaramcod  ,                    ",
               "        a.itaaplnum  ,                    ",
               "        a.aplseqnum  ,                    ",
               "        a.succod                          ",
               " from datmitaapl a                        ",
               " where a.itaprpnum = ?                    ",
               " and aplseqnum = (select max(b.aplseqnum) ",
               " from datmitaapl b                        ",
               " where a.itaprpnum = b.itaprpnum)         "
   prepare p_cty22g00_005 from l_sql
   declare c_cty22g00_005 cursor for p_cty22g00_005


   let l_sql = " select b.itaciacod,   ",
               "        b.itaramcod,   ",
               "        b.itaaplnum,   ",
               "        b.aplseqnum,   ",
               "        b.itaaplitmnum,",
               "        a.succod       ",
               " from datmitaapl a  ,  ",
               "      datmitaaplitm b  ",
               " where a.itaciacod  = b.itaciacod ",
               " and   a.itaramcod  = b.itaramcod ",
               " and   a.itaaplnum  = b.itaaplnum ",
               " and   a.aplseqnum  = b.aplseqnum ",
               " and   b.autchsnum  = ?           ",
               " order by a.itaaplvigfnldat desc, ",
               "          a.aplseqnum desc        "
   prepare p_cty22g00_006  from l_sql
   declare c_cty22g00_006  cursor for p_cty22g00_006


   let l_sql = " select itaaplvigincdat, " ,
               "        itaaplvigfnldat  " ,
               " from datmitaapl         " ,
               " where itaciacod = ?     " ,
               " and   itaramcod = ?     " ,
               " and   itaaplnum = ?     " ,
               " and   aplseqnum = ?     "
    prepare p_cty22g00_007  from l_sql
    declare c_cty22g00_007  cursor for p_cty22g00_007



    let l_sql = "select a.itaciacod       , ",
                "  a.itaramcod       , ",
                "  a.itaaplnum       , ",
                "  a.aplseqnum       , ",
                "  a.itaprpnum       , ",
                "  a.itaaplvigincdat , ",
                "  a.itaaplvigfnldat , ",
                "  a.segnom          , ",
                "  a.pestipcod       , ",
                "  a.segcgccpfnum    , ",
                "  a.segcgcordnum    , ",
                "  a.segcgccpfdig    , ",
                "  a.itaprdcod       , ",
                "  b.itasgrplncod    , ",
                "  b.itaempasicod    , ",
                "  b.itaasisrvcod    , ",
                "  a.itacliscocod    , ",
                "  b.itarsrcaosrvcod , ",
                "  b.itaclisgmcod    , ",
                "  b.itaaplcanmtvcod , ",
                "  b.rsrcaogrtcod    , ",
                "  b.asiincdat       , ",
                "  a.corsus          , ",
                "  a.seglgdnom       , ",
                "  a.seglgdnum       , ",
                "  a.segendcmpdes    , ",
                "  a.segbrrnom       , ",
                "  a.segcidnom       , ",
                "  a.segufdsgl       , ",
                "  a.segcepnum       , ",
                "  a.segcepcmpnum    , ",
                "  a.segresteldddnum , ",
                "  a.segrestelnum    , ",
                "  a.adniclhordat    , ",
                "  a.itaasiarqvrsnum , ",
                "  a.pcsseqnum       , ",
                "  b.ubbcod          , ",
                "  a.succod          , ",
                "  a.vipsegflg       , ",
                "  a.segmaiend       , ",
                "  b.itaaplitmnum    , ",
                "  b.itaaplitmsttcod , ",
                "  b.autchsnum       , ",
                "  b.autplcnum       , ",
                "  b.autfbrnom       , ",
                "  b.autlnhnom       , ",
                "  b.autmodnom       , ",
                "  b.itavclcrgtipcod , ",
                "  b.autfbrano       , ",
                "  b.autmodano       , ",
                "  b.autcornom       , ",
                "  b.autpintipdes    , ",
                "  b.okmflg          , ",
                "  b.impautflg       , ",
                "  b.casfrqvlr       , ",
                "  b.rsclclcepnum    , ",
                "  b.rcslclcepcmpnum , ",
                "  b.porvclcod       , ",
                "  a.frtmdlcod       , ",
                "  a.vndcnlcod       , ",
                "  b.vcltipcod       , ",
                "  b.bldflg            ",
                " from datmitaapl a    , ",
                "      datmitaaplitm b   ",
                " where a.itaciacod = b.itaciacod  ",
                " and   a.itaramcod = b.itaramcod  ",
                " and   a.itaaplnum = b.itaaplnum  ",
                " and   a.aplseqnum = b.aplseqnum  ",
                " and   a.itaciacod     = ? ",
                " and   a.itaramcod     = ? ",
                " and   a.itaaplnum     = ? ",
                " and   a.aplseqnum     = ? ",
                " and   b.itaaplitmnum  = ? "
        prepare p_cty22g00_008  from l_sql
        declare c_cty22g00_008  cursor for p_cty22g00_008

        let l_sql = " select  itacbtcod,    " ,
                    "         itaasiplncod  " ,
                    " from datkitacbtintrgr " ,
                    " where itaasisrvcod     = ?     " ,
                    " and   rsrcaogrtcod     = ?     " ,
                    " and   itarsrcaosrvcod  = ?     " ,
                    " and   ubbcod           = ?     "
         prepare p_cty22g00_009  from l_sql
         declare c_cty22g00_009  cursor for p_cty22g00_009

        let l_sql = " select pansoclmtqtd,    ",
                    "        socqlmqtd        ",
                    " from datkitaasipln      ",
                    " where itaasiplncod = ?  "
         prepare p_cty22g00_010  from l_sql
         declare c_cty22g00_010  cursor for p_cty22g00_010


        let l_sql = "select a.atdsrvnum ,      " ,
                    "       a.atdsrvano        " ,
                    " from datmservico a,      " ,
                    "      datmligacao b,      " ,
                    "      datritaasiplnast c, " ,
                    "      datrligitaaplitm d  " ,
                    " where a.atdsrvnum = b.atdsrvnum " ,
                    " and a.atdsrvano = b.atdsrvano   " ,
                    " and b.c24astcod = c.astcod      " ,
                    " and b.lignum    = d.lignum      " ,
                    " and a.atddat between ? and ?    " ,
                    " and c.itaasiplncod = ?          " ,
                    " and c.evtctbflg = 'S'           " ,
                    " and d.itaciacod = ?             " ,
                    " and d.itaramcod = ?             " ,
                    " and d.itaaplnum = ?             " ,
                    " and d.itaaplitmnum = ?          "
        prepare p_cty22g00_011  from l_sql
        declare c_cty22g00_011  cursor for p_cty22g00_011


        let l_sql = "select count(*),        " ,
                    " evtctbflg,             " ,
                    " itaasiplntipcod,       " ,
                    " sinflg                 " ,
                    " from datritaasiplnast  " ,
                    " where itaasiplncod = ? " ,
                    " and   astcod = ?       " ,
                    " group by 2,3,4         "
        prepare p_cty22g00_012  from l_sql
        declare c_cty22g00_012  cursor for p_cty22g00_012

        let l_sql = "update datmitaapl       " ,
                    " set segmaiend = ?      " ,
                    " where itaciacod = ?    " ,
                    " and   itaramcod = ?    " ,
                    " and   itaaplnum = ?    "
        prepare p_cty22g00_013  from l_sql

        let l_sql = " select a.segnom          , ",
                    "        a.pestipcod       , ",
                    "        a.segcgccpfnum    , ",
                    "        a.segcgcordnum    , ",
                    "        a.segcgccpfdig    , ",
                    "        a.itaaplvigincdat , ",
                    "        a.itaaplvigfnldat , ",
                    "        b.itaaplcanmtvcod   ",
                    " from datmitaapl a ,        ",
                    "      datmitaaplitm b       ",
                    " where a.itaciacod = b.itaciacod  ",
                    " and   a.itaramcod = b.itaramcod  ",
                    " and   a.itaaplnum = b.itaaplnum  ",
                    " and   a.aplseqnum = b.aplseqnum  ",
                    " and   a.itaciacod     = ?  ",
                    " and   a.itaramcod     = ?  ",
                    " and   a.itaaplnum     = ?  ",
                    " and   a.aplseqnum     = ?  ",
                    " and   b.itaaplitmnum  = ?  "
        prepare p_cty22g00_014  from l_sql
        declare c_cty22g00_014  cursor for p_cty22g00_014

        let l_sql = " select count(*) "        ,
                    " from datmitaapl "        ,
                    " where segcgccpfnum = ? " ,
                    " and   segcgcordnum = ? " ,
                    " and   segcgccpfdig = ? "
        prepare p_cty22g00_015  from l_sql
        declare c_cty22g00_015  cursor for p_cty22g00_015

        let l_sql = " select count(*) "        ,
                    " from datmitaapl "        ,
                    " where segnom matches ? "
        prepare p_cty22g00_016 from l_sql
        declare c_cty22g00_016 cursor for p_cty22g00_016

        let l_sql = " select itaasstipcod "  ,
                    " from datkassunto       "  ,
                    " where c24astcod = ?    "
        prepare p_cty22g00_017 from l_sql
        declare c_cty22g00_017 cursor for p_cty22g00_017

        let l_sql = "select atdetpcod     ",
                    "  from datmsrvacp    ",
                    " where atdsrvnum = ? ",
                    "   and atdsrvano = ? ",
                    "   and atdsrvseq = (select max(atdsrvseq)",
                                        "  from datmsrvacp    ",
                                        " where atdsrvnum = ? ",
                                        "   and atdsrvano = ?)"
        prepare p_cty22g00_018 from l_sql
        declare c_cty22g00_018 cursor for p_cty22g00_018

        let l_sql = " select count(*)        "        ,
                    " from datmassistpassag  "        ,
                    " where atdsrvano = ?    "        ,
                    " and   atdsrvnum = ?    "        ,
                    " and  refatdsrvnum is not null " ,
                    " and  refatdsrvano is not null "
        prepare p_cty22g00_019 from l_sql
        declare c_cty22g00_019 cursor for p_cty22g00_019

        let l_sql = "  select cornom               ",
                    "  from gcaksusep a,           ",
                    "       gcakcorr b             ",
                    "where a.corsus  = ?           ",
                    "and a.corsuspcp = b.corsuspcp "
        prepare p_cty22g00_020  from l_sql
        declare c_cty22g00_020  cursor for p_cty22g00_020

				let l_sql = " select max(aplseqnum) ",
               " from datmresitaapl    ",
               " where itaciacod = ?   ",
               " and   itaramcod = ?   ",
               " and   aplnum = ?       "
        prepare p_cty22g00_021  from l_sql
        declare c_cty22g00_021  cursor for p_cty22g00_021
        
        let l_sql =  " select count(*)           ",
                     " from datrligapol a,       ",
                     " datrligitaaplitm b        ",
                     " where a.lignum = b.lignum ",
                     " and a.succod    = ?       ",
                     " and a.ramcod    = ?       ",
                     " and a.aplnumdig = ?       ",
                     " and a.itmnumdig = ?       ",
                     " and b.itaciacod = ?       "
        prepare p_cty22g00_022  from l_sql
        declare c_cty22g00_022  cursor for p_cty22g00_022
        
        let l_sql =  " select distinct(succod)  ",
                     "  from datmitaapl         ",
                     " where itaciacod  = ?     ",
                     " and itaramcod    = ?     ",
                     " and itaaplnum    = ?     "
        prepare p_cty22g00_023  from l_sql
        declare c_cty22g00_023  cursor for p_cty22g00_023
        	
                
        let l_sql = "  select count(*)       "    	
                 ,  "  from datkdominio      "     	
                 ,  "  where cponom = ?      "     	
                 ,  "  and   cpodes = ?      "     	
        prepare p_cty22g00_024  from l_sql                 	
        declare c_cty22g00_024  cursor for p_cty22g00_024 
        
        
        let l_sql = "  select count(*)       "
                 ,  "  from datkdominio      "   
                 ,  "  where cponom = ?      "   
                 ,  "  and cpodes[1,3]  = ?  "   
        prepare p_cty22g00_025  from l_sql               
        declare c_cty22g00_025  cursor for p_cty22g00_025      
        	
       
        let l_sql = "  select cpodes[5,8]    "                 	
                 ,  "  from datkdominio      "                 	
                 ,  "  where cponom = ?      "                 	
                 ,  "  and cpodes[1,3]  = ?  "                 	
        prepare p_cty22g00_026  from l_sql                     	
        declare c_cty22g00_026  cursor for p_cty22g00_026 
        	
       
        let l_sql = "  select count(*)       "    	      
                 ,  "  from datkdominio      "     	      
                 ,  "  where cponom = ?      "     	      
                 ,  "  and   cpocod = ?      "     	      
        prepare p_cty22g00_027  from l_sql                	
        declare c_cty22g00_027  cursor for p_cty22g00_027 
        	
        	
        let l_sql = "  select cpodes         "    	         
                 ,  "  from datkdominio      "     	        	
                 ,  "  where cponom = ?      "     	        	
                 ,  "  and   cpocod = ?      "     	        	
        prepare p_cty22g00_028  from l_sql                	  		
        declare c_cty22g00_028  cursor for p_cty22g00_028 	
        	
        	
        let l_sql = "  select ctisrvflg,       " 
                 ,  "         ctinaosrvflg     "   	         
                 ,  "  from datritaasiplnnat   "     	        	
                 ,  "  where itaasiplncod = ?  "     	        	
                 ,  "  and   socntzcod = ?     "     	        	
        prepare p_cty22g00_029  from l_sql                	  		
        declare c_cty22g00_029  cursor for p_cty22g00_029 		
        	
  
end function

#------------------------------------------------------------------------------
function cty22g00_qtd_apolice(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod,
   itaramcod     like datmitaapl.itaramcod,
   itaaplnum     like datmitaapl.itaaplnum
end record

define lr_retorno record
   qtd integer
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

let lr_retorno.qtd = 0

   open c_cty22g00_001 using lr_param.itaciacod ,
                             lr_param.itaramcod ,
                             lr_param.itaaplnum
   whenever error continue
   fetch c_cty22g00_001 into lr_retorno.qtd
   whenever error stop
   close c_cty22g00_001

   return lr_retorno.qtd

end function

#------------------------------------------------------------------------------
function cty22g00_qtd_cgc_cpf(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    segcgccpfnum    like datmitaapl.segcgccpfnum    ,
    segcgcordnum    like datmitaapl.segcgcordnum    ,
    segcgccpfdig    like datmitaapl.segcgccpfdig
end record

define lr_retorno record
   qtd integer
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

let lr_retorno.qtd = 0

   open c_cty22g00_015 using lr_param.segcgccpfnum ,
                             lr_param.segcgcordnum ,
                             lr_param.segcgccpfdig
   whenever error continue
   fetch c_cty22g00_015 into lr_retorno.qtd
   whenever error stop
   close c_cty22g00_015

   return lr_retorno.qtd

end function

#------------------------------------------------------------------------------
function cty22g00_qtd_nome(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    segnom like datmitaapl.segnom
end record

define lr_retorno record
   qtd integer
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

let lr_retorno.qtd = 0

   let lr_param.segnom = lr_param.segnom clipped , "*"

   open c_cty22g00_016 using lr_param.segnom

   whenever error continue
   fetch c_cty22g00_016 into lr_retorno.qtd
   whenever error stop
   close c_cty22g00_016

   return lr_retorno.qtd

end function


#------------------------------------------------------------------------------
function cty22g00_rec_ult_sequencia(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod,
   itaramcod     like datmitaapl.itaramcod,
   itaaplnum     like datmitaapl.itaaplnum
end record

define lr_retorno record
   aplseqnum     like datmitaapl.aplseqnum,
   erro          integer                  ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

 if lr_param.itaramcod = 31 or lr_param.itaramcod = 531 then
   open c_cty22g00_002 using lr_param.itaciacod ,
                             lr_param.itaramcod ,
                             lr_param.itaaplnum
   whenever error continue
   fetch c_cty22g00_002 into lr_retorno.aplseqnum
   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Sequencia da Apolice nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_002 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_002
  { return lr_retorno.aplseqnum,
          lr_retorno.erro     ,
          lr_retorno.mensagem}
 else

   open c_cty22g00_021 using lr_param.itaciacod ,
                             lr_param.itaramcod ,
                             lr_param.itaaplnum
   whenever error continue
   fetch c_cty22g00_021 into lr_retorno.aplseqnum
   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Sequencia da Apolice nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_002 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_021
 end if
   return lr_retorno.aplseqnum,
          lr_retorno.erro     ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_apolice_por_placa(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   autplcnum     like datmitaaplitm.autplcnum
end record

define lr_retorno record
   itaciacod     like datmitaaplitm.itaciacod    ,
   itaramcod     like datmitaaplitm.itaramcod    ,
   itaaplnum     like datmitaaplitm.itaaplnum    ,
   aplseqnum     like datmitaaplitm.aplseqnum    ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   succod        like datmitaapl.succod          ,
   erro          integer                         ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

   open c_cty22g00_003 using lr_param.autplcnum
   whenever error continue
   fetch c_cty22g00_003 into lr_retorno.itaciacod     ,
                             lr_retorno.itaramcod     ,
                             lr_retorno.itaaplnum     ,
                             lr_retorno.aplseqnum     ,
                             lr_retorno.itaaplitmnum  ,
                             lr_retorno.succod
   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Placa do Veiculo nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_003 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_003

   return lr_retorno.itaciacod    ,
          lr_retorno.itaramcod    ,
          lr_retorno.itaaplnum    ,
          lr_retorno.aplseqnum    ,
          lr_retorno.itaaplitmnum ,
          lr_retorno.succod       ,
          lr_retorno.erro         ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_companhia(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   atdnum   like datratdlig.atdnum
end record

define lr_retorno record
   itaciacod     like datmitaaplitm.itaciacod,
   erro          integer                     ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

   open c_cty22g00_004 using lr_param.atdnum
   whenever error continue
   fetch c_cty22g00_004 into lr_retorno.itaciacod
   whenever error stop

   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Companhia nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_004 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if

   close c_cty22g00_004

   return lr_retorno.itaciacod ,
          lr_retorno.erro      ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_cgc_cpf_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod       like datmitaapl.itaciacod       ,
   itaramcod       like datmitaapl.itaramcod       ,
   itaaplnum       like datmitaapl.itaaplnum       ,
   aplseqnum       like datmitaapl.aplseqnum       ,
   itaaplitmnum    like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
  segnom          like datmitaapl.segnom             ,
  pestipcod       like datmitaapl.pestipcod          ,
  segcgccpfnum    like datmitaapl.segcgccpfnum       ,
  segcgcordnum    like datmitaapl.segcgcordnum       ,
  segcgccpfdig    like datmitaapl.segcgccpfdig       ,
  itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
  itaaplvigfnldat like datmitaapl.itaaplvigfnldat    ,
  itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod ,
  erro            integer                            ,
  mensagem        char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

let lr_retorno.erro = 0

   open c_cty22g00_014 using lr_param.itaciacod    ,
                             lr_param.itaramcod    ,
                             lr_param.itaaplnum    ,
                             lr_param.aplseqnum    ,
                             lr_param.itaaplitmnum

   whenever error continue
   fetch c_cty22g00_014 into lr_retorno.segnom          ,
                             lr_retorno.pestipcod       ,
                             lr_retorno.segcgccpfnum    ,
                             lr_retorno.segcgcordnum    ,
                             lr_retorno.segcgccpfdig    ,
                             lr_retorno.itaaplvigincdat ,
                             lr_retorno.itaaplvigfnldat ,
                             lr_retorno.itaaplcanmtvcod

   whenever error stop

   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Dados do CGC/CPF Não Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_014 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_014

   return lr_retorno.segnom          ,
          lr_retorno.pestipcod       ,
          lr_retorno.segcgccpfnum    ,
          lr_retorno.segcgcordnum    ,
          lr_retorno.segcgccpfdig    ,
          lr_retorno.itaaplvigincdat ,
          lr_retorno.itaaplvigfnldat ,
          lr_retorno.itaaplcanmtvcod ,
          lr_retorno.erro            ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_cobertura_plano(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasisrvcod    like datkitacbtintrgr.itaasisrvcod    ,
   rsrcaogrtcod    like datkitacbtintrgr.rsrcaogrtcod    ,
   itarsrcaosrvcod like datkitacbtintrgr.itarsrcaosrvcod ,
   ubbcod          like datkitacbtintrgr.ubbcod
end record

define lr_retorno record
   itacbtcod     like datkitacbtintrgr.itacbtcod    ,
   itaasiplncod  like datkitacbtintrgr.itaasiplncod ,
   erro          integer                            ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

let lr_retorno.erro = 0

   open c_cty22g00_009 using lr_param.itaasisrvcod    ,
                             lr_param.rsrcaogrtcod    ,
                             lr_param.itarsrcaosrvcod ,
                             lr_param.ubbcod

   whenever error continue
   fetch c_cty22g00_009 into lr_retorno.itacbtcod     ,
                             lr_retorno.itaasiplncod
   whenever error stop

   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Plano e Cobertura Nao Cadastrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_009 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_009

   return lr_retorno.itacbtcod     ,
          lr_retorno.itaasiplncod  ,
          lr_retorno.erro          ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_plano_assistencia(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod  like datkitaasipln.itaasiplncod
end record

define lr_retorno record
   pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
   socqlmqtd     like datkitaasipln.socqlmqtd    ,
   erro          integer                         ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

   open c_cty22g00_010 using lr_param.itaasiplncod
   whenever error continue
   fetch c_cty22g00_010 into lr_retorno.pansoclmtqtd ,
                             lr_retorno.socqlmqtd
   whenever error stop

   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Plano de Assistencia Nao Cadastrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_010 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_010

   return lr_retorno.pansoclmtqtd ,
          lr_retorno.socqlmqtd    ,
          lr_retorno.erro         ,
          lr_retorno.mensagem

end function



#------------------------------------------------------------------------------
function cty22g00_rec_apolice_por_proposta(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaprpnum     like datmitaapl.itaprpnum
end record

define lr_retorno record
   itaciacod     like datmitaaplitm.itaciacod    ,
   itaramcod     like datmitaaplitm.itaramcod    ,
   itaaplnum     like datmitaaplitm.itaaplnum    ,
   aplseqnum     like datmitaaplitm.aplseqnum    ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   succod        like datmitaapl.succod          ,
   erro          integer                         ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

   open c_cty22g00_005 using lr_param.itaprpnum
   whenever error continue
   fetch c_cty22g00_005 into lr_retorno.itaciacod     ,
                             lr_retorno.itaramcod     ,
                             lr_retorno.itaaplnum     ,
                             lr_retorno.aplseqnum     ,
                             lr_retorno.succod

   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Proposta nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao Selecionar o Cursor c_cty22g00_005 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if

   end if
   close c_cty22g00_005

   return lr_retorno.itaciacod    ,
          lr_retorno.itaramcod    ,
          lr_retorno.itaaplnum    ,
          lr_retorno.aplseqnum    ,
          lr_retorno.succod       ,
          lr_retorno.erro         ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_rec_apolice_por_chassi(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   autchsnum   like datmitaaplitm.autchsnum
end record

define lr_retorno record
   itaciacod     like datmitaaplitm.itaciacod    ,
   itaramcod     like datmitaaplitm.itaramcod    ,
   itaaplnum     like datmitaaplitm.itaaplnum    ,
   aplseqnum     like datmitaaplitm.aplseqnum    ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   succod        like datmitaapl.succod          ,
   erro          integer                         ,
   mensagem      char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null
let lr_retorno.erro = 0

   open c_cty22g00_006 using lr_param.autchsnum
   whenever error continue
   fetch c_cty22g00_006 into lr_retorno.itaciacod     ,
                             lr_retorno.itaramcod     ,
                             lr_retorno.itaaplnum     ,
                             lr_retorno.aplseqnum     ,
                             lr_retorno.itaaplitmnum  ,
                             lr_retorno.succod
   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Chassi do Veiculo nao Encontrada!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_006 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_006

   return lr_retorno.itaciacod    ,
          lr_retorno.itaramcod    ,
          lr_retorno.itaaplnum    ,
          lr_retorno.aplseqnum    ,
          lr_retorno.itaaplitmnum ,
          lr_retorno.succod       ,
          lr_retorno.erro         ,
          lr_retorno.mensagem

end function

#------------------------------------------------------------------------------
function cty22g00_ver_vigencia_apolice(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaaplitm.itaciacod    ,
   itaramcod     like datmitaaplitm.itaramcod    ,
   itaaplnum     like datmitaaplitm.itaaplnum    ,
   aplseqnum     like datmitaaplitm.aplseqnum
end record

define lr_retorno record
   itaaplvigincdat  like datmitaapl.itaaplvigincdat ,
   itaaplvigfnldat  like datmitaapl.itaaplvigfnldat ,
   linha1           char(40)                        ,
   linha2           char(40)                        ,
   linha3           char(40)                        ,
   linha4           char(40)                        ,
   confirma         char(01)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null


   open c_cty22g00_007 using lr_param.itaciacod,
                             lr_param.itaramcod,
                             lr_param.itaaplnum,
                             lr_param.aplseqnum
   whenever error continue
   fetch c_cty22g00_007 into lr_retorno.itaaplvigincdat,
                             lr_retorno.itaaplvigfnldat

   whenever error stop
   if sqlca.sqlcode <> 0  then
         error "Erro ao Selecionar o Cursor c_cty22g00_007 ", sqlca.sqlcode
         return false
   end if
   close c_cty22g00_007

   if lr_retorno.itaaplvigincdat <= today and
      lr_retorno.itaaplvigfnldat  >= today then
         return true
   else
      let lr_retorno.linha1 = "ESTA APOLICE ESTA VENCIDA"
      let lr_retorno.linha2 = "PROCURE UMA APOLICE VIGENTE"
      let lr_retorno.linha3 = "OU CONSULTE A SUPERVISAO."
      let lr_retorno.linha4 = "DESEJA PROSSEGUIR?"

      call cts08g01("C","S",lr_retorno.linha1,
                            lr_retorno.linha2,
                            lr_retorno.linha3,
                            lr_retorno.linha4)
           returning lr_retorno.confirma

      if lr_retorno.confirma = "S" then
         return true
      else
         return false
      end if

   end if


end function

#------------------------------------------------------------------------------
function cty22g00_rec_dados_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod       ,
   itaramcod     like datmitaapl.itaramcod       ,
   itaaplnum     like datmitaapl.itaaplnum       ,
   aplseqnum     like datmitaapl.aplseqnum       ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
   erro          integer                         ,
   mensagem      char(50)
end record

define lr_retorno_aux record
   erro          integer                         ,
   mensagem      char(50)
end record

define l_index smallint

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* ,
           lr_retorno_aux.* to null

for  l_index  =  1  to  500
   initialize  g_doc_itau[l_index].* to  null
end  for


let lr_retorno.erro = 0

   open c_cty22g00_008 using lr_param.itaciacod    ,
                             lr_param.itaramcod    ,
                             lr_param.itaaplnum    ,
                             lr_param.aplseqnum    ,
                             lr_param.itaaplitmnum

   whenever error continue
   fetch c_cty22g00_008 into g_doc_itau[1].itaciacod          ,
                             g_doc_itau[1].itaramcod          ,
                             g_doc_itau[1].itaaplnum          ,
                             g_doc_itau[1].aplseqnum          ,
                             g_doc_itau[1].itaprpnum          ,
                             g_doc_itau[1].itaaplvigincdat    ,
                             g_doc_itau[1].itaaplvigfnldat    ,
                             g_doc_itau[1].segnom             ,
                             g_doc_itau[1].pestipcod          ,
                             g_doc_itau[1].segcgccpfnum       ,
                             g_doc_itau[1].segcgcordnum       ,
                             g_doc_itau[1].segcgccpfdig       ,
                             g_doc_itau[1].itaprdcod          ,
                             g_doc_itau[1].itasgrplncod       ,
                             g_doc_itau[1].itaempasicod       ,
                             g_doc_itau[1].itaasisrvcod       ,
                             g_doc_itau[1].itacliscocod       ,
                             g_doc_itau[1].itarsrcaosrvcod    ,
                             g_doc_itau[1].itaclisgmcod       ,
                             g_doc_itau[1].itaaplcanmtvcod    ,
                             g_doc_itau[1].rsrcaogrtcod       ,
                             g_doc_itau[1].asiincdat          ,
                             g_doc_itau[1].corsus             ,
                             g_doc_itau[1].seglgdnom          ,
                             g_doc_itau[1].seglgdnum          ,
                             g_doc_itau[1].segendcmpdes       ,
                             g_doc_itau[1].segbrrnom          ,
                             g_doc_itau[1].segcidnom          ,
                             g_doc_itau[1].segufdsgl          ,
                             g_doc_itau[1].segcepnum          ,
                             g_doc_itau[1].segcepcmpnum       ,
                             g_doc_itau[1].segresteldddnum    ,
                             g_doc_itau[1].segrestelnum       ,
                             g_doc_itau[1].adniclhordat       ,
                             g_doc_itau[1].itaasiarqvrsnum    ,
                             g_doc_itau[1].pcsseqnum          ,
                             g_doc_itau[1].ubbcod             ,
                             g_doc_itau[1].succod             ,
                             g_doc_itau[1].vipsegflg          ,
                             g_doc_itau[1].segmaiend          ,
                             g_doc_itau[1].itaaplitmnum       ,
                             g_doc_itau[1].itaaplitmsttcod    ,
                             g_doc_itau[1].autchsnum          ,
                             g_doc_itau[1].autplcnum          ,
                             g_doc_itau[1].autfbrnom          ,
                             g_doc_itau[1].autlnhnom          ,
                             g_doc_itau[1].autmodnom          ,
                             g_doc_itau[1].itavclcrgtipcod    ,
                             g_doc_itau[1].autfbrano          ,
                             g_doc_itau[1].autmodano          ,
                             g_doc_itau[1].autcornom          ,
                             g_doc_itau[1].autpintipdes       ,
                             g_doc_itau[1].okmflg             ,
                             g_doc_itau[1].impautflg          ,
                             g_doc_itau[1].casfrqvlr          ,
                             g_doc_itau[1].rsclclcepnum       ,
                             g_doc_itau[1].rcslclcepcmpnum    ,
                             g_doc_itau[1].porvclcod          ,
                             g_doc_itau[1].frtmdlcod          ,
                             g_doc_itau[1].vndcnlcod          ,
                             g_doc_itau[1].vcltipcod          ,
                             g_doc_itau[1].bldflg


   whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = notfound  then
         let lr_retorno.mensagem = "Dados do Itau nao Encontrado!"
         let lr_retorno.erro     = 1
      else
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty22g00_008 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode
      end if
   end if
   close c_cty22g00_008

   if lr_retorno.erro = 0 then

       # Recupera Plano e Cobertura

       call cty22g00_rec_cobertura_plano(g_doc_itau[1].itaasisrvcod     ,
                                         g_doc_itau[1].rsrcaogrtcod     ,
                                         g_doc_itau[1].itarsrcaosrvcod  ,
                                         g_doc_itau[1].ubbcod           )
       returning g_doc_itau[1].itacbtcod    ,
                 g_doc_itau[1].itaasiplncod ,
                 lr_retorno_aux.erro        ,
                 lr_retorno_aux.mensagem

   end if

   return lr_retorno.erro         ,
          lr_retorno.mensagem

end function

#========================================================================
function cty22g00_busca_nome_corretor()
#========================================================================
 define lr_cornom like gcakcorr.cornom

 if m_prepare is null or
    m_prepare = false then
    call cty22g00_prepare()
 end if

 let lr_cornom = null

 open c_cty22g00_020 using g_doc_itau[1].corsus
 whenever error continue
 fetch c_cty22g00_020 into lr_cornom
 whenever error stop

 if sqlca.sqlcode = notfound  then
    let lr_cornom = "Corretor nao Cadastrado!"
 end if

close c_cty22g00_020

return lr_cornom

#========================================================================
end function
#========================================================================

#------------------------------------------------------------------------------
function cty22g00_qtd_ligacoes_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaasiplncod     like datkitaasipln.itaasiplncod     ,
   itaaplvigincdat  like datmitaapl.itaaplvigincdat     ,
   itaaplvigfnldat  like datmitaapl.itaaplvigfnldat     ,
   itaciacod        like datmitaapl.itaciacod           ,
   itaramcod        like datmitaapl.itaramcod           ,
   itaaplnum        like datmitaapl.itaaplnum           ,
   itaaplitmnum     like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
   qtd        integer                     ,
   cont       integer                     ,
   atdsrvnum  like datmservico.atdsrvnum  ,
   atdsrvano  like datmservico.atdsrvano  ,
   atdetpcod  like datmsrvacp.atdetpcod
end record

initialize lr_retorno.* to null

let lr_retorno.qtd  = 0
let lr_retorno.cont = 0


   open c_cty22g00_011 using lr_param.itaaplvigincdat  ,
                             lr_param.itaaplvigfnldat  ,
                             lr_param.itaasiplncod     ,
                             lr_param.itaciacod        ,
                             lr_param.itaramcod        ,
                             lr_param.itaaplnum        ,
                             lr_param.itaaplitmnum

   foreach c_cty22g00_011 into lr_retorno.atdsrvnum ,
                               lr_retorno.atdsrvano


          # Verifica a Etapa do Serviço

          open  c_cty22g00_018  using lr_retorno.atdsrvnum,
                                      lr_retorno.atdsrvano,
                                      lr_retorno.atdsrvnum,
                                      lr_retorno.atdsrvano
          whenever error continue
          fetch c_cty22g00_018  into  lr_retorno.atdetpcod
          whenever error stop

          close c_cty22g00_018

          # Verifica se o Serviço e Original ou Filho

          open  c_cty22g00_019  using lr_retorno.atdsrvano,
                                      lr_retorno.atdsrvnum
          whenever error continue
          fetch c_cty22g00_019  into  lr_retorno.qtd
          whenever error stop

          close c_cty22g00_019

          if lr_retorno.atdetpcod <> 5 and  # Soma se for Serviço Diferente de Cancelado
             lr_retorno.qtd       = 0  then # Soma se for Serviço Diferente de Filho
             let lr_retorno.cont = lr_retorno.cont + 1
          end if

   end foreach

   return lr_retorno.cont

end function


#------------------------------------------------------------------------------
function cty22g00_verifica_plano_assunto(lr_param)
#------------------------------------------------------------------------------

define lr_param record
  astcod       like datritaasiplnast.astcod       ,
  itaasiplncod like datritaasiplnast.itaasiplncod ,
  acesso       smallint
end record

define lr_retorno record
 evtctbflg       like datritaasiplnast.evtctbflg       ,
 itaasiplntipcod like datritaasiplnast.itaasiplntipcod ,
 sinflg          like datritaasiplnast.sinflg          ,
 qtd             integer                               ,
 flag            smallint                              ,
 mens            char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if


   while true

    initialize lr_retorno.* to null

       # Verifica o Plano de Assistencia

       if lr_param.itaasiplncod is null then
          let lr_retorno.mens = "Plano de Assistencia nao Cadastrado!"
          let lr_retorno.flag = 2
          exit while
       end if

       open c_cty22g00_012 using lr_param.itaasiplncod,
                                 lr_param.astcod

       whenever error continue
       fetch c_cty22g00_012 into lr_retorno.qtd              ,
                                 lr_retorno.evtctbflg        ,
                                 lr_retorno.itaasiplntipcod  ,
                                 lr_retorno.sinflg
       whenever error stop
       close c_cty22g00_012


      # Verificar se o Assunto e de Sinistro por Guincho, se sim não Passar pelos Limites
      # Verifica se Contabiliza, se não não passa pelos limites

      if lr_retorno.sinflg    = "S" or
         lr_retorno.evtctbflg = "N" then
          let lr_retorno.flag = 1
          exit while
      end if

      # Verifica se o Tipo de Servico e Hibrido e Acesso Primario nao Passa pelos Limites

      if lr_retorno.itaasiplntipcod = 7 and
         lr_param.acesso            = 1 then
           let lr_retorno.flag = 1
           exit while
      end if


      if lr_retorno.qtd is null or
         lr_retorno.qtd = " "   or
         lr_retorno.qtd = 0     then

            let lr_retorno.flag = 2
            let lr_retorno.mens = "Assunto nao Permitido para este Plano!"
      else
            let lr_retorno.flag = 0
      end if

      exit while

   end while

   return lr_retorno.flag     ,
          lr_retorno.mens

end function

#------------------------------------------------------------------------------
function cty22g00_conta_corrente_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
     c24astcod       like datmligacao.c24astcod       ,
     itaasiplncod    like datkitaasipln.itaasiplncod  ,
     itaaplvigincdat like datmitaapl.itaaplvigincdat  ,
     itaaplvigfnldat like datmitaapl.itaaplvigfnldat  ,
     itaciacod       like datmitaapl.itaciacod        ,
     itaramcod       like datmitaapl.itaramcod        ,
     itaaplnum       like datmitaapl.itaaplnum        ,
     itaaplitmnum    like datmitaaplitm.itaaplitmnum  ,
     acesso          smallint
end record

define lr_retorno record
 pansoclmtqtd     like datkitaasipln.pansoclmtqtd       ,
 socqlmqtd        like datkitaasipln.socqlmqtd          ,
 itaasiplntipcod  like datritaasiplnast.itaasiplntipcod ,
 qtd              integer                               ,
 flag             smallint                              ,
 mens             char(50)                              ,
 erro             smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true
let lr_retorno.qtd  = 0


 while true


   # Verifica se o Assunto e do Tipo Serviço

   call cty22g00_recupera_tipo_assunto(lr_param.c24astcod)

   returning lr_retorno.erro,
             lr_retorno.mens,
             lr_retorno.itaasiplntipcod

   # Verifica se Tipo de Assunto e Servico

   if lr_retorno.itaasiplntipcod <> 2 then
      exit while
   end if

   # Verifica se o Assunto tem permissão de ser atendido pelo Plano

   call cty22g00_verifica_plano_assunto(lr_param.c24astcod   ,
                                        lr_param.itaasiplncod,
                                        lr_param.acesso      )
   returning lr_retorno.flag,
             lr_retorno.mens

   case lr_retorno.flag
       when 0
           let lr_retorno.flag = true
       when 1
           let lr_retorno.flag = true
           exit while
       when 2
           let lr_retorno.flag = false
           exit while
   end case

   # Recupera a Quantidade de Serviços Já Prestados

   call cty22g00_qtd_ligacoes_itau(lr_param.itaasiplncod   ,
                                   lr_param.itaaplvigincdat,
                                   lr_param.itaaplvigfnldat,
                                   lr_param.itaciacod      ,
                                   lr_param.itaramcod      ,
                                   lr_param.itaaplnum      ,
                                   lr_param.itaaplitmnum   )
   returning lr_retorno.qtd

   # Recupera a Quantidade de Limites

   call cty22g00_rec_plano_assistencia(lr_param.itaasiplncod)
   returning lr_retorno.pansoclmtqtd ,
             lr_retorno.socqlmqtd    ,
             lr_retorno.flag         ,
             lr_retorno.mens

   if lr_retorno.flag <> 0 then
      let lr_retorno.flag = false
      exit while
   else
      let lr_retorno.flag = true
   end if

   if lr_retorno.qtd >= lr_retorno.pansoclmtqtd then
      let lr_retorno.mens = "Limite Esgotado!|Limite: "      ,
                             lr_retorno.pansoclmtqtd using '&&&',
                            " Utilizado: ", lr_retorno.qtd using '&&&'

      let lr_retorno.flag = false
      exit while
   end if

   exit while

 end while 
 
 # Valida se o Processo e Frota
 
 if cty43g00_restringe_upgrade_frota(lr_param.c24astcod            ,           
                                     g_doc_itau[1].vcltipcod       ,           
                                     g_doc_itau[1].itaaplvigincdat ) then 
    let lr_retorno.flag = false
    let lr_retorno.mens = "Assunto nao Permitido para este Tipo de Veiculo!"      
 end if
 
 
 if cty43g00_acesso_upgrade_frota(lr_param.c24astcod            ,     
                                  g_doc_itau[1].itaprdcod       ,   
                                  g_doc_itau[1].itaasiplncod    ,
                                  g_doc_itau[1].vcltipcod       ,           
                                  g_doc_itau[1].itaaplvigincdat ) then 
    let lr_retorno.flag = true
     
 end if
 
 
 
 

 return lr_retorno.flag,
        lr_retorno.mens

end function

#------------------------------------------------------------------------------
function cty22g00_atualiza_email_itau(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   itaciacod     like datmitaapl.itaciacod  ,
   itaramcod     like datmitaapl.itaramcod  ,
   itaaplnum     like datmitaapl.itaaplnum
end record

define lr_retorno record
 segmaiend  like datmitaapl.segmaiend  ,
 erro       integer                    ,
 mens       char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null

   call cty22g01_email()
   returning lr_retorno.segmaiend

   if lr_retorno.segmaiend is not null                and
      lr_retorno.segmaiend <> g_doc_itau[1].segmaiend then

          whenever error continue
          execute p_cty22g00_013 using lr_retorno.segmaiend   ,
                                       lr_param.itaciacod     ,
                                       lr_param.itaramcod     ,
                                       lr_param.itaaplnum

          whenever error stop

          if sqlca.sqlcode <> 0  then
             let lr_retorno.mens  = "Erro ao Atualizar o E-mail ", sqlca.sqlcode
             let lr_retorno.erro  = sqlca.sqlcode
          else
             let lr_retorno.mens  = "E-mail Atualizado com Sucesso "
             let g_doc_itau[1].segmaiend = lr_retorno.segmaiend
          end if

    end if

   return lr_retorno.erro ,
          lr_retorno.mens

end function

#------------------------------------------------------------------------------
function cty22g00_recupera_tipo_assunto(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   c24astcod     like datkassunto.c24astcod
end record


define lr_retorno record
 itaasiplntipcod  like datritaasiplnast.itaasiplntipcod ,
 erro             integer                               ,
 mens             char(50)
end record

if m_prepare is null or
   m_prepare <> true then
   call cty22g00_prepare()
end if

initialize lr_retorno.* to null


   open c_cty22g00_017 using lr_param.c24astcod

   whenever error continue
   fetch c_cty22g00_017 into lr_retorno.itaasiplntipcod
   whenever error stop

   if sqlca.sqlcode <> 0  then
      let lr_retorno.mens  = "Erro ao Consultar Tipo de Assunto ", sqlca.sqlcode
      let lr_retorno.erro  = sqlca.sqlcode
   end if

   close c_cty22g00_017


   return lr_retorno.erro ,
          lr_retorno.mens ,
          lr_retorno.itaasiplntipcod
end function

#------------------------------------------------------------------------------
function cty22g00_rec_sucursal_itau(lr_param)
#------------------------------------------------------------------------------
define lr_param record
   itaciacod     like datmitaapl.itaciacod        ,
   succod        like datmitaapl.succod           ,
   itaramcod     like datmitaapl.itaramcod        ,
   itaaplnum     like datmitaapl.itaaplnum        ,
   itaaplitmnum  like datmitaaplitm.itaaplitmnum
end record
define lr_retorno record
 succod    like datmitaapl.succod ,
 sucursais char(100)              ,
 cont      integer                ,
 qtd       integer                ,
 existe    smallint
end record
initialize lr_retorno.* to null
let lr_retorno.cont = 0
let lr_retorno.qtd  = 0
 if m_prepare is null or
    m_prepare <> true then
    call cty22g00_prepare()
 end if
 open c_cty22g00_023 using lr_param.itaciacod,
                           lr_param.itaramcod,
                           lr_param.itaaplnum
 foreach c_cty22g00_023 into lr_retorno.succod
  if lr_retorno.succod <> lr_param.succod then
     open c_cty22g00_022 using lr_retorno.succod     ,
                               lr_param.itaramcod    ,
                               lr_param.itaaplnum    ,
                               lr_param.itaaplitmnum ,
                               lr_param.itaciacod
     whenever error continue
     fetch c_cty22g00_022 into lr_retorno.qtd
     whenever error stop
     if lr_retorno.qtd > 0 then
        let lr_retorno.cont = lr_retorno.cont + 1
        if lr_retorno.cont > 1 then
        	  let lr_retorno.sucursais =  lr_retorno.sucursais clipped, ",", lr_retorno.succod  using '<<<<<'
        else
        	  let lr_retorno.sucursais =  lr_retorno.sucursais clipped, lr_retorno.succod using '<<<<<'
        end if
     end if
     close c_cty22g00_022
  else
  	  let lr_retorno.cont = lr_retorno.cont + 1
  	  if lr_retorno.cont > 1 then
  	  	  let lr_retorno.sucursais =  lr_retorno.sucursais clipped, ",", lr_retorno.succod  using '<<<<<'
  	  else
  	  	  let lr_retorno.sucursais =  lr_retorno.sucursais clipped, lr_retorno.succod using '<<<<<'
  	  end if
  end if
 end foreach
 if lr_retorno.cont > 1 then
    let lr_retorno.sucursais = "(", lr_retorno.sucursais clipped, ")"
    let lr_retorno.existe = true
 else
 	  let lr_retorno.existe = false
 end if
 return lr_retorno.existe,
        lr_retorno.sucursais
end function

#-------------------------------------------------#
 function cty22g00_verifica_empresarial(lr_param)
#-------------------------------------------------#

define lr_param record
  itaasiplncod     like datkitaasipln.itaasiplncod
end record

define lr_retorno record
  cont       smallint,
  chave      char(20)                   
end record

initialize lr_retorno.* to null

    if m_prepare is null or      
       m_prepare <> true then    
       call cty22g00_prepare()   
    end if                       
     
    let lr_retorno.chave = "ctc92m01_plano"  
            
    #--------------------------------------------------------
    # Verifica se o Plano e Empresarial
    #--------------------------------------------------------
    
    open c_cty22g00_024  using  lr_retorno.chave  ,
                                lr_param.itaasiplncod
    whenever error continue
    fetch c_cty22g00_024 into lr_retorno.cont
    whenever error stop
    
    if lr_retorno.cont > 0 then
    	 return true
    end if
    
    return false


end function

#------------------------------------------------------#
 function cty22g00_limite_assunto_empresarial(lr_param)
#------------------------------------------------------#

define lr_param record
  itaasiplncod like datkitaasipln.itaasiplncod , 
  c24astcod    like datkassunto.c24astcod      ,     
  itaciacod    like datmitaapl.itaciacod       ,       
  itaramcod    like datmitaapl.itaramcod       , 
  itaaplnum    like datmitaapl.itaaplnum       , 
  itaaplitmnum like datmitaaplitm.itaaplitmnum     
end record

define lr_retorno record
  cont       smallint,
  chave      char(20),
  limite     integer ,
  utilizado  integer ,
  confirma   char(01)                      
end record

initialize lr_retorno.* to null

    if m_prepare is null or      
       m_prepare <> true then    
       call cty22g00_prepare()   
    end if                       
     
    let lr_retorno.chave = ctc92m11_monta_chave(lr_param.itaasiplncod)  
            
    #--------------------------------------------------------
    # Verifica se o Assunto Tem Limite
    #--------------------------------------------------------
    
    open c_cty22g00_025  using  lr_retorno.chave,
                                lr_param.c24astcod
    whenever error continue
    fetch c_cty22g00_025 into lr_retorno.cont
    whenever error stop
    
    if lr_retorno.cont > 0 then
    	 
    	  #--------------------------------------------------------         
    	  # Recupera a Quantidade de Limite por Assunto                                
    	  #--------------------------------------------------------         
    	                                                                    
    	  open c_cty22g00_026  using lr_retorno.chave,  
    	                             lr_param.c24astcod
    	  whenever error continue                                           
    	  fetch c_cty22g00_026 into lr_retorno.limite                         
    	  whenever error stop                                               
    	 
    	  
    	  #--------------------------------------------------------
    	  # Recupera a Quantidade de Servicos Utilizados                                      
    	  #--------------------------------------------------------
    	  call cts61m03_qtd_servico_assunto(lr_param.itaciacod          ,     
    	                                    lr_param.itaramcod          ,     
    	                                    lr_param.itaaplnum          ,     
    	                                    lr_param.itaaplitmnum       ,         
    	                                    lr_param.itaasiplncod       ,
    	                                    lr_param.c24astcod          )     
    	  returning lr_retorno.utilizado 
    	  
    	  if lr_retorno.utilizado >= lr_retorno.limite then
    	     
    	      call cts08g01('A','N',                     
    	                    'ACESSO NEGADO'          ,    
    	                    'ATENDIMENTO LIMITADO A' ,   
    	                    lr_retorno.limite        ,
    	                    'ATENDIMENTO(S)'         )    
    	      returning lr_retorno.confirma  
    	      
    	      return false
    	                                           
        end if 
    
    else  
       return true    
    end if
    
    return true

end function

#------------------------------------------------------#                                      
 function cty22g00_limite_problema_empresarial(lr_param)                                       
#------------------------------------------------------#                                      
                                                                                              
define lr_param record                                                                        
  itaasiplncod like datkitaasipln.itaasiplncod ,                                              
  c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod    ,                                              
  itaciacod    like datmitaapl.itaciacod       ,                                              
  itaramcod    like datmitaapl.itaramcod       ,                                              
  itaaplnum    like datmitaapl.itaaplnum       ,                                              
  itaaplitmnum like datmitaaplitm.itaaplitmnum                                                
end record                                                                                    
                                                                                              
define lr_retorno record                                                                      
  cont       smallint,                                                                        
  chave      char(20),                                                                        
  limite     integer ,                                                                        
  utilizado  integer ,
  linha      char(20),                                                                            
  confirma   char(01)                                                                         
end record                                                                                    
                                                                                              
initialize lr_retorno.* to null                                                               
                                                                                              
    if m_prepare is null or                                                                   
       m_prepare <> true then                                                                 
       call cty22g00_prepare()                                                                
    end if                                                                                    
                                                                                              
    let lr_retorno.chave = ctc92m10_monta_chave(lr_param.itaasiplncod)                        
                                                                                              
    #--------------------------------------------------------                                 
    # Verifica se o Problema Tem Limite                                                        
    #--------------------------------------------------------                                 
                                                                                              
    open c_cty22g00_027  using  lr_retorno.chave,                                             
                                lr_param.c24pbmgrpcod                                            
    whenever error continue                                                                   
    fetch c_cty22g00_027 into lr_retorno.cont                                                 
    whenever error stop                                                                       
                                                                                       
    if lr_retorno.cont > 0 then                                                               
    	                                                                                        
    	  #--------------------------------------------------------                             
    	  # Recupera a Quantidade de Limite por Problema                                         
    	  #--------------------------------------------------------                             
    	                                                                                        
    	  open c_cty22g00_028  using lr_retorno.chave,                                          
    	                             lr_param.c24pbmgrpcod                                         
    	  whenever error continue                                                               
    	  fetch c_cty22g00_028 into lr_retorno.limite                                           
    	  whenever error stop                                                                   
    	                                                                                        
    	                                                                                     
    	  #--------------------------------------------------------                             
    	  # Recupera a Quantidade de Servicos Utilizados                                        
    	  #--------------------------------------------------------                             
    	  call cts61m03_qtd_servico_problema(lr_param.itaciacod          ,                       
    	                                     lr_param.itaramcod          ,                       
    	                                     lr_param.itaaplnum          ,                       
    	                                     lr_param.itaaplitmnum       ,                       
    	                                     lr_param.itaasiplncod       ,
    	                                     lr_param.c24pbmgrpcod       )                       
    	  returning lr_retorno.utilizado                                                        
    	                                                                                  
    	  if lr_retorno.utilizado >= lr_retorno.limite then                                     
    	                                                                                        
    	      
    	      let lr_retorno.linha = "LIMITADO A ", lr_retorno.limite using "&&"  
    	      
    	      call cts08g01('A','N',                                                            
    	                    'ATENDIMENTO NEGADO'     ,                                                                                  
    	                    lr_retorno.linha         ,                                          
    	                    'ATENDIMENTO(S) PARA'    ,        
    	                    'ESSE PROBLEMA'          )                                          
    	      returning lr_retorno.confirma                                                     
    	                                                                                        
    	      return false                                                                      
    	                                                                                        
        end if                                                                                
                                                                                              
    else                                                                                      
       return true                                                                            
    end if                                                                                    
                                                                                              
    return true                                                                               
                                                                                              
end function   

#---------------------------------------------------------#                                                                                                                   
 function cty22g00_limite_assistencia_empresarial(lr_param)                                    
#---------------------------------------------------------#                                    
                                                                                            
define lr_param record                                                                      
  itaasiplncod like datkitaasipln.itaasiplncod ,                                            
  asitipcod    like datmservico.asitipcod      ,                                            
  itaciacod    like datmitaapl.itaciacod       ,                                           
  itaramcod    like datmitaapl.itaramcod       ,                                            
  itaaplnum    like datmitaapl.itaaplnum       ,                                            
  itaaplitmnum like datmitaaplitm.itaaplitmnum                                              
end record                                                                                  
                                                                                            
define lr_retorno record                                                                    
  cont       smallint,                                                                      
  chave      char(20),                                                                      
  limite     integer ,                                                                      
  utilizado  integer ,                                                                      
  linha      char(20),                                                                      
  confirma   char(01)                                                                       
end record                                                                                  
                                                                                            
initialize lr_retorno.* to null                                                             
                                                                                            
    if m_prepare is null or                                                                 
       m_prepare <> true then                                                               
       call cty22g00_prepare()                                                              
    end if                                                                                  
                                                                                            
    let lr_retorno.chave = ctc92m12_monta_chave(lr_param.itaasiplncod)                      
                                                                                            
    #--------------------------------------------------------                               
    # Verifica se a Assistencia Tem Limite                                                     
    #--------------------------------------------------------                               
                                                                                            
    open c_cty22g00_027  using  lr_retorno.chave,                                           
                                lr_param.asitipcod                                       
    whenever error continue                                                                 
    fetch c_cty22g00_027 into lr_retorno.cont                                               
    whenever error stop                                                                     
                                                                                           
    if lr_retorno.cont > 0 then                                                             
    	                                                                                      
    	  #--------------------------------------------------------                           
    	  # Recupera a Quantidade de Limite por Assistencia                                     
    	  #--------------------------------------------------------                           
    	                                                                                      
    	  open c_cty22g00_028  using lr_retorno.chave,                                        
    	                             lr_param.asitipcod                                   
    	  whenever error continue                                                             
    	  fetch c_cty22g00_028 into lr_retorno.limite                                         
    	  whenever error stop                                                                                                                                             
    	                                                                                      
    	  #--------------------------------------------------------                           
    	  # Recupera a Quantidade de Servicos Utilizados                                      
    	  #--------------------------------------------------------                           
    	  call cts61m03_qtd_servico_assistencia(lr_param.itaciacod          ,                     
    	                                        lr_param.itaramcod          ,                     
    	                                        lr_param.itaaplnum          ,                     
    	                                        lr_param.itaaplitmnum       ,                     
    	                                        lr_param.itaasiplncod       ,
    	                                        lr_param.asitipcod          )                     
    	  returning lr_retorno.utilizado                                                      
    	                                                                                      
    	  if lr_retorno.utilizado >= lr_retorno.limite then                                   
    	                                                                                      
    	                                                                                      
    	      let lr_retorno.linha = "LIMITADO A ", lr_retorno.limite using "&&"              
    	                                                                                      
    	      call cts08g01('A','N',                                                          
    	                    'ATENDIMENTO NEGADO'     ,                                        
    	                    lr_retorno.linha         ,                                        
    	                    'ATENDIMENTO(S) PARA'    ,                                        
    	                    'ESSA ASSISTENCIA'       )                                        
    	      returning lr_retorno.confirma                                                   
    	                                                                                      
    	      return false                                                                    
    	                                                                                      
        end if                                                                              
                                                                                            
    else                                                                                    
       return true                                                                          
    end if                                                                                  
                                                                                            
    return true                                                                             
                                                                                            
end function 

#------------------------------------------------------#                                                                                                                   
 function cty22g00_limite_motivo_empresarial(lr_param)                                    
#------------------------------------------------------#                                    
                                                                                            
define lr_param record                                                                      
  itaasiplncod like datkitaasipln.itaasiplncod ,                                            
  asimtvcod    like datkasimtv.asimtvcod       ,                                            
  itaciacod    like datmitaapl.itaciacod       ,                                            
  itaramcod    like datmitaapl.itaramcod       ,                                            
  itaaplnum    like datmitaapl.itaaplnum       ,                                            
  itaaplitmnum like datmitaaplitm.itaaplitmnum                                              
end record                                                                                  
                                                                                            
define lr_retorno record                                                                    
  cont       smallint,                                                                      
  chave      char(20),                                                                      
  limite     integer ,                                                                      
  utilizado  integer ,                                                                      
  linha      char(20),                                                                      
  confirma   char(01)                                                                       
end record                                                                                  
                                                                                            
initialize lr_retorno.* to null                                                             
                                                                                            
    if m_prepare is null or                                                                 
       m_prepare <> true then                                                               
       call cty22g00_prepare()                                                              
    end if                                                                                  
                                                                                            
    let lr_retorno.chave = ctc92m13_monta_chave(lr_param.itaasiplncod)                      
                                                                                            
    #--------------------------------------------------------                               
    # Verifica se o Motivo Tem Limite                                                     
    #--------------------------------------------------------                               
                                                                                            
    open c_cty22g00_027  using  lr_retorno.chave,                                           
                                lr_param.asimtvcod                                       
    whenever error continue                                                                 
    fetch c_cty22g00_027 into lr_retorno.cont                                               
    whenever error stop                                                                     
                                                                                       
    if lr_retorno.cont > 0 then                                                             
    	                                                                                      
    	  #--------------------------------------------------------                           
    	  # Recupera a Quantidade de Limite por Motivo                                      
    	  #--------------------------------------------------------                           
    	                                                                                      
    	  open c_cty22g00_028  using lr_retorno.chave,                                        
    	                             lr_param.asimtvcod                                      
    	  whenever error continue                                                             
    	  fetch c_cty22g00_028 into lr_retorno.limite                                         
    	  whenever error stop                                                                 
    	                                                                                       
    	                                                                                      
    	  #--------------------------------------------------------                           
    	  # Recupera a Quantidade de Servicos Utilizados                                      
    	  #--------------------------------------------------------                           
    	  call cts61m03_qtd_servico_motivo(lr_param.itaciacod          ,                     
    	                                   lr_param.itaramcod          ,                     
    	                                   lr_param.itaaplnum          ,                     
    	                                   lr_param.itaaplitmnum       ,                     
    	                                   lr_param.itaasiplncod       ,
    	                                   lr_param.asimtvcod          )                     
    	  returning lr_retorno.utilizado                                                      
    	                                                                                           
    	  if lr_retorno.utilizado >= lr_retorno.limite then                                   
    	                                                                                      
    	                                                                                      
    	      let lr_retorno.linha = "LIMITADO A ", lr_retorno.limite using "&&"              
    	                                                                                      
    	      call cts08g01('A','N',                                                          
    	                    'ATENDIMENTO NEGADO'     ,                                        
    	                    lr_retorno.linha         ,                                        
    	                    'ATENDIMENTO(S) PARA'    ,                                        
    	                    'ESSE MOTIVO'            )                                        
    	      returning lr_retorno.confirma                                                   
    	                                                                                      
    	      return false                                                                    
    	                                                                                      
        end if                                                                              
                                                                                            
    else                                                                                    
       return true                                                                          
    end if                                                                                  
                                                                                            
    return true                                                                             
                                                                                            
end function 

#-------------------------------------------------#                                                                                                
 function cty22g00_verifica_estado(lr_param)                   
#-------------------------------------------------#                 
                                                                    
define lr_param record                                              
  c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,    
  ufdcod            like datmlcl.ufdcod                
end record                                                          
                                                                    
define lr_retorno record                                            
   confirma   char(01)                                                                                          
end record                                                          
                                                                    
initialize lr_retorno.* to null                                     
                                                                    
    #--------------------------------------------------------  
    # Verifica se o Agrupamento e Motorista Substituto                               
    #--------------------------------------------------------  
    
    if lr_param.c24pbmgrpcod = 239 then
    	    
    	    #--------------------------------------------------------  
    	    # Concessao Somente para SP e RJ                              
    	    #--------------------------------------------------------  
    	    
    	    if lr_param.ufdcod = "SP " or
    	    	 lr_param.ufdcod = "RJ " then 
    	        return true   	    
    	    else
    	  	   
    	  	    call cts08g01('A','N',                        
    	  	                  'ATENDIMENTO NEGADO'       ,      
    	  	                  'MOTORISTA SUBSTITUTO'     ,      
    	  	                  'SOMENTE PARA OS ESTADOS'  ,      
    	  	                  'DE SP E RJ'                )      
    	  	    returning lr_retorno.confirma                 
    	  	       	  	   
    	  	   return false
    	    end if
    	      
     
    end if 
                                                                       
    return true                                                   
                                                                    
                                                                    
end function  

#------------------------------------------------------#
 function cty22g00_valida_natureza_garantia(lr_param)
#------------------------------------------------------#

define lr_param record
  rsrcaogrtcod like datmitaaplitm.rsrcaogrtcod       , 
  itaasiplncod like datkitacbtintrgr.itaasiplncod    ,     
  socntzcod    like datksocntz.socntzcod        
end record

define lr_retorno record
  ctisrvflg     like datritaasiplnnat.ctisrvflg    , 
  ctinaosrvflg  like datritaasiplnnat.ctinaosrvflg                
end record

initialize lr_retorno.* to null

    if m_prepare is null or      
       m_prepare <> true then    
       call cty22g00_prepare()   
    end if  
    
    
    #--------------------------------------------------------
    # Se Garantia nao for Informado nao Restringe                        
    #--------------------------------------------------------
    
    if lr_param.rsrcaogrtcod = 9999 then
      return true
    end if      
    
    #-------------------------------------------------------- 
    # Validacao das Regras Somente para Plano Especial            
    #-------------------------------------------------------- 
    
    if lr_param.itaasiplncod <> 3 then
       return true
    end if                     
        
   
    #--------------------------------------------------------
    # Recupera as Flags do Correntista e Não Correntista
    #--------------------------------------------------------
    
    open c_cty22g00_029  using  lr_param.itaasiplncod,
                                lr_param.socntzcod
    whenever error continue
    fetch c_cty22g00_029 into lr_retorno.ctisrvflg   ,
                              lr_retorno.ctinaosrvflg
    
    whenever error stop
        
    #--------------------------------------------------------
    # Valida Processo Não Correntista     
    #--------------------------------------------------------
    
    if lr_param.rsrcaogrtcod = 1 or
    	 lr_param.rsrcaogrtcod = 2 then
    	 	
    	 	if lr_retorno.ctinaosrvflg = "N" then 
    	 		 return false
    	 	end if	
    	 	
    	 	return true
    	 	
    end if 	
    
    #--------------------------------------------------------      
    # Valida Processo Correntista                               	
    #--------------------------------------------------------      
   
    if lr_param.rsrcaogrtcod = 3 or
    	 lr_param.rsrcaogrtcod = 4 then
    	 	
    	 	if lr_retorno.ctisrvflg = "N" then 
    	 		 return false
    	 	end if	
    	 	
    	 	return true
    	 	
    end if 
    
    return true	 	

end function                                                      
                                                                    