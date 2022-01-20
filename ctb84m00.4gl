############################################################################
# Nome de Modulo: CTB84M00                                                 #
#                                                                          #
# Exibe totais da OP por Centro de Custo                          Mai/2007 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO RESPONSAVEL    DESCRICAO                         #
#--------------------------------------------------------------------------#
#--------------------------------------------------------------------------#
############################################################################


database porto

##---------------------------0000000----------------------------->
function ctb84m00_prepare()
##---------------------------0000000----------------------------->
 define l_sql char(1000)
 let l_sql = "select srv.ciaempcod,               ",
             "        srv.atdsrvorg,                    ",
             "        srv.atdsrvnum,                    ",
             "        srv.atdsrvano,                    ",
             "        pgt.cctcod,                       ",
             "        itm.socopgitmvlr                  ",
             "from   datmservico srv,                   ",
             "        dbsmopgitm itm,                   ",
             "        dbsmopg opg,                      ",
             "        dbscadtippgt pgt                  ",
             "where   opg.socopgnum = itm.socopgnum     ",
             "and     itm.atdsrvnum = srv.atdsrvnum     ",
             "and     itm.atdsrvano = srv.atdsrvano     ",
             "and     srv.atdsrvnum = pgt.nrosrv        ",
             "and     srv.atdsrvano = pgt.anosrv        ",
             "and     opg.socopgnum = ?                 ",
             "and     pgt.pgttipcodps = 3               ",
             "and     opg.soctip = ?                    "

  prepare pctb84m001 from l_sql
  declare cctb84m001 cursor for pctb84m001

  let l_sql = "select apol.succod                      ",
             "from   datmservico srv,                   ",
             "        datrservapol apol,                ",
             "        dbsmopgitm itm,                   ",
             "        dbsmopg opg			",
             "where   opg.socopgnum = itm.socopgnum     ",
             "and     itm.atdsrvnum = srv.atdsrvnum     ",
             "and     itm.atdsrvano = srv.atdsrvano     ",
             "and     srv.atdsrvnum = apol.atdsrvnum    ",
             "and     srv.atdsrvano = apol.atdsrvano    ",
             "and     opg.socopgnum = ?                 ",
             "and     opg.soctip = ?                    "

  prepare pctb84m002 from l_sql
  declare cctb84m002 cursor for pctb84m002

  let l_sql = "select srv.ciaempcod,               ",
             "        srv.atdsrvorg,                    ",
             "        srv.atdsrvnum,                    ",
             "        srv.atdsrvano,                    ",
             "        rat.cctcod,                       ",
             "        itm.socopgitmvlr                  ",
             "from   datmservico srv,                   ",
             "        dbsmopgitm itm,                   ",
             "        dbsmopg opg,                      ",
             "        dbsmcctrat rat                   ",
             "where   opg.socopgnum = itm.socopgnum     ",
             "and     itm.atdsrvnum = srv.atdsrvnum     ",
             "and     itm.atdsrvano = srv.atdsrvano     ",
             "and     srv.atdsrvnum = rat.atdsrvnum     ",
             "and     srv.atdsrvano = rat.atdsrvano     ",
             "and     opg.socopgnum = ?                 ",
             "and     opg.soctip = ?                    "

  prepare pctb84m003 from l_sql
  declare cctb84m003 cursor for pctb84m003

  let l_sql = "select apol.succod                      ",
             "from   datmservico srv,                   ",
             "        datrservapol apol,                ",
             "        dbsmopgitm itm,                   ",
             "        dbsmopg opg                      ",
             "where   opg.socopgnum = itm.socopgnum     ",
             "and     itm.atdsrvnum = srv.atdsrvnum     ",
             "and     itm.atdsrvano = srv.atdsrvano     ",
             "and     srv.atdsrvnum = apol.atdsrvnum    ",
             "and     srv.atdsrvano = apol.atdsrvano    ",
             "and     opg.socopgnum = ?                 ",
             "and     opg.soctip = ?                    "
  prepare pctb84m004 from l_sql
  declare cctb84m004 cursor for pctb84m004


  let l_sql = "select nrosrv from dbscadtippgt pgt, ",
  	      " dbsmopgitm itm, ",
  	      " dbsmopg opg ",
  	      " where opg.socopgnum = itm.socopgnum ",
  	      " and itm.atdsrvnum = pgt.nrosrv ",
  	      " and itm.atdsrvano = pgt.anosrv ",
  	      " and pgt.pgttipcodps = 3 ",
  	      " and opg.socopgnum = ? "
  prepare pctb84m005 from l_sql
  declare cctb84m005 cursor for pctb84m005

