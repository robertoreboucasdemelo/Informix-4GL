#############################################################################
# Nome do Modulo: BDBSR520 - RELATORIO PORTO SOCORRO CENTRO DE CUSTO        #
# Data de Criacao: 30/07/2007                                               #
# Analista Responsável: Cristiane Silva                                     #
# Analista Desenvolvimento: Eduardo Vieira				                          #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/06/2015  RCP,Fornax   RELTXT       Criar versao .txt dos relatorios.   #
#############################################################################

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"


 define m_bdbsr520 record
    socopgnum    like dbsmopg.socopgnum,
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano,
    srvtipdes    like datksrvtip.srvtipdes,
    socntzdes    like datksocntz.socntzdes,
    aplnumdig    like datrservapol.aplnumdig,
    succod       like datrservapol.succod,
    cctcod       like dbscadtippgt.cctcod,
    cctdptnom    like ctgkdpt.cctdptnom,
    c24solnom    like datmligacao.c24solnom,
    atddat       like datmservico.atddat,
    socfatpgtdat like dbsmopg.socfatpgtdat,
    socopgitmvlr like dbsmopgitm.socopgitmvlr,
    pgtmat       like dbscadtippgt.pgtmat,
    funnom       like isskfunc.funnom,
    corsus       like dbscadtippgt.corsus,
    cornom       like gcakcorr.cornom,
    lignum       like datmligacao.lignum
 end record

 define ws_datade     date
 define ws_dataate    date
 define m_datparam    char(10)
 define param_soctip smallint

 define l_param record
        empcod    like ctgklcl.empcod,       --Empresa
        succod    like ctgklcl.succod,       --Sucursal
        cctlclcod like ctgklcl.cctlclcod,    --Local
        cctdptcod like ctgrlcldpt.cctdptcod  --Departamento
 end record

 define lr_ret record
        erro          smallint, ## 0-Ok,1-erro
        mens          char(40),
        cctlclnom     like ctgklcl.cctlclnom,       ##Nome do local
        cctdptnom     like ctgkdpt.cctdptnom,       ##Nome do departamento (antigo cctnom)
        cctdptrspnom  like ctgrlcldpt.cctdptrspnom, ##Responsavel pelo  departamento
        cctdptlclsit  like ctgrlcldpt.cctdptlclsit, ##Situagco do depto (A)tivo ou (I)nativo
        cctdpttip     like ctgkdpt.cctdpttip        ##Tipo de departamento
end record

define m_path     char(100)
define m_path_txt char(100) #--> RELTXT
define m_mes_int  smallint


 main

    initialize m_bdbsr520 to null

     call bdbsr520_prepare()
     call bdbsr520_periodoextracao()
     call bdbsr520_gerarelatorioauto()
     call bdbsr520_gerarelatoriore()

end main


#------------------------------------------------------
 function bdbsr520_prepare()
