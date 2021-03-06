#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty31g00                                                    #
# Objetivo.......: Tarifa de Dezembro 2013 - Controlador de Limites Clausulas  #
# Analista Resp. : Moises Gabel                                                #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 27/12/2013                                                  #
#..............................................................................#
# 14/05/2015  Alberto/Luiz Fornax CT362561 S54/S85                             #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"


database porto

define m_prepare smallint
define m_acesso  smallint

#----------------------------------------------#
 function cty31g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = "select nscdat,        ",
              "       segsex,        ",
              "       pestip,        ",
              "       cgccpfnum,     ",
              "       cgcord,        ",
              "       cgccpfdig      ",              
              " from gsakseg         ",
              " where segnumdig  = ? "
  prepare pcty31g00001  from l_sql
  declare ccty31g00001  cursor for pcty31g00001

  let l_sql = "select segnumdig,  ",
              "       clalclcod   ",
              " from abbmdoc      ",
              " where succod  = ? ",
              " and aplnumdig = ? ",
              " and itmnumdig = ? ",
              " and dctnumseq = ? "
  prepare pcty31g00002  from l_sql
  declare ccty31g00002  cursor for pcty31g00002

	let l_sql = "select viginc,     ",
	            "       vigfnl      ",
	            " from abamapol     ",
	            " where succod  = ? ",
	            " and aplnumdig = ? "
	prepare pcty31g00003  from l_sql
	declare ccty31g00003  cursor for pcty31g00003


	let l_sql = "select clscod        "
	 				   ," from abbmclaus      "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	           ,"   and clscod in ('033','33R','034','035') "
	prepare pcty31g00004  from l_sql
	declare ccty31g00004  cursor for pcty31g00004


	let l_sql = "select vcl0kmflg,    "
	           ,"       vcluso        "
	 				   ," from abbmveic       "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	prepare pcty31g00005  from l_sql
	declare ccty31g00005  cursor for pcty31g00005

  let l_sql = "select imsvlr,       "
             ,"       ctgtrfcod     "
	 				   ," from abbmcasco      "
	           ," where succod    = ? "
	   				 ,"   and aplnumdig = ? "
	   				 ,"   and itmnumdig = ? "
	    	  	 ,"   and dctnumseq = ? "
	prepare pcty31g00006  from l_sql
	declare ccty31g00006  cursor for pcty31g00006

  let l_sql = "select rspdat           "
	 				   ," from abbmquestionario  "
	           ," where succod    = ?    "
	   				 ,"   and aplnumdig = ?    "
	   				 ,"   and itmnumdig = ?    "
	    	  	 ,"   and dctnumseq = ?    "
	    	  	 ,"   and qstcod    = 2    "
	prepare pcty31g00007 from l_sql
	declare ccty31g00007 cursor for pcty31g00007

  let l_sql = "select rspcod           "
	 				   ," from abbmquestionario  "
	           ," where succod    = ?    "
	   				 ,"   and aplnumdig = ?    "
	   				 ,"   and itmnumdig = ?    "
	    	  	 ,"   and dctnumseq = ?    "
	    	  	 ,"   and qstcod    = 120  "
	prepare pcty31g00008 from l_sql
	declare ccty31g00008 cursor for pcty31g00008

	let l_sql = "select atdsrvnum  "
	           ,"      ,atdsrvano  "
	           ," from datrsrvsau  "
	           ," where bnfnum = ? "
	prepare pcty31g00009 from l_sql
	declare ccty31g00009 cursor for pcty31g00009

	let l_sql = " select atdsrvnum    "
	           ,"       ,atdsrvano    "
	           ," from datrservapol   "
	           ," where ramcod    = ? "
	           ," and succod      = ? "
	           ," and aplnumdig   = ? "
	           ," and itmnumdig   = ? "
	prepare pcty31g00010 from l_sql
	declare ccty31g00010 cursor for pcty31g00010


	let l_sql = " select atdsrvnum           "
	           ,"       ,atdsrvano           "
	           ," from datmligacao a         "
	           ,"     ,datrligprp b          "
	           ," where a.lignum  = b.lignum "
	           ," and b.prporg    = ?        "
	           ," and b.prpnumdig = ?        "
	           ," and a.c24astcod = ?        "
	prepare pcty31g00011 from l_sql
	declare ccty31g00011 cursor for pcty31g00011


  let l_sql = " select c.socntzcod            "
             ," from datmservico a            "
             ,"    , datmligacao b            "
             ,"    , datmsrvre   c            "
             ," where a.atdsrvnum = ?         "
             ," and a.atdsrvano = ?           "
             ," and b.c24astcod = ?           "
             ," and a.atdsrvnum = b.atdsrvnum "
             ," and a.atdsrvano = b.atdsrvano "
             ," and a.atdsrvnum = c.atdsrvnum "
             ," and a.atdsrvano = c.atdsrvano "
  prepare pcty31g00012 from l_sql
  declare ccty31g00012 cursor for pcty31g00012

  let l_sql = " select dctsgmcod           "
             ," from abbmapldctsgm         "
             ," where succod    = ?        "
             ," and   aplnumdig = ?        "
             ," and   itmnumdig = ?        "
             ," and   dctnumseq = ?        "
  prepare pcty31g00013 from l_sql
  declare ccty31g00013 cursor for pcty31g00013
  	
  let l_sql = " select cpodes          "           	
            , " from datkdominio       "           	
            , " where cponom =  ?      "           	
            , " and   cpocod =  ?      "           	
  prepare pcty31g00014 from l_sql              
  declare ccty31g00014 cursor for pcty31g00014
  	
  let l_sql = " select cpocod          "           	
            , " from datkdominio       "           	
            , " where cponom =  ?      "           	
            , " and   cpodes =  ?      "           	
  prepare pcty31g00015 from l_sql              
  declare ccty31g00015 cursor for pcty31g00015
  	
  let l_sql = " select clisgmcod           "
             ," from apamconclisgm         "
             ," where pestipcod = ?        "
             ," and   cpjcpfnum = ?        "
             ," and   cpjordnum = ?        "
             ," and   cpjcpfdig = ?        "  
             ," and   vlddat   >= ?        "
  prepare pcty31g00016 from l_sql
  declare ccty31g00016 cursor for pcty31g00016 	 
  	
  let l_sql = " select cpodes        "             	
             ," from datkdominio     "             	
             ," where cponom =  ?    "             	
  prepare pcty31g00017 from l_sql               	
  declare ccty31g00017 cursor for pcty31g00017  
  	
  let l_sql = " select a.nom          ,           "
             ,"        b.dddcod       ,           "
             ,"        b.lcltelnum    ,           "
             ,"        b.celteldddcod ,           "
             ,"        b.celtelnum                "
             ," from datmservico a ,              "
             ,"      datmlcl b                    "
             ," where a.atdsrvnum = b.atdsrvnum   "
             ," and   a.atdsrvano = b.atdsrvano   "
             ," and   b.c24endtip = 1             "
             ," and   a.atdsrvnum = ?             "
             ," and   a.atdsrvano = ?             "
  prepare pcty31g00018 from l_sql
  declare ccty31g00018 cursor for pcty31g00018 
  	
  
  let l_sql = " select c24srvdsc       "          	
             ," from datmservhist      "          	
             ," where atdsrvnum =  ?   "
             ," and   atdsrvano =  ?   "
             ," order by c24txtseq     "         	
  prepare pcty31g00019 from l_sql               	
  declare ccty31g00019 cursor for pcty31g00019
  	
  
  let l_sql = " select dctsgmcod           "
             ," from apbmprpdctsgm         "
             ," where prporgpcp = ?        "
             ," and   prpnumpcp = ?        "
  prepare pcty31g00020 from l_sql
  declare ccty31g00020 cursor for pcty31g00020	
  	
  let l_sql = " select etpnumdig ",            
                " from apamcapa ",             
               " where prporgpcp = ? ",        
               "   and prpnumpcp = ? "         
  prepare pcty31g00021 from l_sql
  declare ccty31g00021 cursor for pcty31g00021
  	
  let l_sql = " select cgccpfnum ,  ",  
              "        cgcord    ,  ",
              "        cgccpfdig ,  ",    
              "        pestip       ",             	
              " from gsakseg        ",              	
              " where segnumdig = ? "             
  prepare pcty31g00022 from l_sql
  declare ccty31g00022 cursor for pcty31g00022
  	
  let l_sql = " select count(*)      ",             	
              " from abbmapltxt      ",              	
              " where apltxttip = 28 ",             
              " and succod      = ?  ",
              " and aplnumdig   = ?  ",
              " and itmnumdig   = ?  "
  prepare pcty31g00023 from l_sql
  declare ccty31g00023 cursor for pcty31g00023
  	
  let l_sql = " select count(*)      ",             	
              " from apbmprptxt      ",              	
              " where prptxttip = 28 ",             
              " and prporgpcp   = ?  ",
              " and prpnumpcp   = ?  "       
  prepare pcty31g00024 from l_sql
  declare ccty31g00024 cursor for pcty31g00024
  	
  	
 
  let m_prepare = true

end function



#----------------------------------------------#
 function cty31g00_recupera_perfil(lr_param)
#----------------------------------------------#

define lr_param  record
   succod      like datrservapol.succod   ,
   aplnumdig   like datrservapol.aplnumdig,
   itmnumdig   like datrservapol.itmnumdig
end record

define lr_retorno record
  nscdat      like gsakseg.nscdat          ,
  segsex      like gsakseg.segsex          ,
  pestip      like gsakseg.pestip          ,
  viginc      like abamapol.viginc         ,
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  dt_cal      date                         ,
  vcl0kmflg   like abbmveic.vcl0kmflg      ,
  imsvlr      like abbmcasco.imsvlr        ,
  vcluso      like abbmveic.vcluso         ,
  rspdat      like abbmquestionario.rspdat ,
  rspcod      like abbmquestionario.rspcod ,
  ctgtrfcod   like abbmcasco.ctgtrfcod     ,
  clalclcod   like abbmdoc.clalclcod       ,
  dctsgmcod   like abbmapldctsgm.dctsgmcod ,  
  clisgmcod   like apamconclisgm.clisgmcod ,
  cgccpfnum   like gsakseg.cgccpfnum       , 
  cgcord      like gsakseg.cgcord          , 
  cgccpfdig   like gsakseg.cgccpfdig         
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if

  initialize lr_retorno.*, g_nova.* to null

  #-----------------------------------------------------------
  # Recupera os Dados do Segurado
  #-----------------------------------------------------------

  call cty31g00_recupera_dados(lr_param.succod   ,
                               lr_param.aplnumdig,
                               lr_param.itmnumdig)
  returning lr_retorno.nscdat    ,
            lr_retorno.segsex    ,
            lr_retorno.pestip    ,
            lr_retorno.viginc    ,
            lr_retorno.clscod    ,
            lr_retorno.dt_cal    ,
            lr_retorno.vcl0kmflg ,
            lr_retorno.imsvlr    ,
            lr_retorno.vcluso    ,
            lr_retorno.rspdat    ,
            lr_retorno.rspcod    ,
            lr_retorno.ctgtrfcod ,
            lr_retorno.clalclcod ,
            lr_retorno.cgccpfnum ,
            lr_retorno.cgcord    ,
            lr_retorno.cgccpfdig
            


  if m_acesso then

      
      #-----------------------------------------------------------  
      # Recupera o Tipo de Atendimento                       
      #-----------------------------------------------------------  
      
      call cty31g00_recupera_tipo_atendimento(lr_retorno.pestip    ,
                                              lr_retorno.cgccpfnum ,
                                              lr_retorno.cgcord    ,
                                              lr_retorno.cgccpfdig )
      returning lr_retorno.clisgmcod  
      
      
      #----------------------------------------------------------- 
      # Recupera o Segmento Auto do Segurado                              
      #----------------------------------------------------------- 
      
      call cty31g00_recupera_segmento(lr_param.succod    , 
                                      lr_param.aplnumdig ,
                                      lr_param.itmnumdig ,
                                      g_funapol.dctnumseq)
      returning lr_retorno.perfil ,
                lr_retorno.dctsgmcod
      
      if lr_retorno.perfil is null then
      
          
          #----------------------------------------------------------- 
          # Recupera o Segmento Central do Segurado                        
          #----------------------------------------------------------- 
          
          call cty31g00_calcula_perfil(lr_retorno.nscdat    ,
                                       lr_retorno.segsex    ,
                                       lr_retorno.pestip    ,
                                       lr_retorno.viginc    ,
                                       lr_retorno.vcluso    ,
                                       lr_retorno.rspdat    ,
                                       lr_retorno.rspcod    ,
                                       lr_retorno.ctgtrfcod ,
                                       lr_retorno.imsvlr    )
          returning lr_retorno.perfil
          
          #----------------------------------------------------------- 
          # Recupera o Segmento do Auto                              
          #----------------------------------------------------------- 
          
          call cty31g00_recupera_parade(lr_retorno.perfil)
          returning lr_retorno.dctsgmcod 
          
      
      end if    


	end if


	return lr_retorno.perfil    ,
	       lr_retorno.clscod    ,
	       lr_retorno.dt_cal    ,
	       lr_retorno.vcl0kmflg ,
         lr_retorno.imsvlr    ,
         lr_retorno.ctgtrfcod ,
         lr_retorno.clalclcod ,
         lr_retorno.dctsgmcod ,
         lr_retorno.clisgmcod         

end function



#----------------------------------------------#
 function cty31g00_recupera_dados(lr_param)
#----------------------------------------------#

define lr_param  record
   succod      like datrservapol.succod     ,
   aplnumdig   like datrservapol.aplnumdig  ,
   itmnumdig   like datrservapol.itmnumdig
end record

define lr_retorno record
   segnumdig      like gsakseg.segnumdig       ,
   sgrorg         like rsamseguro.sgrorg       ,
   sgrnumdig      like rsamseguro.sgrnumdig    ,
   nscdat         like gsakseg.nscdat          ,
   segsex         like gsakseg.segsex          ,
   pestip         like gsakseg.pestip          ,
   viginc         like abamapol.viginc         ,
   vigfnl         like abamapol.vigfnl         ,
   clscod         like abbmclaus.clscod        ,
   acesso         smallint                     ,
   data_calculo   date                         ,
   flag_endosso   char(01)                     ,
   erro           integer                      ,
   clausula       like abbmclaus.clscod        ,
   vcl0kmflg      like abbmveic.vcl0kmflg      ,
   imsvlr         like abbmcasco.imsvlr        ,
   vcluso         like abbmveic.vcluso         ,
   rspdat         like abbmquestionario.rspdat ,
   rspcod         like abbmquestionario.rspcod ,
   ctgtrfcod      like abbmcasco.ctgtrfcod     ,
   clalclcod      like abbmdoc.clalclcod       ,
   cgccpfnum      like gsakseg.cgccpfnum       ,
   cgcord         like gsakseg.cgcord          ,
   cgccpfdig      like gsakseg.cgccpfdig  
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if

  initialize lr_retorno.* to null

  let m_acesso = false

      #-----------------------------------------------------------
      # Localiza o Numero do Segurado
      #-----------------------------------------------------------


       if lr_param.succod    is not null  and
          lr_param.aplnumdig is not null  and
          lr_param.itmnumdig is not null  then


          if g_funapol.dctnumseq is null  then
             call f_funapol_ultima_situacao (lr_param.succod,
                                             lr_param.aplnumdig,
                                             lr_param.itmnumdig)
             returning g_funapol.*
          end if

          open ccty31g00002  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty31g00002 into lr_retorno.segnumdig,
                                  lr_retorno.clalclcod
          whenever error stop

          close ccty31g00002


          #-----------------------------------------------------------
          # Recupera a Vigencia da Apolice
          #-----------------------------------------------------------

          open ccty31g00003  using lr_param.succod    ,
                                   lr_param.aplnumdig
          whenever error continue
          fetch ccty31g00003 into lr_retorno.viginc,
                                  lr_retorno.vigfnl

          whenever error stop

          close ccty31g00003

          #-----------------------------------------------------------
          # Recupera a Clausula da Apolice
          #-----------------------------------------------------------

          open ccty31g00004  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty31g00004 into lr_retorno.clscod

          whenever error stop

          close ccty31g00004
          #-----------------------------------------------------------
          # Valida Duplicacao de Clausula 034
          #-----------------------------------------------------------
          if lr_retorno.clscod = "034" then
          	 if cta13m00_verifica_clausula(lr_param.succod      ,
                                           lr_param.aplnumdig   ,
                                           lr_param.itmnumdig   ,
                                           g_funapol.dctnumseq  ,
                                           lr_retorno.clscod    ) then
                let lr_retorno.clscod = null
             end if
          end if

          #-----------------------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------------------

          open ccty31g00001 using lr_retorno.segnumdig

          whenever error continue
          fetch ccty31g00001 into lr_retorno.nscdat     ,
                                  lr_retorno.segsex     ,
                                  lr_retorno.pestip     ,
                                  lr_retorno.cgccpfnum  ,
                                  lr_retorno.cgcord     ,
                                  lr_retorno.cgccpfdig
          whenever error stop

          close ccty31g00001


          #-----------------------------------------------------------
          # Recupera a Data de Calculo
          #-----------------------------------------------------------

          call faemc144_clausula(lr_param.succod         ,
                                 lr_param.aplnumdig      ,
                                 lr_param.itmnumdig)
                       returning lr_retorno.erro         ,
                                 lr_retorno.clausula     ,
                                 lr_retorno.data_calculo ,
                                 lr_retorno.flag_endosso


          #-----------------------------------------------------------
          # Recupera Se o Veiculo e 0KM
          #-----------------------------------------------------------

          open ccty31g00005  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty31g00005 into lr_retorno.vcl0kmflg,
                                  lr_retorno.vcluso

          whenever error stop

          close ccty31g00005

          #-----------------------------------------------------------
          # Recupera a Importancia Segurada
          #-----------------------------------------------------------

          open ccty31g00006  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.autsitatu
          whenever error continue
          fetch ccty31g00006 into lr_retorno.imsvlr,
                                  lr_retorno.ctgtrfcod

          whenever error stop


          close ccty31g00006

          #-----------------------------------------------------------
          # Recupera a Data de Nascimento do Principal Condutor
          #-----------------------------------------------------------

          open ccty31g00007  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty31g00007 into lr_retorno.rspdat

          whenever error stop


          close ccty31g00007

          #-----------------------------------------------------------
          # Recupera o Sexo do Principal Condutor
          #-----------------------------------------------------------

          open ccty31g00008  using lr_param.succod    ,
                                   lr_param.aplnumdig ,
                                   lr_param.itmnumdig ,
                                   g_funapol.dctnumseq
          whenever error continue
          fetch ccty31g00008 into lr_retorno.rspcod

          whenever error stop


          close ccty31g00008




       end if

       if  lr_retorno.pestip is not null and
           lr_retorno.viginc is not null then
           	   let m_acesso = true
       end if


       return  lr_retorno.nscdat
              ,lr_retorno.segsex
              ,lr_retorno.pestip
              ,lr_retorno.viginc
              ,lr_retorno.clscod
              ,lr_retorno.data_calculo
              ,lr_retorno.vcl0kmflg
              ,lr_retorno.imsvlr
              ,lr_retorno.vcluso
              ,lr_retorno.rspdat
              ,lr_retorno.rspcod
              ,lr_retorno.ctgtrfcod
              ,lr_retorno.clalclcod     
              ,lr_retorno.cgccpfnum
              ,lr_retorno.cgcord   
              ,lr_retorno.cgccpfdig

