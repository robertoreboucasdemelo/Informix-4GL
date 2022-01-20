################################################################################
# Nome do Modulo: CTB83M00                                             	       #
#                                                                              #
# Cadastro de Tipos de Pagamento	                         Jul/2007      #
################################################################################
#..............................................................................#
#                                                                              #
#                             * * * Alteracoes * * *                           #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto
define m_r record
       pgttipcodps      like dbscadtippgt.pgttipcodps,
       cpodes           like iddkdominio.cpodes,
       pgtmat           like dbscadtippgt.pgtmat,
       funnom           like isskfunc.funnom,
       corsus           like dbscadtippgt.corsus,
       cornom           like gcakcorr.cornom,
       cctcod           like dbscadtippgt.cctcod,
       cctnom           like ctgkdpt.cctdptnom,
       succod           like gabksuc.succod,
       sucnom           like gabksuc.sucnom,
       caddat           like dbskgstsuc.caddat,
       funcnomeinc      like isskfunc.funnom,
       atldat           like dbskgstsuc.atldat,
       funcnomeatl      like isskfunc.funnom,
       pgtempcod	    like dbscadtippgt.pgtempcod,
       empnom	        like gabkemp.empnom
end record

define m_anosrv         like  dbscadtippgt.anosrv,
       m_nrosrv         like  dbscadtippgt.nrosrv,
       m_cademp         like  dbscadtippgt.cademp,
       m_atlemp         like  dbscadtippgt.atlemp,
       m_cadmat         like  dbscadtippgt.cadmat,
       m_atlmat         like  dbscadtippgt.atlmat,
       m_empcod         like dbscadtippgt.empcod

 define mr_param record
        empcod    like ctgklcl.empcod,
        succod    like ctgklcl.succod,
        cctlclcod like ctgklcl.cctlclcod,
        cctdptcod like ctgrlcldpt.cctdptcod
 end record

 define mr_ret record
        erro          smallint, ## 0-Ok,1-erro
        mens          char(40),
        cctlclnom     like ctgklcl.cctlclnom,       ##Nome do local
        cctdptnom     like ctgkdpt.cctdptnom,       ##Nome do departamento (antigo cctnom)
        cctdptrspnom  like ctgrlcldpt.cctdptrspnom, ##Responsavel pelo  departamento
        cctdptlclsit  like ctgrlcldpt.cctdptlclsit, ##Situagco do depto (A)tivo ou (I)nativo
        cctdpttip     like ctgkdpt.cctdpttip        ##Tipo de departamento
 end record

  define mr_dpt_pop   record
         lin          smallint,
         col          smallint,
         title        char(054),
         col_tit_1    char(012),
         col_tit_2    char(040),
         tipcod       char(001),
         cmd_sql      char(600),
         comp_sql     char(200),
         tipo         char(001)
                     end record

  define m_ret   decimal(3,0)

  ## retorno da funcao cto00m01
   define ret_funnom         like isskfunc.rhmfunnom,
          ret_empcod         like isskfunc.empcod,
          ret_funmat         like isskfunc.funmat

  ## retorno da funcao aggucora
   define ret_corsus       like gcaksusep.corsus,
          ret_cvnnum       like apamcapa.cvnnum,
          ret_cvncptagnnum like akckagn.cvncptagnnum

 ##
    define m_socopgnum    like dbsmopg.socopgnum
    define m_socopgsitcod like dbsmopg.socopgsitcod


##--------------------------------00000000------------------------------>>
 function ctb83m00_prepare()
##--------------------------------00000000------------------------------>>
 define l_sql char(500)
##IDENTIFICANDO O TIPO DE PAGAMENTO
    let l_sql=    "select  cpodes                 ",
                  "from iddkdominio               ",
                  "where cpocod = ?    ",
                  "and cponom = 'pgttipcodps'      "

    prepare p_ctb83m00_001 from l_sql
    declare c_ctb83m00_001 cursor for p_ctb83m00_001

##IDENTIFICANDO O NOME DO FUNCIONARIO
    let l_sql = "select funnom from isskfunc ",
                "where funmat = ? ",
                "and empcod = 1"


    prepare p_ctb83m00_002 from l_sql
    declare c_ctb83m00_002 cursor for p_ctb83m00_002

##IDENTIFICANDO O NOME DO CORRETOR
    let l_sql = "select cornom from gcakcorr,gcaksusep          ",
                "where gcaksusep.corsuspcp = gcakcorr.corsuspcp ",
                " and gcaksusep.corsus = ? "
    prepare p_ctb83m00_003 from l_sql
    declare c_ctb83m00_003 cursor for p_ctb83m00_003


##IDENTIFICANDO O CENTRO DE CUSTO
    let l_sql = "select cctdptnom from ctgkdpt where cctdptcod = ? "
    prepare p_ctb83m00_004 from l_sql
    declare c_ctb83m00_004 cursor for p_ctb83m00_004

-------------------

##IDENTIFICANDO SE O SERVICO ESTÁ RELACIONADO A UMA OP
  let l_sql = " select atdsrvnum, atdsrvano, socopgnum ",
              " from dbsmopgitm ",
              " where atdsrvnum = ? ",
              " and atdsrvano = ? "

  prepare p_ctb83m00_005 from l_sql
  declare c_ctb83m00_005 cursor for p_ctb83m00_005