#------------------------------------------------------
 define l_sql char(2000)
   let l_sql = " select  opg.socopgnum,  	                                    ",
		                   " srv.atdsrvnum,                                       ",
		                   " srv.atdsrvano,                                       ",
		                   " tip.srvtipdes,                                       ",
		                   " lig.c24solnom,                                       ",
		                   " lig.lignum,                                          ",
		                   " srv.atddat,                                          ",
		                   " opg.socfatpgtdat,			                              ",
		                   " itm.socopgitmvlr,                                    ",
		                   " rat.cctcod				                                    ",
		                   " from                                                 ",
		                   " dbsmopg opg,                                         ",
		                   " datmservico srv,                                     ",
		                   " dbsmcctrat rat,                                      ",
		                   " datmligacao lig,                                     ",
		                   " dbsmopgitm itm,                                      ",
		                   " datksrvtip tip                                       ",
		                   " where                                                ",
		                   " opg.socopgnum = itm.socopgnum                        ",
		                   " and	itm.atdsrvnum = srv.atdsrvnum                   ",
		                   " and	itm.atdsrvano = srv.atdsrvano                   ",
		                   " and     srv.atdsrvnum = rat.atdsrvnum                ",
		                   " and     srv.atdsrvano = rat.atdsrvano                ",
		                   " and     srv.atdsrvnum = lig.atdsrvnum                ",
		                   " and	srv.atdsrvano = lig.atdsrvano                   ",
		                   " and     srv.atdtip    = tip.atdtip                   ",
		                   " and     opg.soctip = 1                               ",
		                   " and	opg.socfatpgtdat between ? and ?                ",
		                   " and	srv.ciaempcod = 1                               ",
		                   " and opg.socopgsitcod = 7                             "

    prepare pbdbsr520001 from l_sql
    declare cbdbsr520001 cursor for pbdbsr520001

   let l_sql = " select  ",
	" opg.socopgnum,      ",
	" srv.atdsrvnum,      ",
	" srv.atdsrvano,      ",
	" ntz.socntzdes,      ",
	" lig.c24solnom,      ", 
	" lig.lignum,             ",
	" srv.atddat,	      ",
	" opg.socfatpgtdat,   ",
	" itm.socopgitmvlr,   ",
	" rat.cctcod	      ",
	" from                ",
	" dbsmopg opg,        ",
	" datmservico srv,    ",
	" datmligacao lig,    ",
	" dbsmopgitm itm,     ",
	" datmsrvre re,      ",
	" datksocntz ntz,     ",
	" dbsmcctrat rat ",
	" where               ",
	" opg.socopgnum = itm.socopgnum           ",
	" and	itm.atdsrvnum = srv.atdsrvnum     ",
	" and	itm.atdsrvano = srv.atdsrvano     ",
	" and     srv.atdsrvnum = rat.atdsrvnum      ",
	" and     srv.atdsrvano = rat.atdsrvano     ",
	" and     srv.atdsrvnum = lig.atdsrvnum   ",
	" and	srv.atdsrvano = lig.atdsrvano     ",
	" and     srv.atdsrvnum     = re.atdsrvnum      ",
	" and     srv.atdsrvano = re.atdsrvano ",
	" and     re.socntzcod = ntz.socntzcod ",
	" and     opg.soctip = 3                  ",
	" and	opg.socfatpgtdat between ? and ?    ",
	" and	srv.ciaempcod = 1 ",
	" and opg.socopgsitcod = 7 "
    prepare pbdbsr520002 from l_sql
    declare cbdbsr520002 cursor for pbdbsr520002

    let l_sql = " select pgt.cctcod, dpt.cctdptnom ",
		" from dbsmcctrat pgt, ctgrlcldpt lcl, ctgkdpt dpt ",
		" where pgt.cctcod = lcl.cctcod ",
		" and lcl.cctdptcod = dpt.cctdptcod ",
		" and pgt.atdsrvnum = ? ",
		" and pgt.atdsrvano = ? "
    prepare pbdbsr520003 from l_sql
    declare cbdbsr520003 cursor for pbdbsr520003


    let l_sql = " select aplnumdig, succod ",
    		" from datrservapol ",
    		" where atdsrvnum = ? ",
    		" and atdsrvano = ? "
    prepare pbdbsr520004 from l_sql
    declare cbdbsr520004 cursor for pbdbsr520004


    let l_sql = " select  opg.socopgnum,  ",
		" srv.atdsrvnum,          ",
		" srv.atdsrvano,          ",
		" tip.srvtipdes,          ",
		" lig.c24solnom,          ",
		" lig.lignum,             ",
		" srv.atddat,             ",
		" opg.socfatpgtdat,	 ",
		" itm.socopgitmvlr,       ",
		" pgt.pgtmat, 		 ",
		" iss.funnom		  ",
		" from                    ",
		" dbsmopg opg,            ",
		" datmservico srv,        ",
		" dbscadtippgt pgt,           ",
		" datmligacao lig,        ",
		" dbsmopgitm itm,         ",
		" datksrvtip tip,          ",
                " isskfunc iss		   ",
		" where                   ",
		" opg.socopgnum = itm.socopgnum  ",
		" and	itm.atdsrvnum = srv.atdsrvnum ",
		" and	itm.atdsrvano = srv.atdsrvano  ",
		" and     srv.atdsrvnum = pgt.nrosrv   ",
		" and     srv.atdsrvano = pgt.anosrv   ",
		" and     srv.atdsrvnum = lig.atdsrvnum ",
		" and	srv.atdsrvano = lig.atdsrvano  ",
		" and     srv.atdtip    = tip.atdtip ",
		" and pgt.pgtmat = iss.funmat ",
		" and     opg.soctip = 1 ",
		" and	opg.socfatpgtdat between ? and ? ",
		" and	srv.ciaempcod = 1 ",
		" and opg.socopgsitcod = 7 ",
		" and pgt.pgttipcodps = 1   "
prepare pbdbsr520005 from l_sql
declare cbdbsr520005 cursor for pbdbsr520005