end function

#----------------------------------------------#
 function cty31g00_calcula_perfil(lr_param)
#----------------------------------------------#

define lr_param record
  nscdat     like gsakseg.nscdat          ,
  segsex     like gsakseg.segsex          ,
  pestip     like gsakseg.pestip          ,
  viginc     like abamapol.viginc         ,
  vcluso     like abbmveic.vcluso         ,
  rspdat     like abbmquestionario.rspdat ,
  rspcod     like abbmquestionario.rspcod ,
  ctgtrfcod  like abbmcasco.ctgtrfcod     ,
  imsvlr     like abbmcasco.imsvlr
end record

define lr_retorno record
  idade  integer  ,
  perfil smallint ,
  dias   dec(10,2)
end record

#-----------------------------------------------------------
# Segmento 1 = Tradicional (25 a 59 anos)
# Segmento 2 = Jovem (Menor de 25 anos)
# Segmento 3 = Senior ( Maior de 59 anos)
# Segmento 4 = Mulher (Sexo: F)
# Segmento 5 = Taxi
# Segmento 6 = Caminhao
# Segmento 7 = Moto
# Segmento 8 = Auto Premium
# Segmento 9 = Juridica
#-----------------------------------------------------------

initialize lr_retorno.* to null


   let lr_retorno.dias  = 365.25

   let lr_retorno.idade = ((lr_param.viginc - lr_param.rspdat)/lr_retorno.dias)

   #--------------#
   # Tradicional  #
   #--------------#

   let lr_retorno.perfil = 1

   #------------------------------#
   # Valida se o Segmento e Moto  #
   #------------------------------#

   if cty31g00_valida_segmento_moto(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 7

      return lr_retorno.perfil
   end if


   #------------------------------#
   # Valida se o Segmento e Taxi  #
   #------------------------------#

   if cty31g00_valida_segmento_taxi(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 5

      return lr_retorno.perfil
   end if


   #----------------------------------#
   # Valida se o Segmento e Caminhao  #
   #----------------------------------#

   if cty31g00_valida_segmento_caminhao(lr_param.ctgtrfcod) then
      let lr_retorno.perfil = 6

      return lr_retorno.perfil
   end if

   #----------------------------------#
   # Valida se o Segmento e Premium   #
   #----------------------------------#

   #if cty31g00_valida_segmento_premium(lr_retorno.idade,
   #	                                   lr_param.imsvlr ) then
   #   let lr_retorno.perfil = 8
   #
   #   return lr_retorno.perfil
   #end if

   if lr_param.pestip = "F" then

      	 #----------------------------------#
      	 # Valida se o Segmento e Mulher    #
      	 #----------------------------------#

      	 if cty31g00_valida_segmento_mulher(lr_retorno.idade,
      	 	                                  lr_param.rspcod ) then
      	    let lr_retorno.perfil = 4

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Jovem     #
      	 #----------------------------------#

      	 if cty31g00_valida_segmento_jovem(lr_retorno.idade) then
      	    let lr_retorno.perfil = 2

      	    return lr_retorno.perfil
      	 end if


      	 #----------------------------------#
      	 # Valida se o Segmento e Senior    #
      	 #----------------------------------#

      	 if cty31g00_valida_segmento_senior(lr_retorno.idade) then
      	    let lr_retorno.perfil = 3

      	    return lr_retorno.perfil
      	 end if

 	 end if 
 	 
 	 
 	 #-------------------------------------------#
 	 # Valida se o Segmento e Pessoa Juridica    # 
 	 #-------------------------------------------#	 

 	 if lr_param.pestip = "J" then
 	 	  let lr_retorno.perfil = 9 	
 	 end if

   return lr_retorno.perfil

end function

#----------------------------------------------#
 function cty31g00_valida_limite(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     if cty36g00_acesso() then
   	    call cty36g00_valida_limite(lr_param.c24astcod  ,
                                    lr_param.clscod     ,
                                    lr_param.perfil     ,
                                    lr_param.socntzcod  )
        returning lr_retorno.limite
   	    return lr_retorno.limite
     end if

     case lr_param.c24astcod
        when "S10"
        	  call  cty31g00_recupera_limite_S10(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "M20"
        	  call  cty31g00_recupera_limite_M20(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "S54"
        	  call  cty31g00_recupera_limite_S54(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "S40"
        	  call  cty31g00_recupera_limite_S40(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "S80"
        	  call  cty31g00_recupera_limite_S80(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "S81"
        	  call  cty31g00_recupera_limite_S81(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "S60"
        	  call  cty31g00_recupera_limite_S60(lr_param.clscod, lr_param.perfil, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S63"
        	  call  cty31g00_recupera_limite_S63(lr_param.clscod, lr_param.perfil, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S41"
        	  call  cty31g00_recupera_limite_S41(lr_param.clscod, lr_param.perfil, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S42"
        	  call  cty31g00_recupera_limite_S42(lr_param.clscod, lr_param.perfil, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S85"
        	  call  cty31g00_recupera_limite_S85(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "SLV"
        	  call  cty31g00_recupera_limite_SLV(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite
        when "SLT"
        	  call  cty31g00_recupera_limite_SLT(lr_param.clscod, lr_param.perfil)
        	  returning lr_retorno.limite


     end case

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_valida_km(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  asitipcod   like datkasitip.asitipcod   ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km    integer ,
  flag_atende  char(01)
end record

initialize lr_retorno.* to null
     if cty36g00_acesso() then
   	    call cty36g00_valida_km(lr_param.c24astcod  ,
                                lr_param.clscod     ,
                                lr_param.perfil     ,
                                lr_param.asitipcod  ,
                                lr_param.asimvtcod  )
        returning lr_retorno.limite_km   ,
                  lr_retorno.flag_atende
   	    return lr_retorno.limite_km   ,
   	           lr_retorno.flag_atende
     end if

let lr_retorno.flag_atende = "S"

     case lr_param.c24astcod
        when "S10"
        	  call  cty31g00_recupera_km_S10(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "M20"
        	  call  cty31g00_recupera_km_M20(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "S54"
        	  call  cty31g00_recupera_km_S54(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "S40"
        	  call  cty31g00_recupera_km_S40(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	  	                             lr_param.asitipcod,
        	  	                             lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "S80"
        	  call  cty31g00_recupera_km_S80(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "S23"
        	  call  cty31g00_recupera_km_S23(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km ,
        	            lr_retorno.flag_atende

        when "M23"
        	  call  cty31g00_recupera_km_M23(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km ,
        	            lr_retorno.flag_atende

        when "S33"
        	  call  cty31g00_recupera_km_S33(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km ,
        	            lr_retorno.flag_atende

        when "M33"
        	  call  cty31g00_recupera_km_M33(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km ,
        	            lr_retorno.flag_atende


        when "S81"
        	  call  cty31g00_recupera_km_S81(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "S29"
        	  call  cty31g00_recupera_km_S29(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km ,
        	            lr_retorno.flag_atende
        when "SLV"
        	  call  cty31g00_recupera_km_SLV(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km
        when "SLT"
        	  call  cty31g00_recupera_km_SLT(lr_param.clscod   ,
        	                                 lr_param.perfil   ,
        	                                 lr_param.asitipcod,
        	                                 lr_param.asimvtcod)
        	  returning lr_retorno.limite_km


     end case

     return lr_retorno.limite_km   ,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_valida_data()
#----------------------------------------------#

  if g_nova.dt_cal >= "01/02/2014" then
     return true
  else
  	 return false
  end if
end function

#----------------------------------------------#
 function cty31g00_valida_perfil()
#----------------------------------------------#

  if g_nova.perfil is not null then
     return true
  else
  	 return false
  end if
end function
#----------------------------------------------#
 function cty31g00_valida_clausula()
#----------------------------------------------#

   if g_nova.clscod = "033"  or
      g_nova.clscod = "33R"  or
      g_nova.clscod = "034"  or
      g_nova.clscod = "035"  then

      return true
   else

   	  return false
   end if

end function
#----------------------------------------------#
 function cty31g00_nova_regra_clausula(lr_param)
#----------------------------------------------#

define lr_param record
    c24astcod   like datkassunto.c24astcod
end record

  if cty36g00_acesso() then
  	 if cty36g00_nova_regra_clausula(lr_param.c24astcod) then
  	      return true
     else
          return false
     end if
  end if

  if cty31g00_valida_data()     and
     cty31g00_valida_perfil()   and
     cty31g00_valida_clausula() then

     if cty31g00_acesso_perfil(lr_param.c24astcod) then
  	  	   return true
     else
           return false
     end if
  else
      return false
  end if

end function

#----------------------------------------------#
 function cty31g00_acesso_perfil(lr_param)
#----------------------------------------------#

define lr_param record
    c24astcod   like datkassunto.c24astcod
end record

    if g_nova.perfil <> 2 then
    	 return true
    else
    	 if lr_param.c24astcod = "S80" or
    	 	  lr_param.c24astcod = "SLV" or
    	 	  lr_param.c24astcod = "SLT" or
    	 	  lr_param.c24astcod = "S40" then 
    	    return true
    	 else
    	 	  return false
    	 end if
    end if

end function

#-------------------------------------------------------
function cty31g00_valida_envio_socorro(lr_param)
#-------------------------------------------------------

 define lr_param record
     ramcod      smallint
    ,succod      like abbmitem.succod
    ,aplnumdig   like abbmitem.aplnumdig
    ,itmnumdig   like abbmitem.itmnumdig
    ,c24astcod   like datkassunto.c24astcod
 end record

 define lr_retorno           record
     erro                    smallint
    ,data_calculo            date
    ,clscod                  char(05)
    ,flag_endosso            char(01)
    ,flag_limite             char(1)
    ,resultado               integer
    ,mensagem                char(80)
    ,qtd_ap                  integer
    ,qtd_pr                  integer
    ,qtd_at                  integer
    ,prporgpcp               like abamdoc.prporgpcp
    ,prpnumpcp               like abamdoc.prpnumpcp
    ,limite                  integer
    ,limite_km               integer
 end record


 initialize  lr_retorno.*  to  null


 let lr_retorno.qtd_ap  = 0
 let lr_retorno.qtd_pr  = 0
 let lr_retorno.qtd_at  = 0

 #-----------------------------------------------------------
 # Obter a Data de Calculo
 #-----------------------------------------------------------

 call faemc144_clausula(lr_param.succod         ,
                        lr_param.aplnumdig      ,
                        lr_param.itmnumdig)
              returning lr_retorno.erro         ,
                        lr_retorno.clscod       ,
                        lr_retorno.data_calculo ,
                        lr_retorno.flag_endosso

 if lr_retorno.erro  <> 0 then

    let lr_retorno.flag_limite = "N"
    let lr_retorno.resultado   = 2
    let lr_retorno.mensagem    =  "Erro no Acesso a Funcao Faemc144."

    return lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite

 end if

 #-----------------------------------------------------------
 # Obter a Quantidade de Atendimentos de Envio de Socorro
 #-----------------------------------------------------------

 let lr_retorno.qtd_ap = cta02m15_qtd_envio_socorro(lr_param.ramcod
                                                   ,lr_param.succod
                                                   ,lr_param.aplnumdig
                                                   ,lr_param.itmnumdig,"",""
                                                   ,lr_retorno.data_calculo)

 #-------------------------------------------------------------------
 # Se Nao tem Endosso, Contar os Servicos Realizados pela Proposta
 #-------------------------------------------------------------------


 if lr_retorno.flag_endosso = "N" then

    #-----------------------------------------------------------
    # Obter a Proposta Original Atraves da Apolice
    #-----------------------------------------------------------

    call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
       returning  lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,lr_retorno.prporgpcp
                 ,lr_retorno.prpnumpcp

    if lr_retorno.resultado <> 1 then

       let lr_retorno.flag_limite = "N"

       return  lr_retorno.resultado
              ,lr_retorno.mensagem
              ,lr_retorno.flag_limite


    end if

    let lr_retorno.qtd_pr = cta02m15_qtd_envio_socorro(""                   ,
                                                       ""                   ,
                                                       ""                   ,
                                                       ""                   ,
                                                       lr_retorno.prporgpcp ,
                                                       lr_retorno.prpnumpcp ,
                                                       lr_retorno.data_calculo)
 end if

 let lr_retorno.qtd_at = lr_retorno.qtd_ap + lr_retorno.qtd_pr

 let lr_retorno.resultado = 1
 let lr_retorno.mensagem  = null

 call cty31g00_valida_limite(lr_param.c24astcod,
                             g_nova.clscod     ,
                             g_nova.perfil     ,
                             ""                )
 returning lr_retorno.limite



 if lr_retorno.qtd_at >= lr_retorno.limite then
      let lr_retorno.flag_limite = "S"
 else
 	    let lr_retorno.flag_limite = "N"
 end if


 return  lr_retorno.resultado
        ,lr_retorno.mensagem
        ,lr_retorno.flag_limite


end function

#-------------------------------------------------------
function cty31g00_valida_envio_residencia(lr_param)
#-------------------------------------------------------

 define lr_param record
     ramcod      smallint
    ,succod      like abbmitem.succod
    ,aplnumdig   like abbmitem.aplnumdig
    ,itmnumdig   like abbmitem.itmnumdig
    ,c24astcod   like datkassunto.c24astcod
    ,bnfnum      like datrsrvsau.bnfnum
    ,crtsaunum   like datksegsau.crtsaunum
    ,socntzcod   like datksocntz.socntzcod
 end record

 define lr_retorno           record
     erro                    smallint
    ,data_calculo            date
    ,clscod                  char(05)
    ,flag_endosso            char(01)
    ,flag_limite             char(1)
    ,resultado               integer
    ,mensagem                char(80)
    ,qtd_ap                  integer
    ,qtd_pr                  integer
    ,qtd_at                  integer
    ,qtd_re                  integer
    ,qtd_bas                 integer
    ,qtd_bra                 integer
    ,qtd_ag                  integer
    ,prporgpcp               like abamdoc.prporgpcp
    ,prpnumpcp               like abamdoc.prpnumpcp
    ,limite                  integer
    ,limite_km               integer
    ,plncod                  like datkplnsau.plncod
    ,plndes                  like datkplnsau.plndes
    ,datac                   char(10)
 end record


 initialize  lr_retorno.*  to  null


 let lr_retorno.qtd_ap  = 0
 let lr_retorno.qtd_pr  = 0
 let lr_retorno.qtd_at  = 0
 let lr_retorno.qtd_re  = 0
 let lr_retorno.qtd_bas = 0
 let lr_retorno.qtd_bra = 0
 let lr_retorno.qtd_ag  = 0

 if lr_param.bnfnum is not null then

    #-----------------------------------------------------------
    # Obter o Plano Para Contagem dos Servicos - Saude
    #-----------------------------------------------------------

    call cta01m15_sel_datksegsau(4, lr_param.crtsaunum, "","","")
    returning lr_retorno.resultado    ,
              lr_retorno.mensagem     ,
              lr_retorno.plncod       ,
              lr_retorno.data_calculo

    let lr_retorno.datac = '01/01/', year(today) using "####"
    let lr_retorno.data_calculo = lr_retorno.datac

    #-----------------------------------------------------------
    # Obter o Limite de Utilizacao do Plano - Saude
    #-----------------------------------------------------------

    call cta01m16_sel_datkplnsau(lr_retorno.plncod )
    returning lr_retorno.resultado  ,
              lr_retorno.mensagem   ,
              lr_retorno.plndes     ,
              lr_retorno.limite

  else

    #-----------------------------------------------------------
    # Obter a Data de Calculo
    #-----------------------------------------------------------

    call faemc144_clausula(lr_param.succod         ,
                           lr_param.aplnumdig      ,
                           lr_param.itmnumdig)
                 returning lr_retorno.erro         ,
                           lr_retorno.clscod       ,
                           lr_retorno.data_calculo ,
                           lr_retorno.flag_endosso

    if lr_retorno.erro  <> 0 then

       let lr_retorno.flag_limite = "N"
       let lr_retorno.resultado   = 2
       let lr_retorno.mensagem    =  "Erro no Acesso a Funcao Faemc144."

       return lr_retorno.resultado
             ,lr_retorno.mensagem
             ,lr_retorno.flag_limite
             ,lr_retorno.qtd_at
             ,lr_retorno.limite


    end if
  end if

   #-----------------------------------------------------------
   # Recupera o Limite
   #-----------------------------------------------------------

   call cty31g00_valida_limite(lr_param.c24astcod   ,
                               g_nova.clscod        ,
                               g_nova.perfil        ,
                               lr_param.socntzcod   )
   returning lr_retorno.limite
   if lr_param.c24astcod = "S60" or
      lr_param.c24astcod = "S63" then
       call framo705_qtd_servicos(lr_retorno.clscod,
                                  lr_param.succod  ,
                                  lr_param.ramcod  ,
                                  lr_param.aplnumdig)
       returning lr_retorno.qtd_bas,
                 lr_retorno.qtd_bra
       if lr_retorno.qtd_bas is null then
          let lr_retorno.qtd_bas = 0
       end if

       if lr_retorno.qtd_bra is null then
          let lr_retorno.qtd_bra = 0
       end if

       if lr_param.c24astcod = "S60" then
          let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bas
       end if

       if lr_param.c24astcod = "S63" then
          let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bra
       end if

   else


   	  if lr_param.c24astcod = "S41" or
   	  	 lr_param.c24astcod = "S42" then

   	     call framo705_qtd_servicos(lr_retorno.clscod ,
                                    lr_param.succod   ,
                                    lr_param.ramcod   ,
                                    lr_param.aplnumdig)
   	     returning lr_retorno.qtd_bas,
   	               lr_retorno.qtd_bra


   	     if lr_retorno.qtd_bas is null then
   	        let lr_retorno.qtd_bas = 0
   	     end if

   	     if lr_retorno.qtd_bra is null then
            let lr_retorno.qtd_bra = 0
         end if
         if lr_param.c24astcod = "S41" then
            let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bas
         end if
   	     if lr_param.c24astcod = "S42" then
            let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bra
         end if
   	  end if

   end if


   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos de Envio de Residencia
   #-----------------------------------------------------------

   if lr_param.c24astcod = "S60" or
   	  lr_param.c24astcod = "S63" then

      call cty31g00_quantidade_residencia(lr_param.ramcod
                                         ,lr_param.succod
                                         ,lr_param.aplnumdig
                                         ,lr_param.itmnumdig
                                         ,lr_retorno.data_calculo
                                         ,lr_param.c24astcod
                                         ,lr_param.bnfnum
                                         ,lr_retorno.flag_endosso
                                         ,lr_param.socntzcod)
      returning lr_retorno.resultado,
                lr_retorno.mensagem ,
                lr_retorno.qtd_at

    else

    	call cty05g02_qtd_srv_res(lr_param.ramcod
                               ,lr_param.succod
                               ,lr_param.aplnumdig
                               ,lr_param.itmnumdig
                               ,lr_retorno.data_calculo
                               ,lr_param.c24astcod
                               ,lr_param.bnfnum
                               ,lr_retorno.flag_endosso)
      returning lr_retorno.resultado,
                lr_retorno.mensagem ,
                lr_retorno.qtd_at
      #-----------------------------------------------------------
      # Obter a Quantidade de Atendimentos Agregados
      #-----------------------------------------------------------

      let lr_retorno.qtd_ag = cty31g00_calcula_agregacao(lr_param.ramcod         ,
                                                         lr_param.succod         ,
                                                         lr_param.aplnumdig      ,
                                                         lr_param.itmnumdig      ,
                                                         lr_param.c24astcod      ,
                                                         lr_retorno.data_calculo )

      let lr_retorno.qtd_at = lr_retorno.qtd_at + lr_retorno.qtd_ag
    end if

   if lr_retorno.resultado <> 1 then

      let lr_retorno.flag_limite = "N"

      return lr_retorno.resultado       ,
             lr_retorno.mensagem        ,
             lr_retorno.flag_limite     ,
             lr_retorno.qtd_at          ,
             lr_retorno.limite


   end if

   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null

   if lr_retorno.qtd_at >= lr_retorno.limite then
        let lr_retorno.flag_limite = "S"
   else
   	    let lr_retorno.flag_limite = "N"
   end if


   if lr_retorno.flag_limite = "N" then

     if lr_param.c24astcod = "S41" or
        lr_param.c24astcod = "S42" then

        call cty05g02_qtd_servicos(lr_param.ramcod
                                  ,lr_param.succod
                                  ,lr_param.aplnumdig
                                  ,lr_param.itmnumdig
                                  ,lr_retorno.data_calculo
                                  ,lr_param.c24astcod
                                  ,lr_param.bnfnum
                                  ,lr_retorno.flag_endosso
                                  ,lr_retorno.limite)
        returning lr_retorno.flag_limite

     end if

   end if


   return  lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite
          ,lr_retorno.qtd_at
          ,lr_retorno.limite


end function

#-------------------------------------------------------
function cty31g00_valida_envio_lei_seca(lr_param)
#-------------------------------------------------------

 define lr_param record
     ramcod      smallint
    ,succod      like abbmitem.succod
    ,aplnumdig   like abbmitem.aplnumdig
    ,itmnumdig   like abbmitem.itmnumdig
    ,c24astcod   like datkassunto.c24astcod
 end record

 define lr_retorno           record
     erro                    smallint
    ,data_calculo            date
    ,clscod                  char(05)
    ,flag_endosso            char(01)
    ,flag_limite             char(1)
    ,resultado               integer
    ,mensagem                char(80)
    ,qtd_ap                  integer
    ,qtd_at                  integer
    ,prporgpcp               like abamdoc.prporgpcp
    ,prpnumpcp               like abamdoc.prpnumpcp
    ,limite                  integer
    ,limite_km               integer
 end record


 initialize  lr_retorno.*  to  null


 let lr_retorno.qtd_ap  = 0
 let lr_retorno.qtd_at  = 0

 #-----------------------------------------------------------
 # Obter a Data de Calculo
 #-----------------------------------------------------------

 call faemc144_clausula(lr_param.succod         ,
                        lr_param.aplnumdig      ,
                        lr_param.itmnumdig)
              returning lr_retorno.erro         ,
                        lr_retorno.clscod       ,
                        lr_retorno.data_calculo ,
                        lr_retorno.flag_endosso

 if lr_retorno.erro  <> 0 then

    let lr_retorno.flag_limite = "N"
    let lr_retorno.resultado   = 2
    let lr_retorno.mensagem    =  "Erro no Acesso a Funcao Faemc144."

    return lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite

 end if

 #-----------------------------------------------------------
 # Obter a Quantidade de Atendimentos da Lei Seca
 #-----------------------------------------------------------

  let lr_retorno.qtd_ap =  cty26g01_qtd_servico_s54(lr_param.ramcod
				                                           ,lr_param.succod
				                                           ,lr_param.aplnumdig
				                                           ,lr_param.itmnumdig
                                                   ,""
				                                           ,""
				                                           ,lr_retorno.data_calculo
				                                           ,lr_param.c24astcod )


 let lr_retorno.qtd_at = lr_retorno.qtd_ap

 let lr_retorno.resultado = 1
 let lr_retorno.mensagem  = null

 call cty31g00_valida_limite(lr_param.c24astcod,
                             g_nova.clscod     ,
                             g_nova.perfil     ,
                             ""                )
 returning lr_retorno.limite



 if lr_retorno.qtd_at >= lr_retorno.limite then
      let lr_retorno.flag_limite = "S"
 else
 	    let lr_retorno.flag_limite = "N"
 end if


 return  lr_retorno.resultado
        ,lr_retorno.mensagem
        ,lr_retorno.flag_limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S10(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 5
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 999
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 5
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 999
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 5
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 999
           end if

     end case

     return  lr_retorno.limite



end function

#----------------------------------------------#
 function cty31g00_recupera_limite_M20(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 999
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

     end case

     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S54(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     #Alterado todos os limites, conforme solicitado no chamado 363392
     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 2
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 2
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 2
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 6
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 2
           end if

     end case




     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S40(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 2
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 2
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 2
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 2
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if
     end case

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S80(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer,
  agrega      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 1
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 1
           end if


     end case

     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S81(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer,
  agrega      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 1
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 1
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1

               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega

               #----------------------------------------------#
               # Verifica a Importancia Segurada
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_alta_IS()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 1
               #----------------------------------------------#
               # Verifica Se o Veiculo e 0KM
               #----------------------------------------------#
               let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
               let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 1
           end if


     end case

     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S60(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 999
                end if
           end if
           if lr_param.clscod = "33R" then
           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if
           end if
           if lr_param.clscod = "034" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if
           end if
           if lr_param.clscod = "035" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
                  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 141 or   # Chave Tetra
                  lr_param.socntzcod = 287 or   # Troca de Lampada
                  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if
           end if
        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
           	   	  lr_param.socntzcod = 317 then # Barra de Apoio
                     let lr_retorno.limite  = 999
                end if

                if lr_param.socntzcod = 41  or    # Kit 1
           	   	   lr_param.socntzcod = 42  then  # Kit 2
                     let lr_retorno.limite  = 1
                end if

                if lr_param.socntzcod = 206  then  # Conectividade
                     let lr_retorno.limite  = 2
                end if

                if lr_param.socntzcod = 207  then  # Mudanca de Mobiliario
                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
           	   	  lr_param.socntzcod = 317 then # Barra de Apoio
                     let lr_retorno.limite  = 3
                end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
           	   	  lr_param.socntzcod = 317 then # Barra de Apoio
                     let lr_retorno.limite  = 3
                end if

                if lr_param.socntzcod = 41  or    # Kit 1
           	   	   lr_param.socntzcod = 42  then  # Kit 2
                     let lr_retorno.limite  = 1
                end if

                if lr_param.socntzcod = 206  then  # Conectividade
                     let lr_retorno.limite  = 2
                end if

                if lr_param.socntzcod = 207  then  # Mudanca de Mobiliario
                     let lr_retorno.limite  = 1
                end if

           end if

        when 4 # Mulher
          if lr_param.clscod = "033" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 999
                end if

                if lr_param.socntzcod = 41  or    # Kit 1
           	   	   lr_param.socntzcod = 42  then  # Kit 2
                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 5   or   # Chaveiro
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 141 or   # Chave Tetra
           	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
           	   	  lr_param.socntzcod = 288 then # Desentupimento Area Externa
                     let lr_retorno.limite  = 3
                end if

                if lr_param.socntzcod = 41  or    # Kit 1
           	   	   lr_param.socntzcod = 42  then  # Kit 2
                     let lr_retorno.limite  = 1
                end if

           end if

     end case


     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S63(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 999
               end if

               if lr_param.socntzcod = 28   or     # Ar Condicionado
                  lr_param.socntzcod = 104  then   # Ar Condicionado
                     let lr_retorno.limite  = 999
               end if


           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 0
               end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 999
               end if

               if lr_param.socntzcod = 28   or     # Ar Condicionado
                  lr_param.socntzcod = 104  then   # Ar Condicionado
                     let lr_retorno.limite  = 999
               end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 0
               end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

        when 4 # Mulher
          if lr_param.clscod = "033" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 999
               end if

               if lr_param.socntzcod = 28   or     # Ar Condicionado
                  lr_param.socntzcod = 104  then   # Ar Condicionado
                     let lr_retorno.limite  = 999
               end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 0
               end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 11   or   # Telefonia
           	   	  lr_param.socntzcod = 12   or   # Geladeira
           	   	  lr_param.socntzcod = 13   or   # Fogao
           	   	  lr_param.socntzcod = 14   or   # Lavadoura
           	   	  lr_param.socntzcod = 15   or   # Lava Louca
           	   	  lr_param.socntzcod = 16   or   # Freezer
           	   	  lr_param.socntzcod = 17   or   # Secadora
           	   	  lr_param.socntzcod = 19   or   # Microondas
           	   	  lr_param.socntzcod = 47   or   # Reversao de Fogao
                  lr_param.socntzcod = 243  or   # Tanquinho
                  lr_param.socntzcod = 300  or   # Geladeira Side by Side
                  lr_param.socntzcod = 301  or   # Ar Condicionado Split
                  lr_param.socntzcod = 302  then # Lava Roupas (Lava e Seca)
                     let lr_retorno.limite  = 3
               end if

           end if

     end case

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S41(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 1
                end if
           end if
           if lr_param.clscod = "33R" then
           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho

                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if
        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if
           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if
           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if
        when 3  # Senior
           if lr_param.clscod = "033" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if
           end if
           if lr_param.clscod = "33R" then
           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if
           end if
           if lr_param.clscod = "034" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
           if lr_param.clscod = "035" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
        when 4 # Mulher
          if lr_param.clscod = "033" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
               	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 288 or   # Desentupimento Area Externa
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if
     end case
     return  lr_retorno.limite
end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S42(lr_param)
#----------------------------------------------#
define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  socntzcod   like datksocntz.socntzcod
end record
define lr_retorno record
  limite      integer
end record
initialize lr_retorno.* to null
     let lr_retorno.limite     = 0
     case lr_param.perfil
     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "33R" then

           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 1
                end if

           end if

           if lr_param.clscod = "034" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if

           if lr_param.clscod = "035" then

               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if
           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if
           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if
           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if
           end if
           if lr_param.clscod = "33R" then
           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if
           end if
           if lr_param.clscod = "034" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
           if lr_param.clscod = "035" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
        when 4 # Mulher
          if lr_param.clscod = "033" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 28  or   # Ar Condicionado ###
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 2
                end if
           end if
           if lr_param.clscod = "33R" then
           	   if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 1
                end if
           end if
           if lr_param.clscod = "034" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if
           end if
           if lr_param.clscod = "035" then
               if lr_param.socntzcod = 1   or   # Hidraulica
           	   	  lr_param.socntzcod = 2   or   # Desentupimento
           	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 10  or   # Eletrica
           	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
           	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
           	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
                  lr_param.socntzcod = 11  or   # Telefonia
           	   	  lr_param.socntzcod = 12  or   # Geladeira
           	   	  lr_param.socntzcod = 13  or   # Fogao
           	   	  lr_param.socntzcod = 14  or   # Lavadoura
           	   	  lr_param.socntzcod = 15  or   # Lava Louca
           	   	  lr_param.socntzcod = 16  or   # Freezer
           	   	  lr_param.socntzcod = 17  or   # Secadora
           	   	  lr_param.socntzcod = 19  or   # Microondas
                  lr_param.socntzcod = 243 then # Tanquinho
                     let lr_retorno.limite  = 0
                end if

           end if


     end case

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_limite_S85(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     case lr_param.perfil

     	when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 1
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then    # Inclusao da clausula solicitada por Moises Veloso
               let lr_retorno.limite     = 1  # em 04/05/2015
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite     = 0
           end if

     end case

     return  lr_retorno.limite


end function



#----------------------------------------------#
 function cty31g00_recupera_limite_SLV(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod = "033" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "33R" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "034" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "035" then
         let lr_retorno.limite     = 1
     end if

     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_limite_SLT(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod ,
  perfil      smallint
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod = "033" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "33R" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "034" then
         let lr_retorno.limite     = 1
     end if

     if lr_param.clscod = "035" then
         let lr_retorno.limite     = 1
     end if

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S10(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer,
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km  = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 400
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 9999
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 400
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 9999
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 400
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 9999
           end if

     end case

     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_M20(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer  ,
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km  = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km     = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km     = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 9999
           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               case lr_param.asitipcod
               	  when 4
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 8
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 9
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 40
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 300,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 100,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  when 50
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 450,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 150,00", "POR EVENTO.")
                      returning lr_retorno.confirma
                  otherwise
                      call cts08g01("A","N","SEM LIMITE DE UTILIZACAO", "R$ 3.000,00 POR VIGENCIA, SENDO ","LIMITADA A R$ 1.000,00", "POR EVENTO.")
                      returning lr_retorno.confirma
               end case

           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

     end case


     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S54(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km  = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50
           end if

        #Alterado perfil Jovem para 50 km, conforme chamado 363392
        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km     = 50
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km     = 50
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km     = 50
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km     = 50
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 50
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50
           end if

     end case


     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S40(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  confirma    char(01)
end record

initialize lr_retorno.* to null
     let lr_retorno.limite_km  = 0

     case lr_param.perfil
     when 1 # Tradicional
        if lr_param.clscod = "033" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "33R" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "034" then
            let lr_retorno.limite_km  = 0
        end if
        if lr_param.clscod = "035" then
            let lr_retorno.limite_km  = 0
        end if
      when 2 # Jovem
        if lr_param.clscod = "033" then
            let lr_retorno.limite_km  = 0
        end if

        if lr_param.clscod = "33R" then
            let lr_retorno.limite_km  = 0
        end if

        if lr_param.clscod = "034" then
            let lr_retorno.limite_km  = 0
        end if
        if lr_param.clscod = "035" then
            let lr_retorno.limite_km  = 0
        end if
      when 3 # Senior
        if lr_param.clscod = "033" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "33R" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "034" then
            let lr_retorno.limite_km  = 0
        end if
        if lr_param.clscod = "035" then
            let lr_retorno.limite_km  = 0
        end if
      when 4 # Mulher
        if lr_param.clscod = "033" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "33R" then
            let lr_retorno.limite_km  = 100
            call cts08g01("A","N","",  "ESTA ASSISTENCIA DEVE SER REALIZADA", "LIMITADO A R$ 125,00","R$ 1,25 POR KM")
            returning lr_retorno.confirma
        end if
        if lr_param.clscod = "034" then
            let lr_retorno.limite_km  = 0
        end if
        if lr_param.clscod = "035" then
            let lr_retorno.limite_km  = 0
        end if
     end case
     return  lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S80(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km     = 0

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 0
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50

                call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
                returning lr_retorno.confirma

           end if

     end case

     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S23(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  flag_atende char(01),
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0
     let lr_retorno.flag_atende = "S"

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL ", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA.")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then



               	   case lr_param.asimvtcod
               	   		when 01

               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#

               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

               	   		when 02

               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#

               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma

               	   		when 03

               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#

               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma
               	   		when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	   		when 11

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"


               	   		when 12

               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#

               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL ", "CLASSE ECONOMICA, IDA E VOLTA.")
               	         returning lr_retorno.confirma

               	      when 13

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"
               	      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	      otherwise

               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#

               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma

               	   end case
               end if


               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if

               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if

           end if

        when 2  # Jovem
           let lr_retorno.limite_km  = 0

           call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA O PERFIL AUTO JOVEM.","")
           returning lr_retorno.confirma

           let lr_retorno.flag_atende = "N"

        when 3  # Senior
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA.")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL ", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA.")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then



               	   case lr_param.asimvtcod
               	   		when 01

               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#

               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

               	   		when 02

               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#

               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma

               	   		when 03

               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#

               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma
               	   		when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	   		when 11

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"


               	   		when 12

               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#

               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
               	         returning lr_retorno.confirma

               	      when 13

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"
               	      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	      otherwise

               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#

               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma

               	   end case
               end if


               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if

               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if

           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA.")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA.")
                         returning lr_retorno.confirma
                      when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then



               	   case lr_param.asimvtcod
               	   		when 01

               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#

               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

               	   		when 02

               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#

               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma

               	   		when 03

               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#

               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma
               	   		when 10
                      	 #--------------------------------------#
                      	 # Taxi Amigo                           #
                      	 #--------------------------------------#
                      	 let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	   		when 11

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"


               	   		when 12

               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#

               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
               	         returning lr_retorno.confirma

               	      when 13

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"
               	      when 14
               	         #--------------------------------------#
               	         # Consulta ou Exame Medica             #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 50
                         call cts08g01("A","N","",  "LIMITADO A UM ATENDIMENTO", " ATE 50 KM","")
                         returning lr_retorno.confirma
               	      otherwise

               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#

               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma

               	   end case
               end if


               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if

               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if

           end if

     end case


     return lr_retorno.limite_km  ,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_recupera_km_M23(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  flag_atende char(01),
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0
     let lr_retorno.flag_atende = "S"

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

        when 2  # Jovem
           let lr_retorno.limite_km  = 0

           call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA O PERFIL AUTO JOVEM.","")
           returning lr_retorno.confirma

           let lr_retorno.flag_atende = "N"

        when 3  # Senior
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

     end case


     return lr_retorno.limite_km  ,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S81(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0

     case lr_param.perfil

       when 1  # Tradicional
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 2  # Jovem
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 0
           end if

        when 3  # Senior
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then
               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

           if lr_param.clscod = "33R" then
               let lr_retorno.limite_km  = 50
               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma
           end if

           if lr_param.clscod = "034" then
               let lr_retorno.limite_km  = 0
           end if

           if lr_param.clscod = "035" then
               let lr_retorno.limite_km  = 50

                call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
                returning lr_retorno.confirma

           end if

     end case

     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S29(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  flag_atende char(01),
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0
     let lr_retorno.flag_atende = "S"

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

           if lr_param.clscod = "034" then


               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"


           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

        when 2  # Jovem
        	 let lr_retorno.limite_km  = 0

           call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA O PERFIL AUTO JOVEM.","")
           returning lr_retorno.confirma

           let lr_retorno.flag_atende = "N"

        when 3  # Senior
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

           if lr_param.clscod = "034" then


               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"


           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

           if lr_param.clscod = "034" then


               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"


           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 50

               call cts08g01("A","N","",  "ESTE TRANSPORTE DEVE SER REALIZADO", "LIMITADO A 50 KM","")
               returning lr_retorno.confirma

           end if

     end case


     return lr_retorno.limite_km,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_recupera_km_S33(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  flag_atende char(01),
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0
     let lr_retorno.flag_atende = "S"

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then



               	   case lr_param.asimvtcod
               	   		when 01

               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#

               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

               	   		when 02

               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#

               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma

               	   		when 03

               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#

               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma

               	   		when 11

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"


               	   		when 12

               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#

               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", " IDA E VOLTA.")
               	         returning lr_retorno.confirma

               	      when 13

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"

               	      otherwise

               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#

               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma

               	   end case
               end if


               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if

               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if

           end if

        when 2  # Jovem
           let lr_retorno.limite_km  = 0

           call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA O PERFIL AUTO JOVEM.","")
           returning lr_retorno.confirma

           let lr_retorno.flag_atende = "N"

        when 3  # Senior
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if
               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#
               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then
               	   case lr_param.asimvtcod
               	   		when 01
               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#
               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma
               	   		when 02
               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#
               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma
               	   		when 03
               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#
               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma
               	   		when 11
               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 0
                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma
                         let lr_retorno.flag_atende = "N"
               	   		when 12
               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#
               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", " IDA E VOLTA.")
               	         returning lr_retorno.confirma
               	      when 13
               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#
               	         let lr_retorno.limite_km  = 0
                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma
                         let lr_retorno.flag_atende = "N"
               	      otherwise
               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#
               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma
               	   end case
               end if
               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#
               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then
                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma
               end if
               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#
               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then
                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma
               end if

           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then
               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 2.500,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then



               	   case lr_param.asimvtcod
               	   		when 01

               	   		   #-------------------------------------#
               	   		   # Retorno a Domicilio                 #
                         #-------------------------------------#

               	   		   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

               	   		when 02

               	   			 #-------------------------------------#
               	   			 # Continuacao de Viagem               #
               	   			 #-------------------------------------#

               	   			 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 1.500,00 POR ","EVENTO.")
               	   			 returning lr_retorno.confirma

               	   		when 03

               	   			 #-------------------------------------#
               	   			 # Recuperacao de Veiculo              #
                         #-------------------------------------#

               	   			 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", "SO IDA.")
                         returning lr_retorno.confirma

               	   		when 11

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"


               	   		when 12

               	         #-------------------------------------#
               	         # Envio de Familiar                   #
                         #-------------------------------------#

               	         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL CLASSE ECONOMICA,", " IDA E VOLTA.")
               	         returning lr_retorno.confirma

               	      when 13

               	         #--------------------------------------#
               	         # Transporte em Caso de Roubo ou Furto #
                         #--------------------------------------#

               	         let lr_retorno.limite_km  = 0

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
                         returning lr_retorno.confirma

                         let lr_retorno.flag_atende = "N"

               	      otherwise

               	         #-------------------------------------#
               	         # Motorista Profissional              #
               	         #-------------------------------------#

               	         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.000,00 POR ","EVENTO.")
               	         returning lr_retorno.confirma

               	   end case
               end if


               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 1.500,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if

               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 200,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if

           end if

     end case


     return lr_retorno.limite_km  ,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_recupera_km_M33(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod     ,
  perfil      smallint                  ,
  asitipcod   like datkasitip.asitipcod ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer ,
  flag_atende char(01),
  confirma    char(01)
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km   = 0
     let lr_retorno.flag_atende = "S"

     case lr_param.perfil

     		when 1  # Tradicional
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

        when 2  # Jovem
           let lr_retorno.limite_km  = 0

           call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA O PERFIL AUTO JOVEM.","")
           returning lr_retorno.confirma

           let lr_retorno.flag_atende = "N"

        when 3  # Senior
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

        when 4 # Mulher
           if lr_param.clscod = "033" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if


           end if

           if lr_param.clscod = "33R" then

               let lr_retorno.limite_km  = 9999

               #-------------------------------------#
               # Remocao Hospitalar                  #
               #-------------------------------------#

               if lr_param.asitipcod = 11 then

               	   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO A R$ 5.000,00 POR ","EVENTO.")
               	   returning lr_retorno.confirma
               end if

               #-------------------------------------#
               # Transporte Taxi, Aviao, Onibus      #
               #-------------------------------------#

               if  lr_param.asitipcod = 10 or
                   lr_param.asitipcod = 5  or
                   lr_param.asitipcod = 16 then

                   case lr_param.asimvtcod
                      when 01

                         #-------------------------------------#
                         # Retorno a Domicilio                 #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 02

                      	 #-------------------------------------#
                      	 # Continuacao Viagem                  #
                      	 #-------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO a R$ 2.000,00 POR ","EVENTO.")
                      	 returning lr_retorno.confirma

                      when 03

                      	 #-------------------------------------#
                      	 # Recuperacao de Veiculo              #
                         #-------------------------------------#

                      	 call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, "," LIMITADO AO VALOR DE UMA PASSAGEM","AEREA NACIONAL", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 11

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                      when 12

                         #-------------------------------------#
                         # Envio de Familiar                   #
                         #-------------------------------------#
                         call cts08g01("A","N","SEM LIMITE DE UTILIZACOES, LIMITADO "," AO VALOR DE UMA PASSAGEM AEREA ","NACIONAL/INTERNACIONAL (MERCOSUL)", "CLASSE ECONOMICA, IDA E VOLTA.")
                         returning lr_retorno.confirma

                      when 13

                      	 #--------------------------------------#
                      	 # Transporte em Caso de Roubo ou Furto #
                      	 #--------------------------------------#

                      	 call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 200,00 POR ","EVENTO.")
                         returning lr_retorno.confirma


                      otherwise

                         #-------------------------------------#
                         # Motorista Profissional              #
                         #-------------------------------------#

                         call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 2.000,00 POR ","EVENTO.")
                         returning lr_retorno.confirma

                   end case



               end if



               #-------------------------------------#
               # Translado de Corpos                 #
               # Obito e Outros                      #
               #-------------------------------------#

               if  lr_param.asitipcod = 12 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 7) then

                   call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " LIMITADO AO VALOR DE R$ 3.000,00 POR ","EVENTO.")
                   returning lr_retorno.confirma

               end if


               #-------------------------------------#
               # Hospedagem                          #
               # Aguarda Conserto e Outros           #
               #-------------------------------------#

               if  lr_param.asitipcod = 13 and
                   (lr_param.asimvtcod = 4  or
                    lr_param.asimvtcod = 5) then

                   call cts08g01("A","N","",  "LIMITE TOTAL DAS DESPESAS DE", " ATE R$ 400,00 POR DIA, MAXIMO 7 DIAS.","")
                   returning lr_retorno.confirma

               end if



           end if

           if lr_param.clscod = "034" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 34.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

           if lr_param.clscod = "035" then

               let lr_retorno.limite_km  = 0

               call cts08g01("A","N","",  "SEM LIMITE DE UTILIZACAO", " PARA A CLAUSULA 35.","")
               returning lr_retorno.confirma

               let lr_retorno.flag_atende = "N"

           end if

     end case


     return lr_retorno.limite_km  ,
            lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty31g00_recupera_km_SLV(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km     = 0


     if lr_param.clscod = "033" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "33R" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "034" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "035" then
         let lr_retorno.limite_km  = 50
     end if


     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_recupera_km_SLT(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  perfil      smallint                   ,
  asitipcod   like datkasitip.asitipcod  ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km   integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite_km     = 0


     if lr_param.clscod = "033" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "33R" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "034" then
         let lr_retorno.limite_km  = 50
     end if

     if lr_param.clscod = "035" then
         let lr_retorno.limite_km  = 50
     end if


     return lr_retorno.limite_km


end function

#----------------------------------------------#
 function cty31g00_valida_diaria(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

      if cty36g00_acesso() then
   	    call cty36g00_valida_diaria(lr_param.c24astcod  ,
                                    lr_param.clscod     ,
                                    lr_param.perfil     ,
                                    lr_param.avialgmtv  )
        returning lr_retorno.limite
   	    return lr_retorno.limite
      end if

     case lr_param.c24astcod
        when "H10"
        	  call  cty31g00_recupera_diaria_H10(lr_param.clscod, lr_param.perfil, lr_param.avialgmtv)
        	  returning lr_retorno.limite
        when "H11"
        	  call  cty31g00_recupera_diaria_H11(lr_param.clscod, lr_param.perfil, lr_param.avialgmtv)
        	  returning lr_retorno.limite
        when "H12"
        	  call  cty31g00_recupera_diaria_H12(lr_param.clscod, lr_param.perfil, lr_param.avialgmtv)
        	  returning lr_retorno.limite
        when "H13"
          	call  cty31g00_recupera_diaria_H13(lr_param.clscod, lr_param.perfil, lr_param.avialgmtv)
        	  returning lr_retorno.limite
     end case

     if lr_param.clscod[1,2] = '26' and
        lr_param.avialgmtv = 1 then
         call cty31g00_recupera_limite_clausula_26(lr_param.clscod)
         returning lr_retorno.limite
     end if

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty31g00_recupera_diaria_H10(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 00

     if lr_param.clscod[1,2] = "26" then
        let lr_param.clscod = g_nova.clscod
     end if


     if lr_param.clscod = "033" then

     	   case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 2

     	          #----------------------------------------------#
     	          # Porto Socorro Pane Mecanica                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 07
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 8

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Part PP     #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 07
     	       when 9

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 20

     	          #----------------------------------------------#
     	          # Tapete Azul                                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 02
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 23

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Integral    #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 15
     	       when 24

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00

     	   end case

     end if

     if lr_param.clscod = "33R" then

         case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 2

     	          #----------------------------------------------#
     	          # Porto Socorro Pane Mecanica                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 07
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 8

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Part PP     #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 07
     	       when 9

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 20

     	          #----------------------------------------------#
     	          # Tapete Azul                                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 02
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 15
     	       when 23

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Integral    #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 15
     	       when 24

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00

     	   end case


     end if

     if lr_param.clscod = "034" then

         case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 2

     	          #----------------------------------------------#
     	          # Porto Socorro Pane Mecanica                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 07
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 8

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Part PP     #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 9

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 20

     	          #----------------------------------------------#
     	          # Tapete Azul                                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 02
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 23

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Integral    #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 24

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00

     	   end case

     end if

     if lr_param.clscod = "035" then

         case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 2

     	          #----------------------------------------------#
     	          # Porto Socorro Pane Mecanica                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	        when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 8

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Part PP     #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 9

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 20

     	          #----------------------------------------------#
     	          # Tapete Azul                                  #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 02
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 15
     	       when 23

     	         #----------------------------------------------#
     	         # Seg. como Terceiro em Cong/Porto/Integral    #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 15
     	       when 24

     	         #----------------------------------------------#
     	         # Indenizacao Integral                         #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 15

     	   end case

     end if

     if lr_param.clscod[1,2] = "26" then

     	   case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30

     	   end case

     end if


     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_diaria_H11(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod[1,2] = "26" then
        let lr_param.clscod = g_nova.clscod
     end if

     if lr_param.clscod = "033" then

     	   case lr_param.avialgmtv
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 07

     	   end case

     end if

     if lr_param.clscod = "33R" then

         case lr_param.avialgmtv
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 07


     	   end case


     end if

     if lr_param.clscod = "034" then

         case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case

     end if

     if lr_param.clscod = "035" then

         case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	       when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case

     end if


     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_diaria_H12(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod[1,2] = "26" then
        let lr_param.clscod = g_nova.clscod
     end if

     if lr_param.clscod = "033" then

     	   case lr_param.avialgmtv
     	        when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999


     	   end case

     end if

     if lr_param.clscod = "33R" then

         case lr_param.avialgmtv
     	        when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999

     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 15

     	   end case


     end if

     if lr_param.clscod = "034" then

         case lr_param.avialgmtv
     	        when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 07
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00


     	   end case

     end if

     if lr_param.clscod = "035" then

         case lr_param.avialgmtv
     	        when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30
     	       when 3

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro                        #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999

     	      when 13

     	          #----------------------------------------------#
     	          # Indenizacao Integral                         #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 14

     	          #----------------------------------------------#
     	          # Tempo Indeterminado Perda Parcial            #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 00
     	       when 21

     	          #----------------------------------------------#
     	          # Beneficio de Sinistro PP                     #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 15

     	   end case

     end if

     if lr_param.clscod[1,2] = "26" then

     	   case lr_param.avialgmtv
     	       when 1

     	          #----------------------------------------------#
     	          # Sinistro se Tiver a Clausula 26              #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 30

     	   end case

     end if

     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_recupera_diaria_H13(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod        ,
  perfil      smallint                     ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod[1,2] = "26" then
        let lr_param.clscod = g_nova.clscod
     end if

     if lr_param.clscod = "033" then

     	   case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case

     end if

     if lr_param.clscod = "33R" then

         case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case


     end if

     if lr_param.clscod = "034" then

         case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case

     end if

     if lr_param.clscod = "035" then

         case lr_param.avialgmtv

     	       when 4

     	          #----------------------------------------------#
     	          # Departamento                                 #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	       when 5

     	          #----------------------------------------------#
     	          # Particular                                   #
     	          #----------------------------------------------#
     	          let lr_retorno.limite     = 999
     	      when 6

     	         #----------------------------------------------#
     	         # Beneficio Terceiro Segurado Porto            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 07
     	      when 7

     	         #----------------------------------------------#
     	         # Terceiro Qualquer                            #
     	         #----------------------------------------------#
     	         let lr_retorno.limite     = 00


     	   end case

     end if


     return  lr_retorno.limite

end function

#---------------------------------------------------#
 function cty31g00_valida_motivo_clausula(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv  ,
  c24astcod    like datkassunto.c24astcod
end record

define lr_retorno record
  atende  char(01) ,
  motivos char(500)
end record

initialize lr_retorno.* to null

    if cty36g00_acesso() then
    	 call cty36g00_valida_motivo_clausula(lr_param.clscod1
    	 	                                   ,lr_param.clscod2
    	 	                                   ,lr_param.flag
    	 	                                   ,lr_param.avialgmtv
    	 	                                   ,lr_param.c24astcod)
    	 returning lr_retorno.atende, lr_retorno.motivos
    	 return  lr_retorno.atende ,
               lr_retorno.motivos
    end if


     case lr_param.c24astcod
     	 when "H10"
           call cty31g00_recupera_motivo_H10(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H11"
           call cty31g00_recupera_motivo_H11(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H12"
           call cty31g00_recupera_motivo_H12(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos

       when "H13"
           call cty31g00_recupera_motivo_H13(lr_param.clscod1   ,
                                             lr_param.clscod2   ,
                                             lr_param.flag      ,
                                             lr_param.avialgmtv )
           returning lr_retorno.atende, lr_retorno.motivos


     end case

     return  lr_retorno.atende ,
             lr_retorno.motivos

end function
#---------------------------------------------------#
 function cty31g00_recupera_motivo_H10(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record
initialize lr_retorno.* to null

  #if (g_documento.semdocto = " " or g_documento.semdocto is null) and  g_documento.ramcod <> 114     then
  if (g_documento.semdocto = " " or g_documento.semdocto is null) then

     let lr_retorno.atende = "N"

     if lr_param.flag = "N" then

         if lr_param.clscod1 = "034" then

            if lr_param.avialgmtv = 03 or
               lr_param.avialgmtv = 04 or
               lr_param.avialgmtv = 05 then
               let lr_retorno.atende = "S"
            end if

            if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                 let lr_retorno.atende = "S"
            end if

            let lr_retorno.motivos = "3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

            if g_flag_azul = "S" then
                let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
            end if

         end if


         if lr_param.clscod1 = "035" then

           if lr_param.avialgmtv = 04 or
           	  lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 21 or
              lr_param.avialgmtv = 23 or
              lr_param.avialgmtv = 24 then
              	  let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias|24 - Indenizacao Integral - 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if

         if lr_param.clscod1 = "033" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              	  let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if

         if lr_param.clscod1 = "33R" then

           if lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 21 or
              lr_param.avialgmtv = 23 then
              	  let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if
     else

     	   if lr_param.clscod2 = "034" then

            if lr_param.avialgmtv = 01 or
            	 lr_param.avialgmtv = 03 or
            	 lr_param.avialgmtv = 04 or
               lr_param.avialgmtv = 05 then
               	  let lr_retorno.atende = "S"
            end if

            if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                 let lr_retorno.atende = "S"
            end if

            let lr_retorno.motivos = "1 - Sinistro|3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

            if g_flag_azul = "S" then
                let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
            end if

         end if


         if lr_param.clscod2 = "035" then

           if lr_param.avialgmtv = 01 or
           	  lr_param.avialgmtv = 04 or
           	  lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 21 or
              lr_param.avialgmtv = 23 or
              lr_param.avialgmtv = 24 then
              	  let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias|24 - Indenizacao Integral - 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if

         if lr_param.clscod2 = "033" then

           if lr_param.avialgmtv = 01 or
              lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 14 or
              lr_param.avialgmtv = 23 then
              	  let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if


         if lr_param.clscod2 = "33R" then

           if lr_param.avialgmtv = 01 or
              lr_param.avialgmtv = 02 or
              lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 or
              lr_param.avialgmtv = 08 or
              lr_param.avialgmtv = 13 or
              lr_param.avialgmtv = 21 or
              lr_param.avialgmtv = 23 then
                let lr_retorno.atende = "S"
           end if

           if g_flag_azul = "S" and lr_param.avialgmtv = 20 then
                let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|2 - Porto Socorro|4 - Departamentos|5 - Particular|8 - Segurado como Terceiro|13- 30 dias I.Integral Claus 33|21 - Beneficio Sinistro PP  15 dias|23 - Seg como Terceiro em Cong/Porto/ I.Integral. 15 dias"

           if g_flag_azul = "S" then
               let lr_retorno.motivos = lr_retorno.motivos clipped, "|20 - Tapete Azul"
           end if

         end if


     end if
  else
     let lr_retorno.atende = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if
     return  lr_retorno.atende  ,
             lr_retorno.motivos

end function

#---------------------------------------------------#
 function cty31g00_recupera_motivo_H12(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if (g_documento.semdocto = " " or g_documento.semdocto is null) then

     let lr_retorno.atende = "N"

     if lr_param.flag = "N" then

        if lr_param.clscod1 = "034" then

           if lr_param.avialgmtv = 03 or
           	  lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              	  let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

        end if


        if lr_param.clscod1 = "035" then

          if lr_param.avialgmtv = 04 or
          	 lr_param.avialgmtv = 05 or
          	 lr_param.avialgmtv = 21 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias"

        end if

        if lr_param.clscod1 = "033" then

          if lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 14 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

        end if


        if lr_param.clscod1 = "33R" then

          if lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 21 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|21 - Beneficio Sinistro PP  15 dias"

        end if
     else

     	   if lr_param.clscod1 = "034" then

           if lr_param.avialgmtv = 01 or
           	  lr_param.avialgmtv = 03 or
           	  lr_param.avialgmtv = 04 or
              lr_param.avialgmtv = 05 then
              	  let lr_retorno.atende = "S"
           end if

           let lr_retorno.motivos = "1 - Sinistro|3 - Beneficio Oficinas|4 - Departamentos|5 - Particular"

        end if


        if lr_param.clscod1 = "035" then

          if lr_param.avialgmtv = 01 or
          	 lr_param.avialgmtv = 04 or
          	 lr_param.avialgmtv = 05 or
          	 lr_param.avialgmtv = 21 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular|21 - Beneficio Sinistro PP  15 dias"

        end if

        if lr_param.clscod1 = "033" then

          if lr_param.avialgmtv = 01 or
          	 lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 14 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|14- T.Indeterminado PP"

        end if


        if lr_param.clscod1 = "33R" then


          if lr_param.avialgmtv = 01 or
          	 lr_param.avialgmtv = 04 or
             lr_param.avialgmtv = 05 or
             lr_param.avialgmtv = 13 or
             lr_param.avialgmtv = 21 then
             	  let lr_retorno.atende = "S"
          end if

          let lr_retorno.motivos = "1 - Sinistro|4 - Departamentos|5 - Particular|13- 30 dias I.Integral Claus 33|21 - Beneficio Sinistro PP  15 dias"

        end if

     end if

  else
     let lr_retorno.atende = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if

  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function

#---------------------------------------------------#
 function cty31g00_recupera_motivo_H11(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if (g_documento.semdocto = " " or g_documento.semdocto is null) then

     let lr_retorno.atende = "N"

     if lr_param.clscod1 = "034" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           	  let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if


     if lr_param.clscod1 = "035" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 06 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|6 - Terceiro Segurado Porto"

     end if

     if lr_param.clscod1 = "033" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if


     if lr_param.clscod1 = "33R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if

  else
     let lr_retorno.atende = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if

  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function

#---------------------------------------------------#
 function cty31g00_recupera_motivo_H13(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv
end record

define lr_retorno record
  atende  char(01),
  motivos char(500)
end record

initialize lr_retorno.* to null

  if (g_documento.semdocto = " " or g_documento.semdocto is null) then

     let lr_retorno.atende = "N"

     if lr_param.clscod1 = "034" then

        if lr_param.avialgmtv = 04 or
           lr_param.avialgmtv = 05 then
           	  let lr_retorno.atende = "S"
        end if

        let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if


     if lr_param.clscod1 = "035" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 06 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|6 - Terceiro Segurado Porto"

     end if

     if lr_param.clscod1 = "033" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 or
          lr_param.avialgmtv = 07 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular|7 - Terceiro Qualquer"

     end if


     if lr_param.clscod1 = "33R" then

       if lr_param.avialgmtv = 04 or
          lr_param.avialgmtv = 05 then
          	  let lr_retorno.atende = "S"
       end if

       let lr_retorno.motivos = "4 - Departamentos|5 - Particular"

     end if

  else
     let lr_retorno.atende = "S"
     let lr_retorno.motivos = "4 - Departamentos|5 - Particular"
  end if

  return  lr_retorno.atende  ,
          lr_retorno.motivos

end function


#---------------------------------------------------#
function cty31g00_popup_motivos(lr_param)
#---------------------------------------------------#

define lr_param record
	clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv  ,
  c24astcod    like datkassunto.c24astcod
end record


define lr_retorno record
       motivos char(500)
      ,atende  char(01)
      ,opcao   like datmavisrent.avialgmtv
      ,cabec   char(60)
      ,qtd     integer
end record

initialize lr_retorno.* to null

   let lr_retorno.cabec = "Motivos"
   let lr_retorno.qtd   = 0

   call cty31g00_valida_motivo_clausula(lr_param.clscod1   ,
                                        lr_param.clscod2   ,
                                        lr_param.flag      ,
                                        lr_param.avialgmtv ,
                                        lr_param.c24astcod )
   returning lr_retorno.atende ,
             lr_retorno.motivos

   call ctx14g01_carro_extra(lr_retorno.cabec, lr_retorno.motivos)
   returning lr_retorno.opcao

   return lr_retorno.opcao

end function

#--------------------------------------------------------#
function cty31g00_valida_envio_guincho(lr_param)
#--------------------------------------------------------#

define lr_param record
    ramcod      smallint
   ,succod      like abbmitem.succod
   ,aplnumdig   like abbmitem.aplnumdig
   ,itmnumdig   like abbmitem.itmnumdig
   ,c24astcod   like datkassunto.c24astcod
   ,socntzcod   like datksocntz.socntzcod
end record

define lr_retorno           record
    erro                    smallint
   ,data_calculo            date
   ,clscod                  char(05)
   ,flag_endosso            char(01)
   ,flag_limite             char(1)
   ,resultado               integer
   ,mensagem                char(80)
   ,qtd_ap                  integer
   ,qtd_ag                  integer
   ,qtd_at                  integer
   ,prporgpcp               like abamdoc.prporgpcp
   ,prpnumpcp               like abamdoc.prpnumpcp
   ,limite                  integer
   ,limite_km               integer
end record

initialize lr_retorno.* to null

   let lr_retorno.qtd_ap  = 0
   let lr_retorno.qtd_ag  = 0
   let lr_retorno.qtd_at  = 0

   #-----------------------------------------------------------
   # Obter a Data de Calculo
   #-----------------------------------------------------------


   call cty26g01_clausula(lr_param.succod   ,
                          lr_param.aplnumdig,
                          lr_param.itmnumdig)
   returning lr_retorno.erro         ,
             lr_retorno.clscod       ,
             lr_retorno.data_calculo ,
             lr_retorno.flag_endosso

   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos de Envio de Socorro
   #-----------------------------------------------------------

   if lr_param.c24astcod = "S41" or
   	  lr_param.c24astcod = "S42" then

   	  call cty31g00_quantidade_servico(lr_param.ramcod         ,
                                       lr_param.succod         ,
                                       lr_param.aplnumdig      ,
                                       lr_param.itmnumdig      ,
                                       ""                      ,
                                       ""                      ,
                                       lr_retorno.data_calculo ,
                                       lr_param.c24astcod      ,
                                       ''                      ,
                                       lr_param.socntzcod      )
      returning lr_retorno.qtd_ap

   else

      call cta02m15_qtd_servico(lr_param.ramcod         ,
                                lr_param.succod         ,
                                lr_param.aplnumdig      ,
                                lr_param.itmnumdig      ,
                                ""                      ,
                                ""                      ,
                                lr_retorno.data_calculo ,
                                lr_param.c24astcod      ,
                                '' )
      returning lr_retorno.qtd_ap

   end if

   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos Agregados
   #-----------------------------------------------------------

   let lr_retorno.qtd_ag = cty31g00_calcula_agregacao(lr_param.ramcod         ,
                                                      lr_param.succod         ,
                                                      lr_param.aplnumdig      ,
                                                      lr_param.itmnumdig      ,
                                                      lr_param.c24astcod      ,
                                                      lr_retorno.data_calculo )


   let lr_retorno.qtd_at = lr_retorno.qtd_ap + lr_retorno.qtd_ag

   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null

   call cty31g00_valida_limite(lr_param.c24astcod,
                               g_nova.clscod     ,
                               g_nova.perfil     ,
                               lr_param.socntzcod)
   returning lr_retorno.limite


   if lr_retorno.qtd_at >= lr_retorno.limite then
        let lr_retorno.flag_limite = "S"
   else
   	    let lr_retorno.flag_limite = "N"
   end if


   return  lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite
          ,lr_retorno.qtd_at
          ,lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_agrega_alta_IS()
#----------------------------------------------#

define lr_retorno record
	 limite integer
end record

initialize lr_retorno.* to null

    let lr_retorno.limite = 0

    if g_nova.imsvlr >= 110000.00 then
       let lr_retorno.limite = 1
    end if

    return lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_agrega_veiculo_0KM()
#----------------------------------------------#

define lr_retorno record
	 limite integer
end record

initialize lr_retorno.* to null

    let lr_retorno.limite = 0

    if g_nova.vcl0kmflg = "S" then
       let lr_retorno.limite = 1
    end if

    return lr_retorno.limite

end function

#--------------------------------------------------------#
function cty31g00_calcula_agregacao(lr_param)
#--------------------------------------------------------#

define lr_param record
    ramcod       smallint
   ,succod       like abbmitem.succod
   ,aplnumdig    like abbmitem.aplnumdig
   ,itmnumdig    like abbmitem.itmnumdig
   ,c24astcod    like datkassunto.c24astcod
   ,data_calculo date
end record

define lr_retorno  record
   qtd_ap integer
end record

   initialize lr_retorno.* to null

   let lr_retorno.qtd_ap = 0

   if lr_param.c24astcod = "S80" or
   	  lr_param.c24astcod = "S81" or
   	  lr_param.c24astcod = "S41" or
   	  lr_param.c24astcod = "S42" then

      case lr_param.c24astcod
         when "S80"
              let lr_param.c24astcod = "S81"
         when "S81"
              let lr_param.c24astcod = "S80"
          when "S41"
               let lr_param.c24astcod = "S42"
          when "S42"
               let lr_param.c24astcod = "S41"
      end case

      #-----------------------------------------------------------
      # Obter a Quantidade de Atendimentos de Envio de Socorro
      #-----------------------------------------------------------


      call cta02m15_qtd_servico(lr_param.ramcod         ,
                                lr_param.succod         ,
                                lr_param.aplnumdig      ,
                                lr_param.itmnumdig      ,
                                ""                      ,
                                ""                      ,
                                lr_param.data_calculo ,
                                lr_param.c24astcod      ,
                                '' )
      returning lr_retorno.qtd_ap

   end if

   return lr_retorno.qtd_ap


end function

#----------------------------------------------#
 function cty31g00_valida_natureza(lr_param)
#----------------------------------------------#

define lr_param record
	  c24astcod  like datkassunto.c24astcod,
    socntzcod  like datksocntz.socntzcod
end record

   if cty36g00_acesso() then
   	 if cty36g00_valida_natureza(lr_param.c24astcod,lr_param.socntzcod) then
   	      return true
      else
           return false
      end if
   end if
   case lr_param.c24astcod
      when "S60"
          if cty31g00_valida_natureza_S60(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S63"
          if cty31g00_valida_natureza_S63(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S41"
          if cty31g00_valida_natureza_S41(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S42"
          if cty31g00_valida_natureza_S42(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S78"
          if cty31g00_valida_natureza_S78(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S66"
          if cty31g00_valida_natureza_S66(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S67"
          if cty31g00_valida_natureza_S67(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      otherwise
          return true

   end case

end function

#----------------------------------------------#
 function cty31g00_valida_natureza_S60(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case g_nova.perfil

    		when 1  # Tradicional

          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 5   # Chaveiro
             	  return true
             when 10  # Eletrica
                return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 141 # Chave Tetra
             	  return true
             when 287 # Troca de Lampada
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             otherwise
                return false
          end case

       when 2  # Jovem
          return false

       when 3  # Senior

          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 5   # Chaveiro
             	  return true
             when 10  # Eletrica
                return true
             when 41  # Kit 1
                return true
             when 42  # Kit 2
             	  return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 141 # Chave Tetra
             	  return true
             when 206 # Conectividade
                return true
             when 207 # Mudanca de Mobiliario
             	  return true
             when 287 # Troca de Lampada
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             when 317 # Barra de Apoio
             	  if cty31g00_nova_regra_corte2() then
             	      return true
             		else
             			  return false
             		end if
             otherwise
                return false
          end case

       when 4 # Mulher
          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 5   # Chaveiro
             	  return true
             when 10  # Eletrica
                return true
             when 41  # Kit 1
                return true
             when 42  # Kit 2
             	  return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 141 # Chave Tetra
             	  return true
             when 287 # Troca de Lampada
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             otherwise
                return false
          end case

    end case

end function

#----------------------------------------------#
 function cty31g00_valida_natureza_S63(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case g_nova.perfil

    		when 1  # Tradicional

          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 28  # Ar Condicionado
             	  return true
             when 47  # Reversao de Fogao
             	  return true
             when 104 # Ar Condicionado
                return true
             when 243 # Tanquinho
             	  return true
             when 300 # Geladeira Side by Side
             	  return true
             when 301 # Ar Condicionado Split
                return true
             when 302 # Lava Roupas (Lava e Seca)
             	  return true
              otherwise
                return false
          end case

       when 2  # Jovem
          return false

       when 3  # Senior

          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 28  # Ar Condicionado
             	  return true
             when 47  # Reversao de Fogao
             	  return true
             when 104 # Ar Condicionado
                return true
             when 243 # Tanquinho
             	  return true
             when 300 # Geladeira Side by Side
             	  return true
             when 301 # Ar Condicionado Split
                return true
             when 302 # Lava Roupas (Lava e Seca)
             	  return true
             otherwise
                return false
          end case

       when 4 # Mulher
          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 28  # Ar Condicionado
             	  return true
             when 47  # Reversao de Fogao
             	  return true
             when 104 # Ar Condicionado
                return true
             when 243 # Tanquinho
             	  return true
             when 300 # Geladeira Side by Side
             	  return true
             when 301 # Ar Condicionado Split
                return true
             when 302 # Lava Roupas (Lava e Seca)
             	  return true
             otherwise
                return false
          end case

    end case

end function

#----------------------------------------------#
 function cty31g00_valida_natureza_S41(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case g_nova.perfil

    		when 1  # Tradicional

          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 10  # Eletrica
                return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             otherwise
                return false
          end case
       when 2  # Jovem
          return false
       when 3  # Senior
          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 10  # Eletrica
                return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             otherwise
                return false
          end case
       when 4 # Mulher
          case lr_param.socntzcod
             when 1   # Hidraulica
                return true
             when 2   # Desentupimento
             	  return true
             when 3   # Substituicao de Telhas
                return true
             when 10  # Eletrica
                return true
             when 43  # Calhas e Rufos
             	  return true
             when 125 # Substituicao de Telhas
                return true
             when 126 # Calhas e Rufos
             	  return true
             when 288 # Desentupimento Area Externa
             	  return true
             otherwise
                return false
          end case
    end case
end function
#----------------------------------------------#
 function cty31g00_valida_natureza_S42(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case g_nova.perfil
    		when 1  # Tradicional
          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 243 # Tanquinho
               return true
             otherwise
                return false
          end case

       when 2  # Jovem
          return false

       when 3  # Senior
          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 243 # Tanquinho
               return true
             otherwise
                return false
          end case

       when 4 # Mulher
          case lr_param.socntzcod
             when 11  # Telefonia
                return true
             when 12  # Geladeira
             	  return true
             when 13  # Fogao
                return true
             when 14  # Lavadoura
             	  return true
             when 15  # Lava Louca
                return true
             when 16  # Freezer
             	  return true
             when 17  # Secadora
                return true
             when 19  # Microondas
             	  return true
             when 28  # Ar Condicionado
             	  return true
             when 243 # Tanquinho
               return true
             otherwise
                return false
          end case
    end case

end function

#----------------------------------------------#
 function cty31g00_valida_natureza_S67(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case g_nova.perfil
    	 when 1  # Tradicional
         case lr_param.socntzcod
            when 45    # Manutencao Micro
            	 return true
            when 155   # Manutencao Micro
               return true
            when 292   # Video Game
               return true
            when 293   # Smart TV
            	 return true
            when 294   # Tablet
               return true
            when 295   # Smart e Celular
               return true
            when 64    # Checkup
            	 return true
            otherwise
               return false
         end case
       when 2  # Jovem
          return false
       when 3  # Senior
          case lr_param.socntzcod
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
                return true
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
             when 295   # Smart e Celular
                return true
             when 64    # Checkup
             	 return true
             otherwise
                return false
          end case
       when 4 # Mulher
          case lr_param.socntzcod
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
                return true
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
            when 295   # Smart e Celular
               return true
             when 64    # Checkup
                return true
             otherwise
                return false
          end case
    end case
end function
#----------------------------------------------#
 function cty31g00_valida_natureza_S66(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case g_nova.perfil
    	 when 1  # Tradicional
         case lr_param.socntzcod
            when 45    # Manutencao Micro
            	 return true
            when 155   # Manutencao Micro
               return true
            when 292   # Video Game
               return true
            when 293   # Smart TV
            	 return true
            when 294   # Tablet
               return true
            when 295   # Smart ou Celular
               return true
            when 64    # Checkup
            	 return true
            otherwise
               return false
         end case
       when 2  # Jovem
          return false
       when 3  # Senior
          case lr_param.socntzcod
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
             	 return true
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
             when 295   # Smart ou Celular
                return true
             when 64    # Checkup
             	 return true
             otherwise
                return false
          end case
       when 4 # Mulher
          case lr_param.socntzcod
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
             	 return true
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
             when 295   # Smart ou Celular
               return true
             when 64    # Checkup
             	 return true
             otherwise
                return false
          end case
    end case
end function
#----------------------------------------------#
 function cty31g00_valida_natureza_S78(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case g_nova.perfil
    	 when 1  # Tradicional
         case lr_param.socntzcod
            {when 128   # Help Desk
               return true}
            when 45    # Manutencao Micro
            	 return true
            when 155   # Manutencao Micro
               return true
          {  when 206   # Conectividade
            	 return true}
            when 292   # Video Game
               return true
            when 293   # Smart TV
            	 return true
            when 294   # Tablet
               return true
            when 295   # Smart ou Celular
               return true
            when 64    # Checkup
            	 return true
            otherwise
               return false
         end case
       when 2  # Jovem
          return false
       when 3  # Senior
          case lr_param.socntzcod
            { when 128   # Help Desk
                return true}
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
                return true
            { when 206   # Conectividade
             	 return true}
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
             when 295   # Smart ou Celular
                return true
             when 64    # Checkup
             	 return true
             otherwise
                return false
          end case
       when 4 # Mulher
          case lr_param.socntzcod
            { when 128   # Help Desk
                return true}
             when 45    # Manutencao Micro
            	 return true
             when 155   # Manutencao Micro
                return true
            { when 206   # Conectividade
             	 return true}
             when 292   # Video Game
                return true
             when 293   # Smart TV
             	 return true
             when 294   # Tablet
                return true
             when 295   # Smart ou Celular
               return true
             when 64    # Checkup
             	 return true
             otherwise
                return false
          end case
    end case
end function
#-------------------------------------------------#
function cty31g00_quantidade_residencia(lr_param)
#-------------------------------------------------#

define lr_param       record
       ramcod         smallint
      ,succod         like abbmitem.succod
      ,aplnumdig      like abbmitem.aplnumdig
      ,itmnumdig      like abbmitem.itmnumdig
      ,data_calculo   date
      ,c24astcod      like datmligacao.c24astcod
      ,bnfnum         like datrsrvsau.bnfnum
      ,flag_endosso   char(1)
      ,socntzcod      like datksocntz.socntzcod
end record

define lr_retorno record
	resultado         integer                  ,
  mensagem          char(80)                 ,
  prporgpcp         like abamdoc.prporgpcp   ,
  prpnumpcp         like abamdoc.prpnumpcp   ,
  qtde_at_ap        integer                  ,
  qtde_at_pr        integer                  ,
  qtd_atendimento   integer
end record

 initialize lr_retorno.* to null


 let lr_retorno.qtde_at_ap      = 0
 let lr_retorno.qtde_at_pr      = 0
 let lr_retorno.qtd_atendimento = 0
 let lr_retorno.resultado       = 1


 let lr_retorno.qtde_at_ap = cty31g00_quantidade_servico(lr_param.ramcod
                                                        ,lr_param.succod
                                                        ,lr_param.aplnumdig
                                                        ,lr_param.itmnumdig
                                                        ,"",""
                                                        ,lr_param.data_calculo
                                                        ,lr_param.c24astcod
                                                        ,lr_param.bnfnum
                                                        ,lr_param.socntzcod )

 #-----------------------------------------------------------------#
 # Se Nao Tem Endosso, Contar os Servicos Realizados pela Proposta
 #-----------------------------------------------------------------#

 if lr_param.flag_endosso = "N" then

    #-----------------------------------------------------------------#
    # Obter Proposta Original Atraves da Apolice
    #-----------------------------------------------------------------#

    call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
    returning lr_retorno.resultado ,
              lr_retorno.mensagem  ,
              lr_retorno.prporgpcp ,
              lr_retorno.prpnumpcp


    if lr_retorno.resultado <> 1 then

       return lr_retorno.resultado       ,
              lr_retorno.mensagem        ,
              lr_retorno.qtd_atendimento

    end if

    let lr_retorno.qtde_at_pr = cty31g00_quantidade_servico(""                     ,
                                                            ""                     ,
                                                            ""                     ,
                                                            ""                     ,
                                                            lr_retorno.prporgpcp   ,
                                                            lr_retorno.prpnumpcp   ,
                                                            lr_param.data_calculo  ,
                                                            lr_param.c24astcod     ,
                                                            ""                     ,
                                                            lr_param.socntzcod)

 end if

 let lr_retorno.qtd_atendimento = lr_retorno.qtde_at_ap + lr_retorno.qtde_at_pr

 return lr_retorno.resultado,
        lr_retorno.mensagem ,
        lr_retorno.qtd_atendimento

end function

#----------------------------------------------#
function cty31g00_quantidade_servico(lr_param)
#----------------------------------------------#

define lr_param record
   ramcod    like datrservapol.ramcod
  ,succod    like datrservapol.succod
  ,aplnumdig like datrservapol.aplnumdig
  ,itmnumdig like datrservapol.itmnumdig
  ,prporgpcp like datrligprp.prporg
  ,prpnumpcp like datrligprp.prpnumdig
  ,clcdat    like datmservico.atddat
  ,c24astcod like datmligacao.c24astcod
  ,bnfnum    like datrligsau.bnfnum
  ,socntzcod like datksocntz.socntzcod
end record

define lr_servico record
   atdsrvnum like datrservapol.atdsrvnum
  ,atdsrvano like datrservapol.atdsrvano
end record

define lr_retorno record
	qtd integer          ,
	resultado smallint   ,
  mensagem  char(60)
end record


if m_prepare is null or
   m_prepare <> true then
   call cty31g00_prepare()
end if

 initialize lr_servico.*, lr_retorno.* to null

 let lr_retorno.qtd   = 0


 #----------------------------------------------------------------------------#
 # Obter a Quantidade de Servicos Realizados de Acordo com o Assunto Recebido
 #----------------------------------------------------------------------------#

 #----------------------------------------------------------------------------#
 # Obter os Servicos dos Atendimentos Realizados pelo Cartao Saude
 #----------------------------------------------------------------------------#

 if lr_param.bnfnum is not null then

    open ccty31g00009 using lr_param.bnfnum

    foreach ccty31g00009 into lr_servico.*

       #----------------------------------------------------------#
       # Consiste o Servico para Considera-lo na Contagem
       #----------------------------------------------------------#

       call cty31g00_consiste_servico(lr_servico.atdsrvnum
                                     ,lr_servico.atdsrvano
                                     ,lr_param.c24astcod
                                     ,lr_param.clcdat
                                     ,lr_param.socntzcod)
       returning lr_retorno.resultado, lr_retorno.mensagem

       if lr_retorno.resultado = 1 then
          let lr_retorno.qtd  = lr_retorno.qtd + 1
       else

          if lr_retorno.resultado = 3 then
             error lr_retorno.mensagem
             exit foreach
          end if

       end if

    end foreach

    close ccty31g00009

 else

    #-----------------------------------------------------------------#
    # Obter os Servicos dos Atendimentos Realizados pela Apolice
    #-----------------------------------------------------------------#

    if lr_param.aplnumdig is not null then

       open ccty31g00010 using lr_param.ramcod
                              ,lr_param.succod
                              ,lr_param.aplnumdig
                              ,lr_param.itmnumdig

       foreach ccty31g00010 into lr_servico.*

          #-----------------------------------------------------------------#
          # Consiste o Servico para Considera-lo na Contagem
          #-----------------------------------------------------------------#

          call cty31g00_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_param.c24astcod
                                        ,lr_param.clcdat
                                        ,lr_param.socntzcod)
          returning lr_retorno.resultado, lr_retorno.mensagem

          if lr_retorno.resultado = 1 then
             let lr_retorno.qtd  = lr_retorno.qtd + 1
          else
             if lr_retorno.resultado = 3 then

                error lr_retorno.mensagem sleep 2
                exit foreach

             end if
          end if

       end foreach

       close ccty31g00010

    end if

    #-----------------------------------------------------------------#
    # Obter os Servicos dos Atendimentos Realizados pela Proposta
    #-----------------------------------------------------------------#

    if lr_param.prpnumpcp is not null then

       open ccty31g00011 using lr_param.prporgpcp
                              ,lr_param.prpnumpcp
                              ,lr_param.c24astcod

       foreach ccty31g00011 into lr_servico.atdsrvnum
                                ,lr_servico.atdsrvano

          #-------------------------------------------------------#
          # Consiste o Servico para Considera-lo na Contagem
          #-------------------------------------------------------#

          call cty31g00_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_param.c24astcod
                                        ,lr_param.clcdat
                                        ,lr_param.socntzcod)
          returning lr_retorno.resultado, lr_retorno.mensagem

          if lr_retorno.resultado = 1 then
             let lr_retorno.qtd  = lr_retorno.qtd + 1
          else
             if lr_retorno.resultado = 3 then

                error lr_retorno.mensagem sleep 2
                exit foreach

             end if
          end if

       end foreach

       close ccty31g00011

    end if

 end if

 return lr_retorno.qtd

end function


#---------------------------------------------#
function cty31g00_consiste_servico(lr_param)
#---------------------------------------------#

define lr_param record
   atdsrvnum like datmservico.atdsrvnum
  ,atdsrvano like datmservico.atdsrvano
  ,c24astcod like datmligacao.c24astcod
  ,clcdat    like datmservico.atddat
  ,socntzcod like datksocntz.socntzcod
end record

define lr_retorno record
	 resultado smallint
	,mensagem  char(60)
  ,atdetpcod like datmsrvacp.atdetpcod
  ,socntzcod like datksocntz.socntzcod
end record


initialize lr_retorno.* to  null

if m_prepare is null or
   m_prepare <> true then
   call cty31g00_prepare()
end if

 #-----------------------------------------------------------------------------#
 # Consistir Regras para Considerar o Servico na Contagem de Atendimento.
 #
 # 1 - Consistiu Servico de Acordo com a Etapa Testada, Ok.
 # 2 - N�o Achou Servico ou Etapa n�o Est� de Acordo com Etapa Testada, Ok.
 # 3 - Erro de Banco.
 #-----------------------------------------------------------------------------#

 #-----------------------------------------------------------------------------#
 # Verifica se o  Atendimento foi Realizado
 #-----------------------------------------------------------------------------#

 open ccty31g00012 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano
                        ,lr_param.c24astcod
 whenever error continue
 fetch ccty31g00012 into lr_retorno.socntzcod
 whenever error stop

 if sqlca.sqlcode <> 0 then

    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro', sqlca.sqlcode, ' em datmservico '
    end if

 else

    if cty36g00_acesso() then
   	    if not cty36g00_valida_bloco(lr_param.c24astcod  ,
                                     g_nova.perfil       ,
                                     lr_param.socntzcod  ,
                                     lr_retorno.socntzcod) then
   	      let lr_retorno.resultado = 2
   	      return lr_retorno.resultado
   	           , lr_retorno.mensagem
   	    end if
     else
        case lr_param.c24astcod
           when "S60"
              if not cty31g00_valida_bloco_S60(lr_param.socntzcod  ,
              	                               lr_retorno.socntzcod) then
                  let lr_retorno.resultado = 2

                  return lr_retorno.resultado
                       , lr_retorno.mensagem

              end if
           when "S63"
              if not cty31g00_valida_bloco_S63(lr_param.socntzcod  ,
                                               lr_retorno.socntzcod) then
                  let lr_retorno.resultado = 2
                  return lr_retorno.resultado
                       , lr_retorno.mensagem
              end if
           when "S41"
              if not cty31g00_valida_bloco_S41(lr_param.socntzcod  ,
                                               lr_retorno.socntzcod) then
                  let lr_retorno.resultado = 2
                  return lr_retorno.resultado
                       , lr_retorno.mensagem
              end if
           when "S42"
              if not cty31g00_valida_bloco_S42(lr_param.socntzcod  ,
                                               lr_retorno.socntzcod) then
                  let lr_retorno.resultado = 2
                  return lr_retorno.resultado
                       , lr_retorno.mensagem
              end if
        end case
    end if

    #------------------------------------------------#
    # Obtem a Ultima Etapa do Servico
    #------------------------------------------------#

    let lr_retorno.atdetpcod = cts10g04_ultima_etapa(lr_param.atdsrvnum
                                                    ,lr_param.atdsrvano)

    #-----------------------------------------------------------------------------#
    # Para Servico a Residencia, Conta Servicos Liberados(1) e Acionados(3)
    #-----------------------------------------------------------------------------#

    if lr_param.c24astcod = 'S60' or
       lr_param.c24astcod = 'S63' or
       lr_param.c24astcod = 'S66' or
       lr_param.c24astcod = 'S67' or
       lr_param.c24astcod = 'S41' or
       lr_param.c24astcod = 'S42' then

       if (lr_param.c24astcod = 'S66'  or
           lr_param.c24astcod = 'S67') then

           if (lr_param.c24astcod    = 'S66'  ) and
              (lr_retorno.atdetpcod  = 1   or
               lr_retorno.atdetpcod  = 2   or
               lr_retorno.atdetpcod  = 3   or
               lr_retorno.atdetpcod  = 4      ) then

              let lr_retorno.resultado = 1

           else

              if lr_retorno.atdetpcod = 1 or
                 lr_retorno.atdetpcod = 3 then
                 let lr_retorno.resultado = 1
              else
                 let lr_retorno.resultado = 2
              end if

           end if

       else

           if lr_retorno.atdetpcod = 1 or
              lr_retorno.atdetpcod = 3 then
              let lr_retorno.resultado = 1
           else
              let lr_retorno.resultado = 2
           end if

       end if
    end if

 end if

 close ccty31g00012

 return lr_retorno.resultado
      , lr_retorno.mensagem
end function

#----------------------------------------------#
 function cty31g00_valida_bloco_S60(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record

  if  lr_param.socntzcod1 = 1   or   # Hidraulica
  	  lr_param.socntzcod1 = 2   or   # Desentupimento
  	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
  	  lr_param.socntzcod1 = 5   or   # Chaveiro
  	  lr_param.socntzcod1 = 10  or   # Eletrica
  	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
  	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
  	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
      lr_param.socntzcod1 = 141 or   # Chave Tetra
      lr_param.socntzcod1 = 287 or   # Troca de Lampada
      lr_param.socntzcod1 = 288 or   # Desentupimento Area Externa
      lr_param.socntzcod1 = 317 then # Barra de Apoio
         if lr_param.socntzcod2 = 1   or   # Hidraulica
         	  lr_param.socntzcod2 = 2   or   # Desentupimento
         	  lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 5   or   # Chaveiro
         	  lr_param.socntzcod2 = 10  or   # Eletrica
         	  lr_param.socntzcod2 = 43  or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 126 or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 141 or   # Chave Tetra
         	  lr_param.socntzcod2 = 287 or   # Troca de Lampada
         	  lr_param.socntzcod2 = 288 or   # Desentupimento Area Externa
         	  lr_param.socntzcod1 = 317 then # Barra de Apoio
             return true
          end if
   end if
    if lr_param.socntzcod1 = 41  or    # Kit 1
  	   lr_param.socntzcod1 = 42  then  # Kit 2
         if lr_param.socntzcod2 = 41  or    # Kit 1
            lr_param.socntzcod2 = 42  then  # Kit 2
            return true
         end if
   end if
   if lr_param.socntzcod1 = 206  then  # Conectividade
         if lr_param.socntzcod2 = 206  then  # Conectividade
            return true
         end if
   end if
   if lr_param.socntzcod1 = 207  then  # Mudanca de Mobiliario
         if lr_param.socntzcod2 = 207  then  # Mudanca de Mobiliario
            return true
         end if
   end if
   return false
end function
#----------------------------------------------#
 function cty31g00_valida_bloco_S63(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
    if lr_param.socntzcod1  = 11   or   # Telefonia
    	  lr_param.socntzcod1 = 12   or   # Geladeira
    	  lr_param.socntzcod1 = 13   or   # Fogao
    	  lr_param.socntzcod1 = 14   or   # Lavadoura
    	  lr_param.socntzcod1 = 15   or   # Lava Louca
    	  lr_param.socntzcod1 = 16   or   # Freezer
    	  lr_param.socntzcod1 = 17   or   # Secadora
    	  lr_param.socntzcod1 = 19   or   # Microondas
    	  lr_param.socntzcod1 = 47   or   # Reversao de Fogao
        lr_param.socntzcod1 = 243  or   # Tanquinho
        lr_param.socntzcod1 = 300  or   # Geladeira Side by Side
        lr_param.socntzcod1 = 301  or   # Ar Condicionado Split
        lr_param.socntzcod1 = 302  then # Lava Roupas (Lava e Seca)
          if  lr_param.socntzcod2 = 11   or   # Telefonia
          	  lr_param.socntzcod2 = 12   or   # Geladeira
          	  lr_param.socntzcod2 = 13   or   # Fogao
          	  lr_param.socntzcod2 = 14   or   # Lavadoura
          	  lr_param.socntzcod2 = 15   or   # Lava Louca
          	  lr_param.socntzcod2 = 16   or   # Freezer
          	  lr_param.socntzcod2 = 17   or   # Secadora
          	  lr_param.socntzcod2 = 19   or   # Microondas
          	  lr_param.socntzcod2 = 47   or   # Reversao de Fogao
              lr_param.socntzcod2 = 243  or   # Tanquinho
              lr_param.socntzcod2 = 300  or   # Geladeira Side by Side
              lr_param.socntzcod2 = 301  or   # Ar Condicionado Split
              lr_param.socntzcod2 = 302  then # Lava Roupas (Lava e Seca)
                return true
          end if
    end if
    if lr_param.socntzcod1 = 28   or     # Ar Condicionado
       lr_param.socntzcod1 = 104  then   # Ar Condicionado
         if lr_param.socntzcod2 = 28   or     # Ar Condicionado
            lr_param.socntzcod2 = 104  then   # Ar Condicionado
                return true
         end if
    end if
    return false
end function
#----------------------------------------------#
 function cty31g00_valida_bloco_S41(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
   if lr_param.socntzcod1 = 1   or   # Hidraulica
   	  lr_param.socntzcod1 = 2   or   # Desentupimento
   	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 10  or   # Eletrica
   	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 288 or   # Desentupimento Area Externa
      lr_param.socntzcod1 = 11  or   # Telefonia
   	  lr_param.socntzcod1 = 12  or   # Geladeira
   	  lr_param.socntzcod1 = 13  or   # Fogao
   	  lr_param.socntzcod1 = 14  or   # Lavadoura
   	  lr_param.socntzcod1 = 15  or   # Lava Louca
   	  lr_param.socntzcod1 = 16  or   # Freezer
   	  lr_param.socntzcod1 = 17  or   # Secadora
   	  lr_param.socntzcod1 = 19  or   # Microondas
      lr_param.socntzcod1 = 243 then # Tanquinho
         if lr_param.socntzcod2 = 1   or   # Hidraulica
         	  lr_param.socntzcod2 = 2   or   # Desentupimento
         	  lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 10  or   # Eletrica
         	  lr_param.socntzcod2 = 43  or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 126 or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 288 or   # Desentupimento Area Externa
            lr_param.socntzcod2 = 11  or   # Telefonia
         	  lr_param.socntzcod2 = 12  or   # Geladeira
         	  lr_param.socntzcod2 = 13  or   # Fogao
         	  lr_param.socntzcod2 = 14  or   # Lavadoura
         	  lr_param.socntzcod2 = 15  or   # Lava Louca
         	  lr_param.socntzcod2 = 16  or   # Freezer
         	  lr_param.socntzcod2 = 17  or   # Secadora
         	  lr_param.socntzcod2 = 19  or   # Microondas
            lr_param.socntzcod2 = 243 then # Tanquinho
               return true
          end if
    end if
    return false
end function
#----------------------------------------------#
 function cty31g00_valida_bloco_S42(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
   if lr_param.socntzcod1 = 1   or   # Hidraulica
   	  lr_param.socntzcod1 = 2   or   # Desentupimento
   	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 10  or   # Eletrica
   	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
      lr_param.socntzcod1 = 11  or   # Telefonia
   	  lr_param.socntzcod1 = 12  or   # Geladeira
   	  lr_param.socntzcod1 = 13  or   # Fogao
   	  lr_param.socntzcod1 = 14  or   # Lavadoura
   	  lr_param.socntzcod1 = 15  or   # Lava Louca
   	  lr_param.socntzcod1 = 16  or   # Freezer
   	  lr_param.socntzcod1 = 17  or   # Secadora
   	  lr_param.socntzcod1 = 19  or   # Microondas
      lr_param.socntzcod1 = 243 then # Tanquinho
         if lr_param.socntzcod2 = 1   or   # Hidraulica
         	  lr_param.socntzcod2 = 2   or   # Desentupimento
         	  lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 10  or   # Eletrica
         	  lr_param.socntzcod2 = 43  or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 126 or   # Calhas e Rufos
            lr_param.socntzcod2 = 11  or   # Telefonia
         	  lr_param.socntzcod2 = 12  or   # Geladeira
         	  lr_param.socntzcod2 = 13  or   # Fogao
         	  lr_param.socntzcod2 = 14  or   # Lavadoura
         	  lr_param.socntzcod2 = 15  or   # Lava Louca
         	  lr_param.socntzcod2 = 16  or   # Freezer
         	  lr_param.socntzcod2 = 17  or   # Secadora
         	  lr_param.socntzcod2 = 19  or   # Microondas
            lr_param.socntzcod2 = 243 then # Tanquinho
               return true
          end if
    end if
    return false

end function
#--------------------------------------------------------#
 function cty31g00_recupera_limite_clausula_26(lr_param)
#--------------------------------------------------------#
define lr_param record
       clscod   like abbmclaus.clscod
end record

define lr_retorno record
       limite     integer
end record

initialize lr_retorno.* to null

      case lr_param.clscod
        when "26A"  let lr_retorno.limite     = 15
        when "26B"  let lr_retorno.limite     = 30
        when "26C"  let lr_retorno.limite     = 07

        when "26D"  let lr_retorno.limite     = 07  ### Deficiente Fisico
        when "26E"  let lr_retorno.limite     = 07
        when "26F"  let lr_retorno.limite     = 30
        when "26G"  let lr_retorno.limite     = 07

        when "26H"  let lr_retorno.limite     = 15  # Carro Extra Medio Porte
        when "26I"  let lr_retorno.limite     = 30  # Carro Extra Medio Porte
        when "26J"  let lr_retorno.limite     = 07  # Carro Extra Medio Porte
        when "26K"  let lr_retorno.limite     = 07  # Carro Extra Medio Porte
        when "26L"  let lr_retorno.limite     = 15  # Carro Extra Medio Porte
        when "26M"  let lr_retorno.limite     = 30  # Carro Extra Medio Porte
      end case

      return lr_retorno.limite

end function

#----------------------------------------------#
 function cty31g00_valida_data_corte1()
#----------------------------------------------#

  if g_nova.dt_cal >= "01/04/2014" then
     return true
  else

  	 return false
  end if

end function

#----------------------------------------------#
 function cty31g00_valida_clausula_corte1()
#----------------------------------------------#

   if g_nova.clscod = "033"  or
      g_nova.clscod = "035"  then
      return true
   else

   	  return false
   end if

end function

#----------------------------------------------#
 function cty31g00_nova_regra_corte1()
#----------------------------------------------#

  if cty31g00_valida_data_corte1()     and
     cty31g00_valida_clausula_corte1() then
  	  return true
  else
      return false
  end if

end function

#----------------------------------------------#
 function cty31g00_valida_data_corte2()
#----------------------------------------------#

  if g_nova.dt_cal >= "01/01/2015" then
     return true
  else
  	 return false
  end if

end function

#----------------------------------------------#
 function cty31g00_valida_clausula_corte2()
#----------------------------------------------#

   if g_nova.clscod = "033"  or
   	  g_nova.clscod = "33R"  or
      g_nova.clscod = "035"  then
      return true
   else
   	  return false
   end if

end function

#----------------------------------------------#
 function cty31g00_valida_categoria_corte2()
#----------------------------------------------#

   if g_nova.ctgtrfcod = 10  then
      return true
   else
   	  return false
   end if

end function

#----------------------------------------------#
 function cty31g00_valida_classe_corte2()
#----------------------------------------------#

   if g_nova.clalclcod  = 11  then
      return true
   else
   	  return false
   end if

end function

#----------------------------------------------#
 function cty31g00_nova_regra_corte2()
#----------------------------------------------#

  if cty31g00_valida_data_corte2()      and
     cty31g00_valida_clausula_corte2()  and
     cty31g00_valida_categoria_corte2() and
     cty31g00_valida_classe_corte2()    then
  	  return true
  else
      return false
  end if

end function

#---------------------------------------------------#
 function cty31g00_valida_natureza_corte2(lr_param)
#---------------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

   if lr_param.socntzcod  = 317  then # Barra de Apoio
      return true
   else
   	  return false
   end if

end function

#----------------------------------------------#
 function cty31g00_nova_regra_corte3()
#----------------------------------------------#
  if cty31g00_valida_data_corte3()     and
     cty31g00_valida_clausula_corte3() then
  	  return true
  else
      return false
  end if
end function

#----------------------------------------------#
 function cty31g00_valida_data_corte3()
#----------------------------------------------#
  if g_nova.dt_cal >= "01/09/2014" then
     return true
  else
  	 return false
  end if
end function

#----------------------------------------------#
 function cty31g00_valida_clausula_corte3()
#----------------------------------------------#
   if g_nova.clscod = "034" then
      return true
   else
   	  return false
   end if
end function

#----------------------------------------------#
 function cty31g00_valida_segmento_moto(lr_param)
#----------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record

  if lr_param.ctgtrfcod = 30 or
  	 lr_param.ctgtrfcod = 31 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------#
 function cty31g00_valida_segmento_taxi(lr_param)
#----------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record

  if lr_param.ctgtrfcod = 80 or
  	 lr_param.ctgtrfcod = 81 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_valida_segmento_caminhao(lr_param)
#----------------------------------------------------#

define lr_param record
	ctgtrfcod      like abbmcasco.ctgtrfcod
end record


  if lr_param.ctgtrfcod = 40 or
  	 lr_param.ctgtrfcod = 41 or
  	 lr_param.ctgtrfcod = 42 or
  	 lr_param.ctgtrfcod = 43 then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_valida_segmento_premium(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer               ,
	imsvlr  like abbmcasco.imsvlr
end record


  if lr_param.imsvlr >= 200000.00 and
  	 lr_param.idade  >= 25        and
  	 lr_param.idade  <= 59        then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_valida_segmento_mulher(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer               ,
	rspcod  like abbmquestionario.rspcod
end record


  if lr_param.rspcod =  2   and
  	 lr_param.idade  >= 25  and
  	 lr_param.idade  <= 59  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_valida_segmento_jovem(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer
end record

  if lr_param.idade  >= 18  and
  	 lr_param.idade  <= 24  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_valida_segmento_senior(lr_param)
#----------------------------------------------------#

define lr_param record
	idade   integer
end record

  if lr_param.idade  >= 60  then
  	 	 return true
  end if

  return false

end function

#----------------------------------------------------#
 function cty31g00_descricao_segmento(lr_param)
#----------------------------------------------------#

define lr_param record
	segmento   integer
end record

define lr_retorno record
	descricao   char(50)
end record


  initialize lr_retorno.* to null

   case lr_param.segmento
    	 when 1
    	   let lr_retorno.descricao = "SEGMENTO TRADICIONAL"
    	 when 2
    	 	 let lr_retorno.descricao = "SEGMENTO JOVEM "
       when 3
         let lr_retorno.descricao = "SEGMENTO SENIOR "
       when 4
         let lr_retorno.descricao = "SEGMENTO MULHER "
       when 5
    	   let lr_retorno.descricao = "SEGMENTO TAXI "
    	 when 6
    	 	 let lr_retorno.descricao = "SEGMENTO CAMINHAO "
       when 7
         let lr_retorno.descricao = "SEGMENTO MOTO "
       when 8
         let lr_retorno.descricao = "SEGMENTO PREMIUM"
       when 9
         let lr_retorno.descricao = "SEGMENTO P.JURIDICA "
   end case

   return lr_retorno.descricao

end function

#--------------------------------------------------------------#
 function cty31g00_recupera_segmento(lr_param)
#--------------------------------------------------------------#

define lr_param record
	succod     like abbmapldctsgm.succod    ,
	aplnumdig  like abbmapldctsgm.aplnumdig ,
	itmnumdig  like abbmapldctsgm.itmnumdig ,
	dctnumseq  like abbmapldctsgm.dctnumseq
end record

define lr_retorno record  
	 perfil    integer                      ,
   dctsgmcod like abbmapldctsgm.dctsgmcod
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if
  
 
  initialize lr_retorno.* to null

  #------------------------------------------------#
  # Recupera o Segmento
  #------------------------------------------------#
  
  
  
  open ccty31g00013 using lr_param.succod
                         ,lr_param.aplnumdig
                         ,lr_param.itmnumdig
                         ,lr_param.dctnumseq
  whenever error continue
  fetch ccty31g00013 into lr_retorno.dctsgmcod
  whenever error stop
 
  
  if lr_retorno.dctsgmcod is not null then
     
     #------------------------------------------------#
     # Recupera o De-Para
     #------------------------------------------------#
          
     call cty31g00_recupera_depara(lr_retorno.dctsgmcod)
     returning lr_retorno.perfil 
     
  
  end if
  

  return lr_retorno.perfil ,
         lr_retorno.dctsgmcod

end function

#--------------------------------------------------------------#
 function cty31g00_recupera_tipo_atendimento(lr_param)
#--------------------------------------------------------------#

define lr_param record
	pestip     like gsakseg.pestip      ,  
	cgccpfnum  like gsakseg.cgccpfnum   ,
  cgcord     like gsakseg.cgcord      ,
  cgccpfdig  like gsakseg.cgccpfdig
end record

define lr_retorno record  
   clisgmcod like apamconclisgm.clisgmcod,
   data      date
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if
  
 
  initialize lr_retorno.* to null
  
  let lr_retorno.data = today

  #------------------------------------------------#
  # Recupera o Tipo de Atendimento
  #------------------------------------------------#
 
  
  
  open ccty31g00016 using lr_param.pestip   
                         ,lr_param.cgccpfnum
                         ,lr_param.cgcord   
                         ,lr_param.cgccpfdig  
                         ,lr_retorno.data
  whenever error continue
  fetch ccty31g00016 into lr_retorno.clisgmcod
  whenever error stop
 
 
  return lr_retorno.clisgmcod

end function

#----------------------------------------------------#
 function cty31g00_recupera_descricao_premium()
#----------------------------------------------------#


define lr_retorno record
	descricao   char(50)
end record


  initialize lr_retorno.* to null

  if g_nova.clisgmcod  = 2 then
     let lr_retorno.descricao = "ATENDIMENTO PREMIUM"
  end if

  return lr_retorno.descricao

end function

#--------------------------------------------------------------#       
 function cty31g00_recupera_depara(lr_param)                         
#--------------------------------------------------------------#       

define lr_param  record   
   cpocod     like datkdominio.cpocod                 
end record                               
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cponom     like datkdominio.cponom,
	 cpodes     like datkdominio.cpodes                                        
end record 

if m_prepare is null or                                              
    m_prepare <> true then                                            
    call cty31g00_prepare()                                           
end if                   

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cponom = "ctc53m31_depara"                           
                                                                             
         #--------------------------------------------------------           
         # Recupera o Segmento                                               
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty31g00014 using lr_retorno.cponom ,        
                                 lr_param.cpocod              
                                                                             
         whenever error continue                                             
         fetch ccty31g00014 into lr_retorno.cpodes          
         whenever error stop 
         
         return lr_retorno.cpodes                                                
                                                                                                                                                          
end function 

#--------------------------------------------------------------#       
 function cty31g00_recupera_parade(lr_param)                         
#--------------------------------------------------------------#       

define lr_param  record  
   cpodes     like datkdominio.cpodes                 
end record                               
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cponom     like datkdominio.cponom,
	 cpocod     like datkdominio.cpocod                                        
end record 

if m_prepare is null or                                              
    m_prepare <> true then                                            
    call cty31g00_prepare()                                           
end if                   

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cponom = "ctc53m31_depara"                           
                                                                             
         #--------------------------------------------------------           
         # Recupera o Segmento                                               
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty31g00015 using lr_retorno.cponom ,        
                                 lr_param.cpodes              
                                                                             
         whenever error continue                                             
         fetch ccty31g00015 into lr_retorno.cpocod          
         whenever error stop 
         
         return lr_retorno.cpocod                                                
                                                                                                                                                          
end function  

#----------------------------------------------#                                                                                                         
 function cty31g00_valida_atd_premium()                                                                                                                                                        
#----------------------------------------------#         
                                                       
  if g_nova.clisgmcod = 2 then               
     return true                                        
  else                                                  
  	 return false                                       
  end if                                                
end function 

#========================================================================                                                 
function cty31g00_dispara_email(lr_param)                                              
#========================================================================

define lr_param record                      
	atdsrvnum   like  datmservico.atdsrvnum , 
	atdsrvano   like  datmservico.atdsrvano , 
	succod      like  datrligapol.succod    , 
	ramcod      like  datrligapol.ramcod    , 
	aplnumdig   like  datrligapol.aplnumdig , 
	itmnumdig   like  datrligapol.itmnumdig   
end record                                  
      
                                                                               
define lr_mail      record                                                     
       de           char(500)   # De                                           
      ,para         char(5000)  # Para                                         
      ,cc           char(500)   # cc                                           
      ,cco          char(500)   # cco                                          
      ,assunto      char(500)   # Assunto do e-mail                            
      ,mensagem     char(32766) # Nome do Anexo                                
      ,id_remetente char(20)                                                   
      ,tipo         char(4)     #                                              
  end  record                                                                  
                                                                               
define l_erro  smallint                                                        
define msg_erro char(500)                                                      
initialize lr_mail.* to null                                                   
                                                                               
                                                                               
    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"                    
    let lr_mail.para    = cty31g00_recupera_email()                            
    let lr_mail.cc      = ""                                                   
    let lr_mail.cco     = ""                                                   
                                                                               
    let lr_mail.assunto = "Atendimento Premium -", lr_param.atdsrvnum, "-", lr_param.atdsrvano                       
                                                                               
    let lr_mail.mensagem  = cty31g00_monta_mensagem(lr_param.*)                          
    let lr_mail.id_remetente = "CT24HS"                                        
    let lr_mail.tipo = "html"                                                  
                                                                               
    #-----------------------------------------------                           
    # Dispara o E-mail                                                         
    #-----------------------------------------------                           
                                                                               
     call figrc009_mail_send1 (lr_mail.*)                                      
     returning l_erro                                                          
              ,msg_erro                                                        
                                                                               
                                                                               
                                                                               
#========================================================================      
end function                                                                   
#======================================================================== 

#========================================================================                             
function cty31g00_recupera_email()                                                               
#========================================================================                        
                                                                                                 
define lr_retorno record                                                                         
	cponom  like datkdominio.cponom,                                                               
	cpocod  like datkdominio.cpocod,                                                               
	cpodes  like datkdominio.cpodes,                                                               
	email   char(32766)            ,                                                               
	flag    smallint                                                                               
end record                                                                                       
                                                                                                 
initialize lr_retorno.* to null                                                                  
                                                                                                 
let lr_retorno.flag = true                                                                       
                                                                                                 
let lr_retorno.cponom = "cty31g00_email"                                                         
                                                                                                 
                                                                                                 
  open ccty31g00017 using  lr_retorno.cponom                                                   
  foreach ccty31g00017 into lr_retorno.cpodes                                                  
                                                                                                 
    if lr_retorno.flag then                                                                      
      let lr_retorno.email = lr_retorno.cpodes clipped                                           
      let lr_retorno.flag  = false                                                               
    else                                                                                         
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped            
    end if                                                                                       
                                                                                                 
                                                                                                 
  end foreach                                                                                    
                                                                                                 
                                                                                                 
  return lr_retorno.email                                                                        
                                                                                                 
                                                                                                 
#========================================================================                        
end function                                                                                     
#======================================================================== 

#========================================================================
function cty31g00_monta_mensagem(lr_param)
#========================================================================

define lr_param record            
	atdsrvnum   like  datmservico.atdsrvnum ,
	atdsrvano   like  datmservico.atdsrvano ,
	succod      like  datrligapol.succod    ,
	ramcod      like  datrligapol.ramcod    ,
	aplnumdig   like  datrligapol.aplnumdig ,
	itmnumdig   like  datrligapol.itmnumdig    
end record                          

define lr_retorno record
	mensagem     char(30000)                 ,   
	historico    char(30000)                 ,   
	nom          like datmservico.nom        ,
	dddcod       like datmlcl.dddcod         ,
	lcltelnum    like datmlcl.lcltelnum      ,
	celteldddcod like datmlcl.celteldddcod   ,
	celtelnum    like datmlcl.celtelnum   	
end record

initialize lr_retorno.* to null 

           #--------------------------------------------------------        
           # Recupera os Dados                                           
           #--------------------------------------------------------        
                                                                            
           open ccty31g00018 using lr_param.atdsrvnum,                     
                                   lr_param.atdsrvano                          
                                                                            
           whenever error continue                                          
           fetch ccty31g00018 into lr_retorno.nom          ,    
                                   lr_retorno.dddcod       ,
                                   lr_retorno.lcltelnum    ,
                                   lr_retorno.celteldddcod ,
                                   lr_retorno.celtelnum   
                               
           whenever error stop                                              


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          let lr_retorno.mensagem = "<PRE><P><B>",
                                    " ATENDIMENTO PREMIUM " ,
                                    "</B></P>",
                                    "<P>",
                                    " NUMERO DO SERVICO...: " , lr_param.atdsrvnum using '<<<<<<<<<' ,"-", lr_param.atdsrvano using '&&'         , "<br>" ,
                                    " APOLICE.............: " , lr_param.ramcod using '&&&', "-", lr_param.succod using '<<&&', "-", 
                                      lr_param.aplnumdig using '<<<&&&&&&', "-", lr_param.itmnumdig using '<<&&'                                 , "<br>" ,
                                    " NOME................: " , lr_retorno.nom clipped                                                           , "<br>" ,                                      
                                    " TELEFONE............: " , lr_retorno.dddcod using '&&&' , "-", lr_retorno.lcltelnum using '<<<&&&&&&'      , "<br>" ,                                      
                                    " CELULAR.............: " , lr_retorno.celteldddcod using '&&&', "-", lr_retorno.celtelnum using '<<<&&&&&&' , "<br>" ,  
                                    "</P></PRE>"

          let lr_retorno.historico = cty31g00_recupera_historico(lr_param.atdsrvnum, lr_param.atdsrvano) 
          
          let lr_retorno.mensagem  = lr_retorno.mensagem clipped, lr_retorno.historico clipped                                                       

          return lr_retorno.mensagem
          

#========================================================================
end function
#========================================================================

#========================================================================
function cty31g00_recupera_historico(lr_param)
#========================================================================

define lr_param record            
	atdsrvnum   like  datmservico.atdsrvnum ,
	atdsrvano   like  datmservico.atdsrvano 
end record                          

define lr_retorno record
	c24srvdsc like datmservhist.c24srvdsc ,
	mensagem  char(30000)                 ,
	texto    char(30000)                                
end record

initialize lr_retorno.* to null    

          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          let lr_retorno.mensagem = "<PRE><P><B>",
                                    " HISTORICO DO ATENDIMENTO " ,
                                    "</B></P>",
                                    "<P>"
         
          
          #-------------------------------------------------------- 
          # Recupera Historico                                     
          #-------------------------------------------------------- 
      
          open ccty31g00019 using lr_param.atdsrvnum ,  
                                  lr_param.atdsrvano
                                                           
  				foreach ccty31g00019 into lr_retorno.c24srvdsc                                                  
                                                                                             
             let lr_retorno.texto = lr_retorno.texto clipped, lr_retorno.c24srvdsc , "<br>"         
                                                                                                                                                                                                                    
  				end foreach                       
          
          let lr_retorno.mensagem = lr_retorno.mensagem clipped, lr_retorno.texto, "</P></PRE>" 
         
          return lr_retorno.mensagem

#========================================================================
end function
#======================================================================== 

#--------------------------------------------------------------#
 function cty31g00_recupera_segmento_proposta(lr_param)
#--------------------------------------------------------------#

define lr_param record
	prporgpcp  like apbmprpdctsgm.prporgpcp ,  
  prpnumpcp  like apbmprpdctsgm.prpnumpcp 
end record

define lr_retorno record  
	 perfil    integer                      ,
   dctsgmcod like abbmapldctsgm.dctsgmcod
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if
  
 
  initialize lr_retorno.* to null

  #------------------------------------------------#
  # Recupera o Segmento por Proposta
  #------------------------------------------------#
   
  open ccty31g00020 using lr_param.prporgpcp
                         ,lr_param.prpnumpcp
  whenever error continue
  fetch ccty31g00020 into lr_retorno.dctsgmcod
  whenever error stop
 
  
  if lr_retorno.dctsgmcod is not null then
     
     #------------------------------------------------#
     # Recupera o De-Para
     #------------------------------------------------#
          
     call cty31g00_recupera_depara(lr_retorno.dctsgmcod)
     returning lr_retorno.perfil 
     
  
  end if
  

  return lr_retorno.perfil ,
         lr_retorno.dctsgmcod

end function

#----------------------------------------------------#
 function cty31g00_recupera_dados_proposta(lr_param)
#----------------------------------------------------#

define lr_param record
	prporgpcp  like apbmprpdctsgm.prporgpcp ,  
  prpnumpcp  like apbmprpdctsgm.prpnumpcp 
end record

define lr_retorno record
   segnumdig      like gsakseg.segnumdig       ,
   cgccpfnum      like gsakseg.cgccpfnum       ,
   cgcord         like gsakseg.cgcord          ,
   cgccpfdig      like gsakseg.cgccpfdig       ,
   pestip         like gsakseg.pestip          ,
   clisgmcod      like apamconclisgm.clisgmcod  
end record

  if m_prepare is null or
     m_prepare <> true then
     call cty31g00_prepare()
  end if

  initialize lr_retorno.* to null

      #-----------------------------------------------------------
      # Localiza o Numero do Segurado
      #-----------------------------------------------------------


      open ccty31g00021  using lr_param.prporgpcp ,
                               lr_param.prpnumpcp                                  
      whenever error continue
      fetch ccty31g00021 into lr_retorno.segnumdig
                             
      whenever error stop

      close ccty31g00021


      #-----------------------------------------------------------
      # Recupera os Dados do CGC/CPF
      #-----------------------------------------------------------

      open ccty31g00022  using lr_retorno.segnumdig
                               
      whenever error continue
      fetch ccty31g00022 into lr_retorno.cgccpfnum ,
                              lr_retorno.cgcord    ,
                              lr_retorno.cgccpfdig ,
                              lr_retorno.pestip

      whenever error stop

      close ccty31g00022
      
      
      #-----------------------------------------------------------       
      # Recupera o Tipo de Atendimento                                   
      #-----------------------------------------------------------       
                                                                         
      call cty31g00_recupera_tipo_atendimento(lr_retorno.pestip    ,     
                                              lr_retorno.cgccpfnum ,     
                                              lr_retorno.cgcord    ,     
                                              lr_retorno.cgccpfdig )     
      returning lr_retorno.clisgmcod                                     
     
      return  lr_retorno.clisgmcod

end function  

#--------------------------------------------------------------#       
 function cty31g00_recupera_descricao_fisico_apolice(lr_param)                         
#--------------------------------------------------------------#       

define lr_param  record
   succod      like datrservapol.succod   ,
   aplnumdig   like datrservapol.aplnumdig,
   itmnumdig   like datrservapol.itmnumdig
end record                             
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cont      integer ,
	 descricao char(20)                                   
end record 

if m_prepare is null or                                              
    m_prepare <> true then                                            
    call cty31g00_prepare()                                           
end if                   

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cont = 0                          
                                                                             
         #--------------------------------------------------------           
         # Valida se Apolice e de Deficiente Fisico                                       
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty31g00023 using  lr_param.succod    , 
                                  lr_param.aplnumdig ,
                                  lr_param.itmnumdig          
                                                                             
         whenever error continue                                             
         fetch ccty31g00023 into lr_retorno.cont          
         whenever error stop 
         
         if lr_retorno.cont > 0 then
         	  let lr_retorno.descricao = "DEFICIENTE FISICO"
         end if
         
         return lr_retorno.descricao                                               
                                                                                                                                                          
end function   

#--------------------------------------------------------------#       
 function cty31g00_recupera_descricao_fisico_proposta(lr_param)                         
#--------------------------------------------------------------#       

define lr_param record
	prporgpcp  like apbmprpdctsgm.prporgpcp ,  
  prpnumpcp  like apbmprpdctsgm.prpnumpcp 
end record                          
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cont      integer ,
	 descricao char(20)                                   
end record 

if m_prepare is null or                                              
    m_prepare <> true then                                            
    call cty31g00_prepare()                                           
end if                   

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cont = 0                          
                                                                             
         #--------------------------------------------------------           
         # Valida se Proposta e de Deficiente Fisico                                       
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty31g00024 using  lr_param.prporgpcp ,
                                  lr_param.prpnumpcp
                                        
                                                                             
         whenever error continue                                             
         fetch ccty31g00024 into lr_retorno.cont          
         whenever error stop 
         
         if lr_retorno.cont > 0 then
         	  let lr_retorno.descricao = "DEFICIENTE FISICO"
         end if
         
         return lr_retorno.descricao                                               
                                                                                                                                                          
end function  

#--------------------------------------------------------------#       
 function cty31g00_valida_fisico_apolice(lr_param)                         
#--------------------------------------------------------------#       

define lr_param  record
   succod      like datrservapol.succod   ,
   aplnumdig   like datrservapol.aplnumdig,
   itmnumdig   like datrservapol.itmnumdig
end record                             
                                                                                                                                                                                          
define lr_retorno  record                                                    
	 cont      integer                                 
end record 

if m_prepare is null or                                              
    m_prepare <> true then                                            
    call cty31g00_prepare()                                           
end if                   

                                                                                                                                                                                                                                                                             
initialize lr_retorno.* to null                                              
                                                                                                                                                          
         let lr_retorno.cont = 0                          
                                                                             
         #--------------------------------------------------------           
         # Valida se Apolice e de Deficiente Fisico                                       
         #--------------------------------------------------------           
                                                                                                                                                          
         open ccty31g00023 using  lr_param.succod    , 
                                  lr_param.aplnumdig ,
                                  lr_param.itmnumdig          
                                                                             
         whenever error continue                                             
         fetch ccty31g00023 into lr_retorno.cont          
         whenever error stop 
         
         if lr_retorno.cont > 0 then
         	  return true
         end if
         
         return false                                              
                                                                                                                                                          
end function 