## PROCURAR DADOS JÁ CADASTRADOS PARA MOSTRAR NA TELA, NA FUNC. DE MODIFICAR

    let l_sql = " select pgttipcodps, pgtmat, corsus, cctcod, caddat, atldat, ",
                " cadmat, atlmat, succod, cademp, pgtempcod",
                " from dbscadtippgt where ",
                " nrosrv = ? ",
                " and anosrv = ? "

    prepare p_ctb83m00_006 from l_sql
    declare c_ctb83m00_006 cursor for p_ctb83m00_006

## ATUALIZA

    let l_sql = "update dbscadtippgt set (anosrv, nrosrv, pgttipcodps, ",
                "pgtmat, corsus, atlmat, atlemp, atldat, ",
                "cctcod, succod, pgtempcod ) = (?,?,?,?,?,?,?,?,?,?,?) ",
                "where anosrv = ? ",
                "and nrosrv = ? " ,
                "and pgttipcodps = ? "
    prepare p_ctb83m00_007 from l_sql

##IDENTIFICANDO A SUCURSAL

     let l_sql =   "select  sucnom  ",
                  "from gabksuc                     ",
                  "where succod = ?      "

    prepare p_ctb83m00_008 from l_sql
    declare c_ctb83m00_007 cursor for p_ctb83m00_008


##INSERINDO TIPO DE PAGAMENTO PARA SERVICO EXISTENTE
   let l_sql = " insert into dbscadtippgt (anosrv,",
   		" nrosrv, ",
   		" pgttipcodps,",
   		" pgtmat, ",
   		" corsus, ",
   		" cadmat, ",
		" cademp,  ",
		" caddat,  ",
		" atlmat,  ",
		" atlemp,  ",
		" atldat,  ",
		" cctcod,  ",
		" empcod,   ",
		" succod,   ",
		" pgtempcod  )",
                " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
   prepare p_ctb83m00_009 from l_sql

##IDENTIFICANDO A EMPRESA

    let l_sql =   "select  empnom  ",
                  "from gabkemp                     ",
                  "where empcod = ?      "

    prepare p_ctb83m00_010 from l_sql
    declare c_ctb83m00_008 cursor for p_ctb83m00_010

##IDENTIFICANDO O NOME DO FUNCIONARIO
    let l_sql = "select funnom from isskfunc ",
                "where funmat = ? ",
                "and empcod = ?"


    prepare p_ctb83m00_011 from l_sql
    declare c_ctb83m00_009 cursor for p_ctb83m00_011

 end function

 --main
 function ctb83m00()
 define l_param smallint
 define l_return smallint
      options prompt line last,
          message line last -1

      initialize m_r to null
--Popup

      initialize mr_dpt_pop to null
      let mr_dpt_pop.lin         = 6
      let mr_dpt_pop.col         = 2
      let mr_dpt_pop.title       = 'Centro de Custo'
      let mr_dpt_pop.col_tit_1   = 'Codigo'
      let mr_dpt_pop.col_tit_2   = 'Descricao'
      let mr_dpt_pop.tipcod      = 'N'
      let mr_dpt_pop.tipo        = 'D'
      let mr_dpt_pop.cmd_sql =  'select distinct a.cctdptcod,b.cctdptnom  '
                               ,'  from ctgrlcldpt a,ctgkdpt b '
                               ,' where a.cctdptcod = b.cctdptcod '
                               ,'   and a.empcod = '
                               ,'   and a.succod = '

--
      #display "O servico na g_documento.atdsrvnum é ", g_documento.atdsrvnum
      call ctb83m00_prepare()

      if g_documento.atdsrvnum is null then
          let l_param = 0
      else
         open c_ctb83m00_006 using g_documento.atdsrvnum, g_documento.atdsrvano
         fetch c_ctb83m00_006 into m_r.pgttipcodps, m_r.pgtmat, m_r.corsus,
                               m_r.cctcod, m_r.caddat, m_r.atldat, m_cadmat, m_atlmat, m_r.succod, m_cademp,
                               m_r.pgtempcod
         close c_ctb83m00_006
         if m_r.pgttipcodps is null or m_r.pgttipcodps = 0 then
         	let l_param = 0
         else
         	let l_param = 1
         end if
      end if


      open window w1 at 06,02 with form 'ctb83m00' attribute(border)
         if l_param = 0 then
             call ctb83m00_inclui()
             returning l_return
         else
             if l_param = 1 then
		 call ctb83m00_modifica()
                 returning l_return
             end if
         end if
         close window w1
         return l_return
 end function
 --end main

##--------------------------------00000000------------------------------>>
 function ctb83m00_inclui()
##--------------------------------00000000------------------------------>>
    define v_resp char(1)
    define l_error char(70)
    define l_return smallint
    define vf_sql char(200)
    define l_status smallint


    initialize m_r to null

    input by name m_r.pgttipcodps, m_r.pgtmat, m_r.corsus, m_r.succod, m_r.cctcod, m_r.pgtempcod