let l_sql = " select  opg.socopgnum,  ",
		" srv.atdsrvnum,          ",
		" srv.atdsrvano,          ",
		" ntz.socntzdes,          ",
		" lig.c24solnom,          ",    
		" lig.lignum,             ",
		" srv.atddat,             ",
		" opg.socfatpgtdat,	  ",
		" itm.socopgitmvlr,       ",
		" pgt.pgtmat, 		 ",
		" iss.funnom             ",
		" from                    ",
		" dbsmopg opg,            ",
		" datmservico srv,        ",
		" dbscadtippgt pgt,           ",
		" datmligacao lig,        ",
		" dbsmopgitm itm,         ",
		" datmsrvre re,      ",
	        " datksocntz ntz,     ",
		" isskfunc iss		   ",
		" where                   ",
		" opg.socopgnum = itm.socopgnum  ",
		" and	itm.atdsrvnum = srv.atdsrvnum ",
		" and	itm.atdsrvano = srv.atdsrvano  ",
		" and   srv.atdsrvnum = pgt.nrosrv   ",
		" and   srv.atdsrvano = pgt.anosrv   ",
		" and   srv.atdsrvnum = lig.atdsrvnum ",
		" and	srv.atdsrvano = lig.atdsrvano  ",
		" and     srv.atdsrvnum     = re.atdsrvnum      ",
		" and     srv.atdsrvano = re.atdsrvano ",
		" and     re.socntzcod = ntz.socntzcod ",
		" and   pgt.pgtmat = iss.funmat ",
		" and   opg.soctip = 3 ",
		" and	opg.socfatpgtdat between ? and ? ",
		" and	srv.ciaempcod = 1 ",
		" and   opg.socopgsitcod = 7 ",
		" and   pgt.pgttipcodps = 1   "
prepare pbdbsr520006 from l_sql
declare cbdbsr520006 cursor for pbdbsr520006

let l_sql = " select  opg.socopgnum,  ",
		" srv.atdsrvnum,          ",
		" srv.atdsrvano,          ",
		" tip.srvtipdes,          ",
		" lig.c24solnom,          ",
		" lig.lignum,             ",
		" srv.atddat,             ",
		" opg.socfatpgtdat,	  ",
		" itm.socopgitmvlr,       ",
		" pgt.corsus, 		 ",
		" sus.cornom           ",
		" from                    ",
		" dbsmopg opg,            ",
		" datmservico srv,        ",
		" dbscadtippgt pgt,           ",
		" datmligacao lig,        ",
		" dbsmopgitm itm,         ",
		" datksrvtip tip,          ",
		" gcaksusep ep,		   ",
		" gcakcorr sus		   ",
		" where                   ",
		" opg.socopgnum = itm.socopgnum  ",
		" and	itm.atdsrvnum = srv.atdsrvnum ",
		" and	itm.atdsrvano = srv.atdsrvano  ",
		" and   srv.atdsrvnum = pgt.nrosrv   ",
		" and   srv.atdsrvano = pgt.anosrv   ",
		" and   srv.atdsrvnum = lig.atdsrvnum ",
		" and	srv.atdsrvano = lig.atdsrvano  ",
		" and srv.atdtip = tip.atdtip ",
		" and   pgt.corsus = ep.corsus ",
		" and   ep.corsuspcp = sus.corsuspcp ",
		" and   opg.soctip = 1 ",
		" and	opg.socfatpgtdat between ? and ? ",
		" and	srv.ciaempcod = 1 ",
		" and   opg.socopgsitcod = 7 ",
		" and   pgt.pgttipcodps = 2   "
prepare pbdbsr520007 from l_sql
declare cbdbsr520007 cursor for pbdbsr520007


let l_sql = " select  opg.socopgnum,  ",
		" srv.atdsrvnum,          ",
		" srv.atdsrvano,          ",
		" ntz.socntzdes,          ",
		" lig.c24solnom,          ",
		" lig.lignum,             ",
		" srv.atddat,             ",
		" opg.socfatpgtdat,	  ",
		" itm.socopgitmvlr,       ",
		" pgt.corsus, 		 ",
		" sus.cornom           ",
		" from                    ",
		" dbsmopg opg,            ",
		" datmservico srv,        ",
		" dbscadtippgt pgt,           ",
		" datmligacao lig,        ",
		" dbsmopgitm itm,         ",
		" datmsrvre re,      ",
	        " datksocntz ntz,     ",
		" gcaksusep ep,		   ",
		" gcakcorr sus		   ",
		" where                   ",
		" opg.socopgnum = itm.socopgnum  ",
		" and	itm.atdsrvnum = srv.atdsrvnum ",
		" and	itm.atdsrvano = srv.atdsrvano  ",
		" and   srv.atdsrvnum = pgt.nrosrv   ",
		" and   srv.atdsrvano = pgt.anosrv   ",
		" and   srv.atdsrvnum = lig.atdsrvnum ",
		" and	srv.atdsrvano = lig.atdsrvano  ",
		" and     srv.atdsrvnum     = re.atdsrvnum      ",
		" and     srv.atdsrvano = re.atdsrvano ",
		" and     re.socntzcod = ntz.socntzcod ",
		" and   pgt.corsus = ep.corsus ",
		" and   ep.corsuspcp = sus.corsuspcp ",
		" and   opg.soctip = 3 ",
		" and	opg.socfatpgtdat between ? and ? ",
		" and	srv.ciaempcod = 1 ",
		" and   opg.socopgsitcod = 7 ",
		" and   pgt.pgttipcodps = 2   "