#IDENTIFICANDO O CENTRO DE CUSTO
    let l_sql = "select cctdptnom from ctgkdpt where cctdptcod = ? "
    prepare pctb83m006 from l_sql
    declare cctb83m006 cursor for pctb83m006


  end function

##---------------------------0000000----------------------------->
function ctb84m00(param,param_soctip)
##---------------------------0000000----------------------------->
 define param record
     socopgnum like dbsmopg.socopgnum
 end record
 define param_soctip smallint

 define a_ctb84m00 array[50] of record
     ciaempcod        like datmservico.ciaempcod,
     succod           like datrservapol.succod,
     atdsrvorg        like datmservico.atdsrvorg,
     atdsrvnum        like datmservico.atdsrvnum,
     atdsrvano        like datmservico.atdsrvano,
     cctcod           like dbscadtippgt.cctcod,
     cctnom           like ctokcentrosuc.cctnom,
     socopgitmvlr     like dbsmopgitm.socopgitmvlr
 end record

 define ws record
 	atdsrvnum like dbscadtippgt.nrosrv
 end record



 #Variaveis para buscar o nome do centro de custo
 define lr_param     record
        empcod       like ctgklcl.empcod,          -- Empresa
        succod       like ctgklcl.succod,          -- Sucursal
        cctlclcod    like ctgklcl.cctlclcod,       -- Local
        cctdptcod    like ctgrlcldpt.cctdptcod     -- Departamento
 end record

 define lr_ret record
        erro         smallint,                     -- 0-Ok 1-erro
        mens         char(40),
        cctlclnom    like ctgklcl.cctlclnom,       -- Nome do local
        cctdptnom    like ctgkdpt.cctdptnom,       -- Nome depto (antigo cctnom)
        cctdptrspnom like ctgrlcldpt.cctdptrspnom, -- Responsavel pelo depto
        cctdptlclsit like ctgrlcldpt.cctdptlclsit, -- Sit depto (A)tivo (I)nativo
        cctdpttip    like ctgkdpt.cctdpttip        -- Tipo de departamento
 end record
--

 define arr_aux smallint

 initialize a_ctb84m00 to null

 call ctb84m00_prepare()

 open window w_ctb84m00 at 5,2 with form "ctb84m00" attribute(border)

     let arr_aux = 1

       	open cctb84m003 using param.socopgnum,param_soctip
	foreach cctb84m003 into a_ctb84m00[arr_aux].ciaempcod,
                      		a_ctb84m00[arr_aux].atdsrvorg,
                             	a_ctb84m00[arr_aux].atdsrvnum,
                             	a_ctb84m00[arr_aux].atdsrvano,
                             	a_ctb84m00[arr_aux].cctcod,
                             	a_ctb84m00[arr_aux].socopgitmvlr

   	open cctb84m004 using param.socopgnum,param_soctip
        fetch cctb84m004 into a_ctb84m00[arr_aux].succod
        close cctb84m004

        let lr_param.empcod    = a_ctb84m00[arr_aux].ciaempcod
        let lr_param.succod    = a_ctb84m00[arr_aux].succod
        let lr_param.cctlclcod = (a_ctb84m00[arr_aux].cctcod / 10000)
        let lr_param.cctdptcod = (a_ctb84m00[arr_aux].cctcod mod 10000)


        call fctgc102_vld_dep(lr_param.*)
        returning lr_ret.*
        if lr_ret.erro <> 0 then
        	open cctb83m006 using lr_param.cctdptcod
            	fetch cctb83m006 into lr_ret.cctdptnom
            	close cctb83m006
            	if lr_ret.cctdptnom is null or lr_ret.cctdptnom = "" then
            		error "Nome do Centro de Custo nao Encontrado"
	               	let lr_ret.cctdptnom = " "
               	end if
        end if

        let a_ctb84m00[arr_aux].cctnom = lr_ret.cctdptnom

        let arr_aux = arr_aux + 1
	if arr_aux > 50 then
        	exit foreach
        end if
     	end foreach
     	close cctb84m003

        call set_count(arr_aux -1)
        display array a_ctb84m00 to s_ctb84m00.*
        on key (interrupt,control-c)
              exit display
              end display
  close window w_ctb84m00

end function