--
        before field pgttipcodps
            clear form
            display m_r.pgttipcodps to pgttipcodps attribute(reverse)
            message "1- Funcionario / 2- Corretor / 3- Centro de Custo"
        after field pgttipcodps
            if m_r.pgttipcodps is null then
                error "Campo nao pode ser nulo !"
                next field pgttipcodps
            end if

            open c_ctb83m00_001 using m_r.pgttipcodps
                fetch c_ctb83m00_001 into m_r.cpodes
            close c_ctb83m00_001
            display m_r.pgttipcodps to pgttipcodps
            display m_r.cpodes to cpodes
            if m_r.pgttipcodps is null then
                error "Campo nao pode ser nulo !"
                next field pgttipcodps
            end if
            if m_r.pgttipcodps = 1 then      ## Se pagamento funcionario
                next field pgtempcod
            else
                if m_r.pgttipcodps = 2 then  ## Se pagamento corretor
                    next field corsus
                else                         ## Se pagamento centro de custo
                    next field pgtempcod
                end if
            end if
            message ""
--
        before field pgtempcod
        	display m_r.pgtempcod to pgtempcod
        	message "Digite a empresa do funcionario que pagara pelo servico"

        after field pgtempcod
            if volta_campo() then
                display m_r.pgtempcod to pgtempcod
                next field pgttipcodps
            end if

            if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
            	error "Campo empresa não pode ser nulo!"
            	call ctb83m02(m_r.pgtempcod) returning m_r.pgtempcod, m_r.empnom

            	#CT 564761
            	if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                    error "Campo empresa não pode ser nulo!"
                next field pgtempcod

            end if

            else
            	open c_ctb83m00_008 using m_r.pgtempcod
            	fetch c_ctb83m00_008 into m_r.empnom
	    end if

            display m_r.pgtempcod to pgtempcod
            display m_r.empnom to empnom
            message ""
            #exit input

            if m_r.pgttipcodps = 1 then
            	next field pgtmat
            else
            	if m_r.pgttipcodps = 3 then
            		next field succod
            	end if
            end if

        before field pgtmat
            #CT 564761
            {if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                error "Campo empresa não pode ser nulo!"
                next field pgtempcod
            end if}
            display m_r.pgtmat to pgtmat attribute(reverse)
            message "Digite a matricula do funcionario que pagara pelo servico"
        after field pgtmat
            if volta_campo() then
                display m_r.pgtmat to pgtmat
                next field pgttipcodps
            end if
            if m_r.pgtmat is null or m_r.pgtmat = 0 then
                error "Campo não pode ser nulo! "
                call cto00m01("")
                    returning ret_empcod,
                              ret_funmat,
                              ret_funnom
                let m_r.pgtempcod = ret_empcod
                let m_r.pgtmat = ret_funmat
                let m_r.funnom = ret_funnom

                #CT 564761
                if m_r.pgtmat is null or m_r.pgtmat = 0 or m_r.pgtmat = " " then
                    error "Campo não pode ser nulo! "
                    next field pgtmat
                end if
            else
            	open c_ctb83m00_009 using m_r.pgtmat, m_r.pgtempcod
                fetch c_ctb83m00_009 into m_r.funnom
                    if sqlca.sqlcode = 100 then
                        error "NAO FOI ENCONTRADO FUNCIONARIO"
                        call cto00m01("")
                            returning ret_empcod,
                                      ret_funmat,
                                      ret_funnom
                        let m_r.pgtempcod = ret_empcod
                        let m_r.pgtmat = ret_funmat
                        let m_r.funnom = ret_funnom
                        next field pgtmat
                    end if
	            close c_ctb83m00_009
	        end if

        	display m_r.pgtempcod to pgtempcod
        	display m_r.pgtmat to pgtmat
            	display m_r.funnom to funnom
            	message ""
	        exit input

--
        before field corsus
            display m_r.corsus to corsus attribute(reverse)
            message "Digite o corsus do corretor"
        after field corsus
            if volta_campo() then
                display m_r.corsus to corsus
                next field pgttipcodps
            end if
            if m_r.corsus is null or m_r.corsus = 0 then
                error "Campo nao pode ser nulo !"
                call aggucora()
                    returning ret_corsus,
                              ret_cvnnum,
                              ret_cvncptagnnum
                    let m_r.corsus = ret_corsus
            end if
            open c_ctb83m00_003 using m_r.corsus
                fetch c_ctb83m00_003 into m_r.cornom
                    if sqlca.sqlcode = 100 then
                        error "NAO FOI ENCONTRADO CORRETOR"
                        call aggucora()
                            returning ret_corsus,
                                      ret_cvnnum,
                                      ret_cvncptagnnum
                            let m_r.corsus = ret_corsus
                            next field corsus
                    end if
            close c_ctb83m00_003
            display m_r.corsus to corsus
            display m_r.cornom to cornom
            message ""
            exit input
--
        before field succod
            #CT 564761
            if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                error "Campo empresa não pode ser nulo!"
                next field pgtempcod
            end if
            display m_r.succod to succod attribute(reverse)
            message "Digite o codigo da sucursal"
        after field succod
            if volta_campo() then
                display m_r.succod to succod
                next field pgttipcodps
            end if