prepare pbdbsr520008 from l_sql
declare cbdbsr520008 cursor for pbdbsr520008

 end function



#------------------------------------------------------
 function bdbsr520_periodoextracao()
#------------------------------------------------------
     let m_datparam  = arg_val(1)

     if m_datparam is null  or
        m_datparam =  "  "  then
        let m_datparam = today
     else
        if length(m_datparam) < 10  then
           display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
           exit program
        end if
     end if

     if  month(m_datparam) = 01 then
        let ws_datade = mdy(12,01,year(m_datparam) - 1)
        let ws_dataate    = mdy(12,31,year(m_datparam) - 1)

    else
        let ws_datade = mdy(month(m_datparam) - 1,01,year(m_datparam))
        let ws_dataate    = mdy(month(m_datparam),01,year(m_datparam)) - 1 units day
    end if

    display "De ",ws_datade
    display "Ate ",ws_dataate

 end function ## funcao relat_periodoextracao

#------------------------------------------------------
 function bdbsr520_gerarelatorioauto()
#------------------------------------------------------
 define l_assunto char(100)
 define l_mes_extenso char(010)
 define l_dataarq char(8)
 define l_data    date
 
 let l_data = today
 display "l_data: ", l_data
 let l_dataarq = extend(l_data, year to year),
                 extend(l_data, month to month),
                 extend(l_data, day to day)
 display "l_dataarq: ", l_dataarq

 initialize m_bdbsr520 to null

 let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path_txt = m_path clipped, "/BDBSR520auto_", l_dataarq, ".txt"   
    let m_path     = m_path clipped, "/BDBSR520auto.xls"

    let m_mes_int = month(ws_datade)

 case m_mes_int
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case


   let l_assunto = "Servicos Debitados em Centro de Custo ", l_mes_extenso clipped, " /AUTO"

 open cbdbsr520001 using ws_datade, ws_dataate
 start report rel_bdbsr52001 to m_path
 start report rel_bdbsr52001_txt to m_path_txt #--> RELTXT

 foreach cbdbsr520001 into m_bdbsr520.socopgnum   ,
                        m_bdbsr520.atdsrvnum   ,
                        m_bdbsr520.atdsrvano   ,
                        m_bdbsr520.srvtipdes   ,
                        m_bdbsr520.c24solnom   ,
                        m_bdbsr520.lignum      ,
                        m_bdbsr520.atddat      ,
                        m_bdbsr520.socfatpgtdat,
                        m_bdbsr520.socopgitmvlr,
                        m_bdbsr520.cctcod

       if m_bdbsr520.cctcod is not null and m_bdbsr520.cctcod <> 0 then
     			let l_param.empcod    = 1
        		let l_param.succod    = 1
        		let l_param.cctlclcod = (m_bdbsr520.cctcod / 10000)
        		let l_param.cctdptcod = (m_bdbsr520.cctcod mod 10000)
        		call fctgc102_vld_dep(l_param.*) returning lr_ret.*
        		if lr_ret.erro <> 0 then
	           		error "Nome do CENTRO DE CUSTO nao encontrado !!!"
        		end if
        		let m_bdbsr520.cctdptnom = lr_ret.cctdptnom
	end if

       open cbdbsr520004 using  m_bdbsr520.atdsrvnum   ,
                        m_bdbsr520.atdsrvano
       fetch cbdbsr520004 into m_bdbsr520.aplnumdig   ,
                        m_bdbsr520.succod

       close cbdbsr520004

       output to report rel_bdbsr52001()
       output to report rel_bdbsr52001_txt() #--> RELTXT

 end foreach

close cbdbsr520001

initialize m_bdbsr520 to null

open cbdbsr520005 using ws_datade, ws_dataate
foreach cbdbsr520005 into  m_bdbsr520.socopgnum   ,
                       		m_bdbsr520.atdsrvnum   ,
                       		m_bdbsr520.atdsrvano   ,
                       		m_bdbsr520.srvtipdes   ,
                       		m_bdbsr520.c24solnom   ,
                       		m_bdbsr520.lignum      ,
                       		m_bdbsr520.atddat      ,
                       		m_bdbsr520.socfatpgtdat,
                       		m_bdbsr520.socopgitmvlr,
                       		m_bdbsr520.pgtmat,
               		        m_bdbsr520.funnom

       	output to report rel_bdbsr52001()
       	output to report rel_bdbsr52001_txt() #--> RELTXT