##IDENTIFICANDO A SUCURSAL
           if (m_r.succod is null or m_r.succod = 0) then
               let vf_sql = 'select  distinct(ok.succod), suc.sucnom from ctokcentrosuc ok, gabksuc suc where ok.succod = suc.succod and ok.empcod =', m_r.pgtempcod
               call ofgrc001_popup
                                  (08,
                                   13,
                                   'ESCOLHA A SUCURSAL',
                                   'Codigo',
                                   'Descricao',
                                   'N',
                                   vf_sql,
                                   '',
                                   'D')
               returning l_status,
                         m_r.succod,
                         m_r.sucnom
               if l_status = 1 then
                  next field succod
               end if
           else

#IDENTIFICANDO A SUCURSAL
                 open c_ctb83m00_007 using m_r.succod
                     fetch c_ctb83m00_007 into m_r.sucnom
                        if sqlca.sqlcode = notfound then
                           let vf_sql = 'select  distinct(ok.succod), suc.sucnom from ctokcentrosuc ok, gabksuc suc where ok.succod = suc.succod and ok.succod = ', m_r.succod, ' and ok.empcod =', m_r.pgtempcod
                           Error "Não existe esse código de gestão !!"
                           call ofgrc001_popup
                                           (08,
                                            13,
                                            'ESCOLHA A SUCURSAL',
                                            'Codigo',
                                            'Descricao',
                                            'N',
                                            vf_sql,
                                            '',
                                            'D')
                            returning l_status,
                                      m_r.succod,
                                      m_r.sucnom
                            if l_status = 1 then
                               next field succod
                            end if

                        end if
                     close c_ctb83m00_007
           end if
               display m_r.succod to succod
               display m_r.sucnom to sucnom

        before field cctcod
            display m_r.cctcod to cctcod attribute(reverse)
            message "Digite o número do centro de custo"
        after field cctcod
            if volta_campo() then
                display m_r.cctcod to cctcod
                next field succod
            end if

            if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
            	call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom

            	#CT 564761
            	if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
				    error "Centro de custo não pode ser nulo "
				    next field cctcod
			    end if
	        else
                let mr_param.empcod    = m_r.pgtempcod
            	let mr_param.succod    = m_r.succod
            	let mr_param.cctlclcod = (m_r.cctcod / 10000)
            	let mr_param.cctdptcod = (m_r.cctcod mod 10000)
            	call fctgc102_vld_dep(mr_param.*) returning mr_ret.*

            	#CT 564761
            	if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
				    error "Centro de custo não pode ser nulo "
				    next field cctcod
			    end if

		        if mr_ret.cctdptnom is null or mr_ret.cctdptnom = " " then
			        open  c_ctb83m00_004 using m_r.cctcod
			        fetch c_ctb83m00_004 into  m_r.cctnom
			        close c_ctb83m00_004
			        if m_r.cctnom is null or m_r.cctnom = " " then
				        error "Centro de custo não encontrado "
				        #next field cctcod
				        call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			        end if
			        #CT 564761
			        if m_r.cctcod < 9999 then
			            error "Centro de custo necessita ser especificado "
			            call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			        end if
		        else
                    let m_r.cctnom = mr_ret.cctdptnom
		        end if

        end if

            display m_r.cctcod to cctcod
            display m_r.cctnom to cctnom
            message ""
            exit input
    end input
    if int_flag = true then
        let int_flag=false
        let l_return = 0
    else


## TROCAR PELA S VARIVÁVEIS GLOBAIS
         let m_r.caddat = today
         let m_r.atldat = today
         let m_r.funcnomeinc = g_issk.funnom
         let m_r.funcnomeatl = g_issk.funnom

         let m_anosrv = 07
         let m_nrosrv = 9999
         let m_cademp = g_documento.ciaempcod
         let m_empcod = g_documento.ciaempcod
         let m_atlemp = g_documento.ciaempcod
         let m_cadmat = g_issk.funmat
         let m_atlmat = g_issk.funmat
-------------