end foreach
close cbdbsr520005

initialize m_bdbsr520 to null

open cbdbsr520007 using ws_datade, ws_dataate
foreach cbdbsr520007 into  m_bdbsr520.socopgnum   ,
                       		m_bdbsr520.atdsrvnum   ,
                       		m_bdbsr520.atdsrvano   ,
                       		m_bdbsr520.srvtipdes   ,
                       		m_bdbsr520.c24solnom   ,
                       		m_bdbsr520.lignum      ,
                       		m_bdbsr520.atddat      ,
                       		m_bdbsr520.socfatpgtdat,
                       		m_bdbsr520.socopgitmvlr,
                       		m_bdbsr520.corsus,
               		        m_bdbsr520.cornom

       	output to report rel_bdbsr52001()
       	output to report rel_bdbsr52001_txt() #--> RELTXT
end foreach
close cbdbsr520007

finish report rel_bdbsr52001
finish report rel_bdbsr52001_txt #--> RELTXT

call bdbsr520_enviaemail(l_assunto)


 end function ## final relat_gerarelatorioauto()

#------------------------------------------------------
 function bdbsr520_gerarelatoriore()
#------------------------------------------------------

 define l_assunto char(100)
 define l_mes_extenso char(010)
 define l_dataarq char(8)
 define l_data    date
 
 let l_data = today
 display "l_data: ", l_data
 let l_dataarq = extend(l_data, year to year),
                 extend(l_data, month to month),
                 extend(l_data, day to day)
 display "l_dataarq: ", l_dataarq

 initialize m_bdbsr520 to null

     let m_path = null

     # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_path_txt = m_path clipped, "/BDBSR520re_", l_dataarq, ".txt"  
    let m_path     = m_path clipped, "/BDBSR520re.xls"

    let m_mes_int = month(ws_datade)

    case m_mes_int
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case


   let l_assunto = "Servicos Debitados em Centro de Custo ", l_mes_extenso clipped, " /RE"


 open cbdbsr520002  using  ws_datade, ws_dataate
 start report rel_bdbsr52002 to m_path
 start report rel_bdbsr52002_txt to m_path_txt #--> RELTXT

 foreach cbdbsr520002 into m_bdbsr520.socopgnum   ,
                        m_bdbsr520.atdsrvnum   ,
                        m_bdbsr520.atdsrvano   ,
                        m_bdbsr520.socntzdes   ,
                        m_bdbsr520.c24solnom   ,  
                        m_bdbsr520.lignum      ,
                        m_bdbsr520.atddat      ,
                        m_bdbsr520.socfatpgtdat,
                        m_bdbsr520.socopgitmvlr,
                        m_bdbsr520.cctcod

      if m_bdbsr520.cctcod is not null and m_bdbsr520.cctcod <> 0 then
     			let l_param.empcod    = 1
        		let l_param.succod    = 1
        		let l_param.cctlclcod = (m_bdbsr520.cctcod / 10000)
        		let l_param.cctdptcod = (m_bdbsr520.cctcod mod 10000)
        		call fctgc102_vld_dep(l_param.*) returning lr_ret.*
        		if lr_ret.erro <> 0 then
	           		error "Nome do CENTRO DE CUSTO nao encontrado !!!"
        		end if
        		let m_bdbsr520.cctdptnom = lr_ret.cctdptnom
	end if



       open cbdbsr520004 using  m_bdbsr520.atdsrvnum   ,
                         m_bdbsr520.atdsrvano
       fetch cbdbsr520004 into m_bdbsr520.aplnumdig   ,
                        m_bdbsr520.succod

	close cbdbsr520004

     output to report rel_bdbsr52002()
     output to report rel_bdbsr52002_txt() #--> RELTXT

 end foreach
close cbdbsr520002

initialize m_bdbsr520 to null

open cbdbsr520006 using ws_datade, ws_dataate
foreach  cbdbsr520006 into  m_bdbsr520.socopgnum   ,
                       		m_bdbsr520.atdsrvnum   ,
                       		m_bdbsr520.atdsrvano   ,
                       		m_bdbsr520.socntzdes   ,
                       		m_bdbsr520.c24solnom   ,
                       		m_bdbsr520.lignum      ,
                       		m_bdbsr520.atddat      ,
                       		m_bdbsr520.socfatpgtdat,
                       		m_bdbsr520.socopgitmvlr,
                       		m_bdbsr520.pgtmat,
                       		m_bdbsr520.funnom

       	output to report rel_bdbsr52002()
       	output to report rel_bdbsr52002_txt() #--> RELTXT
end foreach
close cbdbsr520006

initialize m_bdbsr520 to null

open cbdbsr520008 using ws_datade, ws_dataate
foreach  cbdbsr520008 into  m_bdbsr520.socopgnum   ,
                       		m_bdbsr520.atdsrvnum   ,
                       		m_bdbsr520.atdsrvano   ,
                       		m_bdbsr520.socntzdes   ,
                       		m_bdbsr520.c24solnom   ,
                       		m_bdbsr520.lignum      ,
                       		m_bdbsr520.atddat      ,
                       		m_bdbsr520.socfatpgtdat,
                       		m_bdbsr520.socopgitmvlr,
                       		m_bdbsr520.corsus,
                       		m_bdbsr520.cornom

       	output to report rel_bdbsr52002()
       	output to report rel_bdbsr52002_txt() #--> RELTXT
end foreach
close cbdbsr520008


 finish report rel_bdbsr52002
 finish report rel_bdbsr52002_txt #--> RELTXT

call bdbsr520_enviaemail(l_assunto)

 end function ## final relat_gerarelatoriore()
#------------------------------------------------------
 function bdbsr520_enviaemail(l_param)
#------------------------------------------------------

define l_param record
	assunto char(100)
end record

 # E-MAIL PORTO SOCORRO
 define l_erro_envio integer
 define l_comando     char(200)


   let l_comando = "gzip -f ", m_path

   run l_comando

   let m_path = m_path clipped, ".gz"


   let l_erro_envio = ctx22g00_envia_email("BDBSR520", l_param.assunto, m_path)

    if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display " Erro ao enviar email(ctx22g00)-", l_erro_envio
       else
          display " Email nao encontrado para este modulo BDBSR520 "
       end if
    end if

 end function
#------------------------------------------------------
 report rel_bdbsr52001()
#------------------------------------------------------
define l_socfatpgtdat,
 	l_atddat char(10)
 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  80

 format

  page header
       print column 001, "Ordem de pagamento"      ,ascii(09),
                        "Numero do Servico"       , ascii(09),
                        "Ano do Servico",ascii(09),
                        "Tipo de Servico", ascii(09),
                        "Apolice",ascii(09),
                        "Sucursal ",ascii(09),
                        "Centro de Custo",ascii(09),
                        "Departamento",ascii(09),
                        "Solicitante",ascii(09),
                        "Data do Servico",ascii(09),
                        "Data de Pagamento", ascii(09),
                        "Valor", ascii(09),
                        "Matricula", ascii(09),
                        "Nome Funcionario", ascii(09),
                        "Susep", ascii(09),
                        "Corretor", ascii(09)

  on every row

	                          
        print column 001, m_bdbsr520.socopgnum   ,ascii(09),
                         m_bdbsr520.atdsrvnum   ,ascii(09),
                         m_bdbsr520.atdsrvano   ,ascii(09),
                         m_bdbsr520.srvtipdes   ,ascii(09);

                         if m_bdbsr520.aplnumdig is null or m_bdbsr520.aplnumdig = 0 then
                         	print "APOLICE NAO CADASTRADA"  ,ascii(09);
                         else
                         	print m_bdbsr520.aplnumdig, ascii(09);
                         end if

                         if m_bdbsr520.succod is null or m_bdbsr520.succod = 0 then
                         	print "SUCURSAL NAO ENCONTRADA", ascii(09);
                         else
                         	print m_bdbsr520.succod      ,ascii(09);
                         end if

                         if m_bdbsr520.cctcod is null or m_bdbsr520.cctcod = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctcod, ascii(09);
                         end if

                         if m_bdbsr520.cctdptnom is null or m_bdbsr520.cctdptnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctdptnom, ascii(09);
                         end if

			 let l_atddat = extend(m_bdbsr520.atddat , year to year), "-",            # PSI 229555
	                                extend(m_bdbsr520.atddat , month to month), "-",          #
	                                extend(m_bdbsr520.atddat , day to day)                    #
 			                                                                          #
 			 let l_socfatpgtdat = extend(m_bdbsr520.socfatpgtdat , year to year), "-",#
	                                extend(m_bdbsr520.socfatpgtdat , month to month), "-",    #
	                                extend(m_bdbsr520.socfatpgtdat , day to day)              #
			
                         print  m_bdbsr520.c24solnom   ,ascii(09),
                         l_atddat     ,ascii(09),
                         l_socfatpgtdat, ascii(09),
                         
                         m_bdbsr520.socopgitmvlr using "---------&,&&", ascii(09);

                         if m_bdbsr520.pgtmat is null or m_bdbsr520.pgtmat = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.pgtmat, ascii(09);
                         end if

                         if m_bdbsr520.funnom is null or m_bdbsr520.funnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.funnom, ascii(09);
                         end if

                         if m_bdbsr520.corsus is null or m_bdbsr520.corsus = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.corsus, ascii(09);
                         end if

                         if m_bdbsr520.cornom is null or m_bdbsr520.cornom = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.cornom, ascii(09);
                         end if

                     skip 1 line