##      Não pode inserir nulo na tabela
         if m_r.corsus is null then
             let m_r.corsus = '0'
         end if
         if m_r.pgtmat is null then
             let m_r.pgtmat = 0
         end if
         if m_r.cctcod is null then
             let m_r.cctcod = 0
         end if
         if m_r.succod is null then
         	let m_r.succod = 0
         end if

        display by name  m_r.funcnomeinc,
                         m_r.caddat,
                         m_r.atldat,
                         m_r.funcnomeatl

         while v_resp not matches "[SSssNNnn]" or v_resp is null
             prompt "Confirma? (S/N)" for char v_resp
         end while

         if v_resp matches "[Ss]" then

             if g_documento.atdsrvnum is not null and g_documento.atdsrvnum <> 0 then


	     	execute p_ctb83m00_009 using g_documento.atdsrvano,
				     	 g_documento.atdsrvnum,
	     				 m_r.pgttipcodps,
					 m_r.pgtmat,
					 m_r.corsus,
					 m_cadmat,
					 m_cademp,
					 m_r.caddat,
					 m_atlmat,
					 m_atlemp,
					 m_r.atldat,
					 m_r.cctcod,
					 m_empcod,
					 m_r.succod,
					 m_r.pgtempcod
		if sqlca.sqlcode = 0 then
			display "REGISTRO INSERIDO COM SUCESSO"
		else
			display "ERRO AO INSERIR REGISTRO (pctb83m010)"
		end if
	     else
	     	let g_cc.pgttipcodps  = m_r.pgttipcodps
             	let g_cc.pgtmat       = m_r.pgtmat
             	let g_cc.corsus       = m_r.corsus
             	let g_cc.cadmat       = m_cadmat
             	let g_cc.cademp       = m_cademp
             	let g_cc.caddat       = m_r.caddat
             	let g_cc.atlmat       = m_atlmat
             	let g_cc.atlemp       = m_atlemp
             	let g_cc.atldat       = m_r.atldat
             	let g_cc.cctcod       = m_r.cctcod
             	let g_cc.empcod       = m_empcod
             	let g_cc.succod       = m_r.succod
             	let g_cc.pgtempcod    = m_r.pgtempcod
	     end if

             let l_return = 1


         else
             error "NÃO CONFIRMADO"
             let l_return = 0
             sleep 2
         end if
    end if
    return l_return
 end function

##--------------------------------00000000------------------------------>>
 function ctb83m00_modifica()
##--------------------------------00000000------------------------------>>
    define v_resp char(1)
    define l_error char(70)
    define l_return smallint
    define vf_sql char(200)
    define l_status smallint

    define  l_pgttipcodpsant      like dbscadtippgt.pgttipcodps,
            l_pgtmatant           like dbscadtippgt.pgtmat,
            l_corsusant           like dbscadtippgt.corsus,
            l_cctcodant           like dbscadtippgt.cctcod,
            l_pgtempcodant	  like dbscadtippgt.pgtempcod

    initialize m_r to null
    let l_return = 0


    open c_ctb83m00_006 using g_documento.atdsrvnum,g_documento.atdsrvano
         fetch c_ctb83m00_006 into m_r.pgttipcodps, m_r.pgtmat, m_r.corsus,
                               m_r.cctcod, m_r.caddat, m_r.atldat, m_cadmat, m_atlmat, m_r.succod, m_cademp,
                               m_r.pgtempcod

    open c_ctb83m00_002 using m_cadmat
        fetch c_ctb83m00_002 into m_r.funcnomeinc
    close c_ctb83m00_002
    open c_ctb83m00_002 using m_atlmat

        fetch c_ctb83m00_002 into m_r.funcnomeatl
    close c_ctb83m00_002

    open c_ctb83m00_009 using m_r.pgtmat, m_r.pgtempcod
    fetch c_ctb83m00_009 into m_r.funnom

    display by name m_r.*

    # MOSTRANDO A DESCRICAO DOS CAMPOS

    open c_ctb83m00_001 using m_r.pgttipcodps
       fetch c_ctb83m00_001 into m_r.cpodes
    close c_ctb83m00_001
    display m_r.cpodes to cpodes

    #open c_ctb83m00_002 using m_r.pgtmat
    #    fetch c_ctb83m00_002 into m_r.funnom
    #close c_ctb83m00_002
    #display m_r.funnom to funnom

    open c_ctb83m00_003 using m_r.corsus
        fetch c_ctb83m00_003 into m_r.cornom
    close c_ctb83m00_003
    display m_r.cornom to cornom

    open c_ctb83m00_007 using m_r.succod
        fetch c_ctb83m00_007 into m_r.sucnom
    close c_ctb83m00_007
    display m_r.sucnom to sucnom

    open c_ctb83m00_008 using m_r.pgtempcod
        fetch c_ctb83m00_008 into m_r.empnom
    close c_ctb83m00_008
    display m_r.empnom to empnom

    if m_r.pgttipcodps = 3 then

	if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
            	call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
	else
                let mr_param.empcod    = m_r.pgtempcod
            	let mr_param.succod    = m_r.succod
            	let mr_param.cctlclcod = (m_r.cctcod / 10000)
            	let mr_param.cctdptcod = (m_r.cctcod mod 10000)
            	call fctgc102_vld_dep(mr_param.*) returning mr_ret.*

		if mr_ret.cctdptnom is null or mr_ret.cctdptnom = "" then
			open  c_ctb83m00_004 using m_r.cctcod
			fetch c_ctb83m00_004 into  m_r.cctnom
			close c_ctb83m00_004
			if m_r.cctnom is null or m_r.cctnom = " " then
			 error "Centro de custo não encontrado "
			 #next field cctcod
			 call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			end if
			#CT 564761
			if m_r.cctcod < 9999 then
			    error "Centro de custo necessita do código do local "
			    call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			end if
		end if

	end if
		let m_r.cctnom = mr_ret.cctdptnom
		display m_r.cctnom to cctnom
    end if


     open c_ctb83m00_005 using g_documento.atdsrvnum, g_documento.atdsrvano
         fetch c_ctb83m00_005 into g_documento.atdsrvnum,
                               g_documento.atdsrvano,
                               m_socopgnum

    if sqlca.sqlcode = 100 then
        let l_pgttipcodpsant = m_r.pgttipcodps
        let l_pgtempcodant = m_r.pgtempcod
        let l_pgtmatant      = m_r.pgtmat
        let l_corsusant      = m_r.corsus
        let l_cctcodant      = m_r.cctcod
        input by name m_r.pgttipcodps, m_r.pgtmat, m_r.corsus, m_r.succod, m_r.cctcod, m_r.pgtempcod without defaults