end report ##final report rel_relat01

#------------------------------------------------------
 report rel_bdbsr52001_txt() #--> RELTXT
#------------------------------------------------------
define l_socfatpgtdat,
 	l_atddat char(10)
 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

  on every row
	                          
        print column 001, m_bdbsr520.socopgnum   ,ascii(09),
                         m_bdbsr520.atdsrvnum   ,ascii(09),
                         m_bdbsr520.atdsrvano   ,ascii(09),
                         m_bdbsr520.srvtipdes   ,ascii(09);

                         if m_bdbsr520.aplnumdig is null or m_bdbsr520.aplnumdig = 0 then
                         	print "APOLICE NAO CADASTRADA"  ,ascii(09);
                         else
                         	print m_bdbsr520.aplnumdig, ascii(09);
                         end if

                         if m_bdbsr520.succod is null or m_bdbsr520.succod = 0 then
                         	print "SUCURSAL NAO ENCONTRADA", ascii(09);
                         else
                         	print m_bdbsr520.succod      ,ascii(09);
                         end if

                         if m_bdbsr520.cctcod is null or m_bdbsr520.cctcod = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctcod, ascii(09);
                         end if

                         if m_bdbsr520.cctdptnom is null or m_bdbsr520.cctdptnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctdptnom, ascii(09);
                         end if

			 let l_atddat = extend(m_bdbsr520.atddat , year to year), "-",            # PSI 229555
	                                extend(m_bdbsr520.atddat , month to month), "-",          #
	                                extend(m_bdbsr520.atddat , day to day)                    #
 			                                                                          #
 			 let l_socfatpgtdat = extend(m_bdbsr520.socfatpgtdat , year to year), "-",#
	                                extend(m_bdbsr520.socfatpgtdat , month to month), "-",    #
	                                extend(m_bdbsr520.socfatpgtdat , day to day)              #
			
                         print  m_bdbsr520.c24solnom   ,ascii(09),
                         l_atddat     ,ascii(09),
                         l_socfatpgtdat, ascii(09),
                         
                         m_bdbsr520.socopgitmvlr using "---------&,&&", ascii(09);

                         if m_bdbsr520.pgtmat is null or m_bdbsr520.pgtmat = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.pgtmat, ascii(09);
                         end if

                         if m_bdbsr520.funnom is null or m_bdbsr520.funnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.funnom, ascii(09);
                         end if

                         if m_bdbsr520.corsus is null or m_bdbsr520.corsus = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.corsus, ascii(09);
                         end if

                         if m_bdbsr520.cornom is null or m_bdbsr520.cornom = 0 then
                         	print " ", ASCII(09);
                         else
                         	print  m_bdbsr520.cornom, ASCII(09);
                         end if
                         
                         print m_bdbsr520.lignum, ASCII(09)




end report ##final report rel_relat01_txt

#------------------------------------------------------
 report rel_bdbsr52002()