--
            before field pgttipcodps
                display m_r.pgttipcodps to pgttipcodps attribute(reverse)
                message "1- Funcionario / 2- Corretor / 3- Centro de Custo"
            after field pgttipcodps
                if m_r.pgttipcodps is null then
                    error "Campo nao pode ser nulo !"
                    next field pgttipcodps
                end if

                open c_ctb83m00_001 using m_r.pgttipcodps
                    fetch c_ctb83m00_001 into m_r.cpodes
                close c_ctb83m00_001
                display m_r.pgttipcodps to pgttipcodps
                display m_r.cpodes to cpodes
                if m_r.pgttipcodps is null then
                    error "Campo nao pode ser nulo !"
                    next field pgttipcodps
                end if
                if m_r.pgttipcodps = 1 then      ## Se pagamento funcionario
                    let m_r.corsus = 0
                    let m_r.cctcod = 0
                    let m_r.succod = 0
                    let m_r.sucnom = null
                    let m_r.cornom = null
                    let m_r.cctnom = null
                    display by name m_r.corsus, m_r.cctcod, m_r.cornom, m_r.cctnom
                    #next field pgtmat
                    next field pgtempcod
                else
                    if m_r.pgttipcodps = 2 then  ## Se pagamento corretor
                        let m_r.pgtmat = 0
                        let m_r.cctcod = 0
                        let m_r.succod = 0
                        let m_r.pgtempcod = 0
                        let m_r.sucnom = null
                        let m_r.cctnom = null
                        let m_r.funnom = null
                        let m_r.empnom = null
                        display by name m_r.pgtmat, m_r.pgtempcod, m_r.cctcod, m_r.cctnom, m_r.funnom, m_r.empnom
                        next field corsus
                    else                         ## Se pagamento centro de custo
                        let m_r.corsus = 0
                        let m_r.pgtmat = 0
                        let m_r.funnom = null
                        let m_r.cornom = null
                        display by name m_r.corsus, m_r.pgtmat, m_r.funnom, m_r.cornom
                        #next field succod
                        next field pgtempcod
                    end if
                end if
                message ""


       before field pgtempcod
        	display m_r.pgtempcod to pgtempcod
        	message "Digite a empresa do funcionário que pagara pelo servico"

        after field pgtempcod
            if volta_campo() then
                display m_r.pgtempcod to pgtempcod
                next field pgttipcodps
            end if

            if m_r.pgtempcod is null or m_r.pgtempcod = 0 then
            	error "Campo não pode ser nulo!"
            	call ctb83m02(m_r.pgtempcod) returning m_r.pgtempcod, m_r.empnom

            	#CT 564761
            	if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                    error "Campo empresa não pode ser nulo!"
                    next field pgtempcod
                end if

            else
            	open c_ctb83m00_008 using m_r.pgtempcod
            	fetch c_ctb83m00_008 into m_r.empnom
	    end if

            display m_r.pgtempcod to pgtempcod
            display m_r.empnom to empnom
            #message ""
            #exit input

            if m_r.pgttipcodps = 1 then
            	let m_r.corsus = 0
                let m_r.cctcod = 0
                let m_r.succod = 0
                let m_r.sucnom = null
                let m_r.cornom = null
                let m_r.cctnom = null
                display by name m_r.corsus, m_r.cctcod, m_r.succod, m_r.sucnom, m_r.cornom, m_r.cctnom
                next field pgtmat
            else
            	if m_r.pgttipcodps = 2 then  ## Se pagamento corretor
                        let m_r.pgtmat = 0
                        let m_r.cctcod = 0
                        let m_r.succod = 0
                        let m_r.pgtempcod = 0
                        let m_r.sucnom = null
                        let m_r.cctnom = null
                        let m_r.funnom = null
                        let m_r.empnom = null
                        display by name m_r.pgtmat, m_r.cctcod, m_r.cctnom, m_r.funnom, m_r.empnom
                        next field corsus
                else                         ## Se pagamento centro de custo
                        let m_r.corsus = 0
                        let m_r.pgtmat = 0
                        let m_r.funnom = null
                        let m_r.cornom = null
                        display by name m_r.corsus, m_r.pgtmat, m_r.funnom, m_r.cornom
                        next field succod
                        #next field pgtempcod
                end if
           end if


--
            before field pgtmat
                #CT 564761
                {if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                    error "Campo empresa não pode ser nulo!"
                    next field pgtempcod
                end if}
                display m_r.pgtmat to pgtmat attribute(reverse)
                message "Digite a matricula do funcionario que pagará pelo serviço"
            after field pgtmat
                if volta_campo() then
                    display m_r.pgtmat to pgtmat
                    next field pgttipcodps
                end if
                if m_r.pgtmat is null or m_r.pgtmat = 0 then
                    error "Campo nao pode ser nulo !"
                    call cto00m01("")
                        returning ret_empcod,
                                  ret_funmat,
                                  ret_funnom
                    display "retorno 1...:", ret_empcod, " - ", ret_funmat, " - ", ret_funnom
                    let m_r.pgtmat = ret_funmat
                    let m_r.pgtempcod = ret_empcod
                    let m_r.funnom = ret_funnom

                    #CT 564761
                    if m_r.pgtmat is null or m_r.pgtmat = 0 or m_r.pgtmat = " " then
                        error "Campo não pode ser nulo! "
                        next field pgtmat
                    end if

                else
                	open c_ctb83m00_009 using m_r.pgtmat, m_r.pgtempcod
                	fetch c_ctb83m00_009 into m_r.funnom
                	if sqlca.sqlcode = 100 then
                		error "NAO FOI ENCONTRADO FUNCIONARIO"
                        	call cto00m01("")
                        	returning ret_empcod,
                                	  ret_funmat,
                                  	  ret_funnom
                        	let m_r.pgtmat = ret_funmat
                        	let m_r.pgtempcod = ret_empcod
                        	let m_r.funnom = ret_funnom
                        	next field pgtmat
                	end if
                	close c_ctb83m00_009
		end if

		display "fim do endif"
		display "conteudo...", m_r.pgtempcod, " - ", m_r.pgtmat, " - ", m_r.funnom

                display m_r.pgtempcod to pgtempcod
                display m_r.pgtmat to pgtmat
                display m_r.funnom to funnom
                message ""
                exit input
--
            before field corsus
                display m_r.corsus to corsus attribute(reverse)
                message "Digite o corsus do corretor"
            after field corsus
                if volta_campo() then
                    display m_r.corsus to corsus
                    next field pgttipcodps
                end if
                if m_r.corsus is null or m_r.corsus = 0 then
                    error "Campo nao pode ser nulo !"
                    call aggucora()
                        returning ret_corsus,
                                  ret_cvnnum,
                                  ret_cvncptagnnum
                        let m_r.corsus = ret_corsus
                end if
                open c_ctb83m00_003 using m_r.corsus
                    fetch c_ctb83m00_003 into m_r.cornom
                        if sqlca.sqlcode = 100 then
                            error "NAO FOI ENCONTRADO CORRETOR"
                            call aggucora()
                                returning ret_corsus,
                                          ret_cvnnum,
                                          ret_cvncptagnnum
                                let m_r.corsus = ret_corsus
                                next field corsus
                        end if
                close c_ctb83m00_003
                display m_r.corsus to corsus
                display m_r.cornom to cornom
                message ""
                exit input
--
        before field succod
            #CT 564761
            if m_r.pgtempcod is null or m_r.pgtempcod = 0 or m_r.pgtempcod = " " then
                error "Campo empresa não pode ser nulo!"
                next field pgtempcod
            end if
            display m_r.succod to succod attribute(reverse)
            message "Digite o codigo da sucursal"
        after field succod
            if volta_campo() then
                display m_r.succod to succod
                next field pgttipcodps
            end if
##IDENTIFICANDO A SUCURSAL
           if (m_r.succod is null or m_r.succod = 0) then
               let vf_sql = 'select  ok.succod, suc.sucnom from ctokcentrosuc ok, gabksuc suc where ok.succod = suc.succod and ok.empcod =', m_r.pgtempcod clipped
               call ofgrc001_popup
                                  (08,
                                   13,
                                   'ESCOLHA A SUCURSAL',
                                   'Codigo',
                                   'Descricao',
                                   'N',
                                   vf_sql,
                                   '',
                                   'D')
               returning l_status,
                         m_r.succod,
                         m_r.sucnom
               if l_status = 1 then
                  error "Digite o código da sucursal "
                  next field succod
               end if
           else
#IDENTIFICANDO A SUCURSAL
                 open c_ctb83m00_007 using m_r.succod
                     fetch c_ctb83m00_007 into m_r.sucnom
                        if sqlca.sqlcode = notfound then
                           let vf_sql = 'select  ok.succod, suc.sucnom from ctokcentrosuc ok, gabksuc suc where ok.succod = suc.succod and ok.empcod =', m_r.pgtempcod clipped
                           Error "Não existe esse código de gestão !!"
                           call ofgrc001_popup
                                           (08,
                                            13,
                                            'ESCOLHA A SUCURSAL',
                                            'Codigo',
                                            'Descricao',
                                            'N',
                                            vf_sql,
                                            '',
                                            'D')
                            returning l_status,
                                      m_r.succod,
                                      m_r.sucnom
                            if l_status = 1 then
                               next field succod
                            end if

                        end if
                     close c_ctb83m00_007
           end if
               display m_r.succod to succod
               display m_r.sucnom to sucnom