#------------------------------------------------------
define l_socfatpgtdat,
 	l_atddat char(10)
 	
 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  80

 format

  page header
       print column 001, "Ordem de pagamento",ascii(09),
                        "Numero do Servico", ascii(09),
                        "Ano do Servico",ascii(09),
                        "Natureza", ascii(09),
                        "Apolice",ascii(09),
                        "Sucursal ",ascii(09),
                        "Centro de Custo",ascii(09),
                        "Departamento",ascii(09),
                        "Solicitante",ascii(09),
                        "Data do Servico",ascii(09),
                        "Data de Pagamento", ascii(09),
                        "Valor", ascii(09),
                        "Matricula", ascii(09),
                        "Nome Funcionario", ascii(09),
                        "Susep", ascii(09),
                        "Corretor", ascii(09)
  on every row
       print column 001, m_bdbsr520.socopgnum   ,ascii(09),
                         m_bdbsr520.atdsrvnum   ,ascii(09),
                         m_bdbsr520.atdsrvano   ,ascii(09),
                         m_bdbsr520.socntzdes   ,ascii(09);

                         if m_bdbsr520.aplnumdig is null or m_bdbsr520.aplnumdig = 0 then
                         	print "APOLICE NAO CADASTRADA"  ,ascii(09);
                         else
                         	print m_bdbsr520.aplnumdig, ascii(09);
                         end if

                         if m_bdbsr520.succod is null or m_bdbsr520.succod = 0 then
                         	print "SUCURSAL NAO ENCONTRADA", ascii(09);
                         else
                         	print m_bdbsr520.succod      ,ascii(09);
                         end if

                         if m_bdbsr520.cctcod is null or m_bdbsr520.cctcod = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctcod, ascii(09);
                         end if

                         if m_bdbsr520.cctdptnom is null or m_bdbsr520.cctdptnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctdptnom, ascii(09);
                         end if
                         
                         let l_atddat = extend(m_bdbsr520.atddat , year to year), "-",            # PSI 229555               
			                extend(m_bdbsr520.atddat , month to month), "-",          #                          
			                extend(m_bdbsr520.atddat , day to day)                    #                          
			                                                                          #                          
			 let l_socfatpgtdat = extend(m_bdbsr520.socfatpgtdat , year to year), "-",#                          
			                extend(m_bdbsr520.socfatpgtdat , month to month), "-",    #                          
			                extend(m_bdbsr520.socfatpgtdat , day to day)              #                          

                         
                         print  m_bdbsr520.c24solnom   ,ascii(09),
                         l_atddat    ,ascii(09),
                         l_socfatpgtdat, ascii(09),
                         m_bdbsr520.socopgitmvlr using "---------&,&&", ascii(09);
                         
                         if m_bdbsr520.pgtmat is null or m_bdbsr520.pgtmat = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.pgtmat, ascii(09);
                         end if

                         if m_bdbsr520.funnom is null or m_bdbsr520.funnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.funnom, ascii(09);
                         end if

                          if m_bdbsr520.corsus is null or m_bdbsr520.corsus = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.corsus, ascii(09);
                         end if

                         if m_bdbsr520.cornom is null or m_bdbsr520.cornom = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.cornom, ascii(09);
                         end if

skip 1 line

end report ##final report rel_relat02

#------------------------------------------------------
 report rel_bdbsr52002_txt()
#------------------------------------------------------
define l_socfatpgtdat,
 	l_atddat char(10)
 	
 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 format

  on every row
       print column 001, m_bdbsr520.socopgnum   ,ascii(09),
                         m_bdbsr520.atdsrvnum   ,ascii(09),
                         m_bdbsr520.atdsrvano   ,ascii(09),
                         m_bdbsr520.socntzdes   ,ascii(09);

                         if m_bdbsr520.aplnumdig is null or m_bdbsr520.aplnumdig = 0 then
                         	print "APOLICE NAO CADASTRADA"  ,ascii(09);
                         else
                         	print m_bdbsr520.aplnumdig, ascii(09);
                         end if

                         if m_bdbsr520.succod is null or m_bdbsr520.succod = 0 then
                         	print "SUCURSAL NAO ENCONTRADA", ascii(09);
                         else
                         	print m_bdbsr520.succod      ,ascii(09);
                         end if

                         if m_bdbsr520.cctcod is null or m_bdbsr520.cctcod = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctcod, ascii(09);
                         end if

                         if m_bdbsr520.cctdptnom is null or m_bdbsr520.cctdptnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.cctdptnom, ascii(09);
                         end if
                         
                         let l_atddat = extend(m_bdbsr520.atddat , year to year), "-",            # PSI 229555               
			                extend(m_bdbsr520.atddat , month to month), "-",          #                          
			                extend(m_bdbsr520.atddat , day to day)                    #                          
			                                                                          #                          
			 let l_socfatpgtdat = extend(m_bdbsr520.socfatpgtdat , year to year), "-",#                          
			                extend(m_bdbsr520.socfatpgtdat , month to month), "-",    #                          
			                extend(m_bdbsr520.socfatpgtdat , day to day)              #                          

                         
                         print  m_bdbsr520.c24solnom   ,ascii(09),
                         l_atddat    ,ascii(09),
                         l_socfatpgtdat, ascii(09),
                         m_bdbsr520.socopgitmvlr using "---------&,&&", ascii(09);
                         
                         if m_bdbsr520.pgtmat is null or m_bdbsr520.pgtmat = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.pgtmat, ascii(09);
                         end if

                         if m_bdbsr520.funnom is null or m_bdbsr520.funnom = 0 then
                         	print " ", ascii(09);
                         else
                         	print m_bdbsr520.funnom, ascii(09);
                         end if

                          if m_bdbsr520.corsus is null or m_bdbsr520.corsus = 0 then
                         	print " ", ascii(09);
                         else
                         	print  m_bdbsr520.corsus, ascii(09);
                         end if

                         if m_bdbsr520.cornom is null or m_bdbsr520.cornom = 0 then
                         	print " ", ASCII(09);
                         else
                         	print  m_bdbsr520.cornom, ASCII(09);
                         end if
                         
                         print m_bdbsr520.lignum, ASCII(09)



end report ##final report rel_relat02_txt