--

            before field cctcod
                display m_r.cctcod to cctcod attribute(reverse)
                message "Digite o número do centro de custo"
            after field cctcod
                if volta_campo() then
                    display m_r.cctcod to cctcod
                    next field pgttipcodps
                end if
               if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
            		call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom

            		#CT 564761
            	    if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
				        error "Centro de custo não pode ser nulo "
				        next field cctcod
			        end if
	           else
                	let mr_param.empcod    = m_r.pgtempcod
            		let mr_param.succod    = m_r.succod
            		let mr_param.cctlclcod = (m_r.cctcod / 10000)
            		let mr_param.cctdptcod = (m_r.cctcod mod 10000)
            		call fctgc102_vld_dep(mr_param.*) returning mr_ret.*

            		#CT 564761
            	    if m_r.cctcod is null or m_r.cctcod = 0 or m_r.cctcod = " " then
				        error "Centro de custo não pode ser nulo "
				        next field cctcod
			        end if

			        if mr_ret.cctdptnom is null or mr_ret.cctdptnom = "" then
				        open  c_ctb83m00_004 using m_r.cctcod
			            fetch c_ctb83m00_004 into  m_r.cctnom
			            close c_ctb83m00_004
			            if m_r.cctnom is null or m_r.cctnom = " " then
				            error "Centro de custo não encontrado "
				            #next field cctcod
				            call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			            end if
			            #CT 564761
			            if m_r.cctcod < 9999 then
			                error "Centro de custo necessita ser especificado "
			                call ctb83m01(m_r.succod, m_r.pgtempcod) returning m_r.cctcod, m_r.cctnom
			            end if
			        else
            			let m_r.cctnom = mr_ret.cctdptnom

			        end if

            	end if


                display m_r.cctcod to cctcod
                display m_r.cctnom to cctnom
                message ""
                exit input
        end input
        if int_flag = true then
            let int_flag=false
            let l_return = 0
        else


## TROCAR PELA S VARIVÁVEIS GLOBAIS
             let m_r.atldat = today
             let m_atlemp = g_issk.empcod
             let m_atlmat = g_issk.funmat
-------------

##  Não pode inserir nulo na tabela
             if m_r.corsus is null then
                 let m_r.corsus = '0'
             end if
             if m_r.pgtmat is null then
                 let m_r.pgtmat = 0
             end if
             if m_r.cctcod is null then
                 let m_r.cctcod = 0
             end if

            display by name  m_r.funcnomeinc,
                             m_r.caddat,
                             m_r.atldat,
                             m_r.funcnomeatl
            if   m_r.pgttipcodps != l_pgttipcodpsant or
                 m_r.pgtempcod != l_pgtempcodant or
                 m_r.pgtmat      != l_pgtmatant      or
                 m_r.corsus      != l_corsusant      or
                 m_r.cctcod      != l_cctcodant      then
                 while v_resp not matches "[SSssNNnn]" or v_resp is null
                     Prompt "Confirma? (S/N)" for char v_resp
                 end while

                 if v_resp matches "[Ss]" then
                     let g_cc.pgttipcodps  = m_r.pgttipcodps
                     let g_cc.pgtmat       = m_r.pgtmat
                     let g_cc.corsus       = m_r.corsus
                     let g_cc.cadmat       = m_cadmat
                     let g_cc.cademp       = m_cademp
                     let g_cc.caddat       = m_r.caddat
                     let g_cc.atlmat       = m_atlmat
                     let g_cc.atlemp       = m_atlemp
                     let g_cc.atldat       = m_r.atldat
                     let g_cc.cctcod       = m_r.cctcod
                     let g_cc.pgtempcod    = m_r.pgtempcod



                     WHENEVER ERROR CONTINUE
                     execute p_ctb83m00_007 using g_documento.atdsrvano,
                                              g_documento.atdsrvnum,
                                              m_r.pgttipcodps,
                                              m_r.pgtmat,
                                              m_r.corsus,
                                              m_atlmat  ,
                                              m_atlemp  ,
                                              m_r.atldat,
                                              m_r.cctcod,
                                              m_r.succod,
                                              m_r.pgtempcod,
                                              g_documento.atdsrvano,
                                              g_documento.atdsrvnum,
                                              l_pgttipcodpsant

                     WHENEVER ERROR STOP
	                 if sqlca.sqlcode = 0 then
                         if SQLCA.SQLERRD[3] > 0 then
  	                         Error "ALTERACAO EFETUADA !!"
                             sleep 1
                             let l_return = 1
                         else
                            Error "Erro, nenhum registro alterado !!"
                         end if
                     else
                         let l_error = sqlca.sqlcode, "/", sqlca.sqlerrd[2], " pctb83m007"
                         Error "ERRO -> ", l_error
                         sleep 2
                         let l_return = 0
                     end if
                 else
                     Error "NÃO ALTERADO"
                     let l_return = 0
                     sleep 1
                 end if
            end if
        end if
    else
           message "Dados somente para consulta. Servico ja pago"
        let int_flag = false
        while int_flag = false
        end while
        message ""
        let l_return = 0
    end if
    return l_return

 end function





##--------------------------------00000000------------------------------>>
 Function volta_campo()
##--------------------------------00000000------------------------------>>
    if  fgl_lastkey() = fgl_keyval('UP') or
        fgl_lastkey() = fgl_keyval('left') then

            return true
    else
            return false
    end if
 end function






