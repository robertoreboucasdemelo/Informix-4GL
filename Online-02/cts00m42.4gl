{----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: CENTRAL 24 HORAS                                          #
# MODULO.........: CTS00M42.4GL                                              #
# ANALISTA RESP..: R.FORNAX                                                  #
# PSI/OSF........:                                                           #
# OBJETIVO.......: REGRAS LEVA E TRAZ                                        #
#............................................................................#
# DESENVOLVIMENTO: R.FORNAX                                                  #
# LIBERACAO......: 11/07/2013                                                #
#............................................................................}

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prep_sql      smallint

#------------------------------------#
 function cts00m42_prepare()
#------------------------------------#

define l_sql  char(1000)


  let l_sql = "select a.atdsrvnum ,      " ,
              "       a.atdsrvano        " ,
              " from datmservico a,      " ,
              "      datmligacao b,      " ,
              "      datrligapol c       " ,
              " where a.atdsrvnum = b.atdsrvnum " ,
              " and a.atdsrvano = b.atdsrvano   " ,
              " and b.lignum    = c.lignum      " ,
              " and c.succod = ?                " ,
              " and c.ramcod = ?                " ,
              " and c.aplnumdig = ?             " ,
              " and c.itmnumdig = ?             " ,
              " and b.c24astcod = ?             "
  prepare p_cts00m42_001 from l_sql
  declare c_cts00m42_001 cursor with hold for p_cts00m42_001


  let l_sql = "select atdetpcod     ",
              "  from datmsrvacp    ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? ",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
  prepare p_cts00m42_002 from l_sql
  declare c_cts00m42_002 cursor with hold for p_cts00m42_002


  let l_sql = " select count(*)  "
             ," from iddkdominio "
	     ," where cponom = ? "
             ," and   cpodes = ? "
	prepare p_cts00m42_003 from l_sql
	declare c_cts00m42_003 cursor with hold for p_cts00m42_003


	let l_sql =  "select cbtcod,    "
	            ,"       ctgtrfcod  "
                    ,"from abbmcasco    "
                    ,"where succod  = ? "
                    ,"and aplnumdig = ? "
                    ,"and itmnumdig = ? "
                    ,"and dctnumseq = ? "
	prepare p_cts00m42_004 from l_sql
	declare c_cts00m42_004 cursor with hold for p_cts00m42_004

  let l_sql = " select cpodes    "
	     ," from iddkdominio "
             ," where cponom = ? "
	prepare p_cts00m42_005 from l_sql
	declare c_cts00m42_005 cursor with hold for p_cts00m42_005


  let l_sql = "select b.c24pbmgrpcod, ",
              "       b.c24pbmgrpdes, ",
              "       a.c24pbmdes     ",
	            "from datkpbm a,        ",
	            "     datkpbmgrp b      ",
	            "where a.c24pbmgrpcod = b.c24pbmgrpcod " ,
	            "and a.c24pbmcod = ?    "
	prepare p_cts00m42_006 from l_sql
	declare c_cts00m42_006 cursor with hold for p_cts00m42_006

	let l_sql = "select b.c24astcod,     ",
	            "       a.c24solnom,     ",
	            "       a.atddat,        ",
	            "       a.atdhor,        ",
	            "       a.atddfttxt,     ",
	            "       a.vclcorcod,     ",
	            "       a.ciaempcod,     ",
	            "       a.atdsrvorg,     ",
	            "       c.atdcennum,     ",
	            "       c.emaenvflg,     ",
	            "       d.c24astdes,     ",
	            "       b.lignum         ",
	            "from  datmservico a,    ",
	            "      datmligacao b,    ",
                    "outer datmservicocmp c, ",
	            "      datkassunto d     ",
	            "where a.atdsrvnum = b.atdsrvnum " ,
	            "and   a.atdsrvano = b.atdsrvano " ,
	            "and   a.atdsrvnum = c.atdsrvnum " ,
	            "and   a.atdsrvano = c.atdsrvano " ,
	            "and   b.c24astcod = d.c24astcod " ,
	            "and   a.atdsrvnum = ?  " ,
	            "and   a.atdsrvano = ?  " ,
	            "order by lignum        "
	prepare p_cts00m42_007 from l_sql
	declare c_cts00m42_007 cursor with hold for p_cts00m42_007


	let l_sql = "select succod,       ",
	            "       ramcod,       ",
	            "       aplnumdig,    ",
	            "       itmnumdig,    ",
	            "       edsnumref     ",
	            "from datrligapol     ",
	            "where lignum = ?     "
	prepare p_cts00m42_008 from l_sql
	declare c_cts00m42_008 cursor with hold for p_cts00m42_008


	let l_sql = "select segnumdig    ",
	            "from   abbmdoc      ",
	            "where succod  =  ?  ",
	            "and aplnumdig =  ?  ",
	            "and itmnumdig =  ?  ",
	            "and dctnumseq =  ?  "
	prepare p_cts00m42_009 from l_sql
	declare c_cts00m42_009 cursor with hold for p_cts00m42_009


	let l_sql = "select a.segnom, ",
	            "       b.dddcod, ",
	            "       b.teltxt  ",
	            "from gsakseg a,  ",
	            "     gsakend b   ",
	            "where a.segnumdig  = b.segnumdig ",
	            "and   b.endfld     = '1'         ",
	            "and   a.segnumdig  = ?           "
	prepare p_cts00m42_010 from l_sql
	declare c_cts00m42_010 cursor with hold for p_cts00m42_010


	let l_sql = "select a.vclcoddig, ",
	            "       a.vclanofbc, ",
	            "       a.vclanomdl, ",
	            "       a.vcllicnum, ",
	            "       a.vclchsinc, ",
	            "       a.vclchsfnl, ",
	            "       b.vclmrccod, ",
	            "       b.vcltipcod, ",
	            "       b.vclmdlnom, ",
	            "       c.vclmrcnom, ",
	            "       d.vcltipnom	 ",
	            "from abbmveic  a ,  ",
	            "     agbkveic  b ,  ",
	            "     agbkmarca c ,  ",
	            "     agbktip   d    ",
	            "where a.vclcoddig  = b.vclcoddig ",
	            "and   b.vclmrccod  = c.vclmrccod ",
	            "and   b.vclmrccod  = d.vclmrccod ",
	            "and   b.vcltipcod  = d.vcltipcod ",
	            "and   a.succod     = ?       	  ",
	            "and   a.aplnumdig  = ?       	  ",
	            "and   a.itmnumdig  = ?       	  ",
	            "and   a.dctnumseq  = ?           "
		prepare p_cts00m42_011 from l_sql
		declare c_cts00m42_011 cursor with hold for p_cts00m42_011


		let l_sql = "select cpodes[2,9] ",
		            "from iddkdominio   ",
		            "where cponom  = 'vclcorcod' ",
		            "and cpocod    = ?           "
		prepare p_cts00m42_012 from l_sql
		declare c_cts00m42_012 cursor with hold for p_cts00m42_012


		let l_sql = "select min(dctnumseq) ",
		            "from abbmdoc          ",
		            "where succod  = ?     ",
		            "and aplnumdig = ?     ",
		            "and itmnumdig = ?     "
		prepare p_cts00m42_013 from l_sql
		declare c_cts00m42_013 cursor with hold for p_cts00m42_013


		let l_sql = "update datmservicocmp ",
		            "set atdcennum = ?     ",
		            "where atdsrvnum = ?   ",
		            "and   atdsrvano = ?   "
		prepare p_cts00m42_014 from l_sql


		let l_sql = "update datmservicocmp ",
		            "set emaenvflg = ?     ",
		            "where atdsrvnum = ?   ",
		            "and   atdsrvano = ?   "
		prepare p_cts00m42_015 from l_sql


		let l_sql = "select c24pbmdes     ",
		            "from datkpbm         ",
		            "where c24pbmcod = ?  "
		prepare p_cts00m42_016 from l_sql
		declare c_cts00m42_016 cursor with hold for p_cts00m42_016


	  let l_sql = "select dddcod        ,    ",
	              "       lcltelnum     ,    ",
	              "       celteldddcod  ,    ",
	              "       celtelnum          ",
		            "from datmlcl              ",
		            "where atdsrvnum = ?       ",
		            "and   atdsrvano = ?       ",
		            "and   c24endtip = ?       "
		prepare p_cts00m42_017 from l_sql
		declare c_cts00m42_017 cursor with hold for p_cts00m42_017

    let m_prep_sql = true

end function

#------------------------------------------#
function cts00m42_conta_corrente(lr_param)
#------------------------------------------#

define lr_param record
  c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
  atdsrvnum like datmservico.atdsrvnum ,
  atdsrvano like datmservico.atdsrvano ,
  atdetpcod like datmsrvacp.atdetpcod  ,
  cbtcod    like abbmcasco.cbtcod      ,
  ctgtrfcod like abbmcasco.ctgtrfcod   ,
  cponom1   like iddkdominio.cponom    ,
  cponom2   like iddkdominio.cponom    ,
  qtd       integer                    ,
  confirma  char(01)                   ,
  limite    integer
end record

initialize lr_retorno.* to null

let lr_retorno.qtd     = 0
let lr_retorno.cponom1 = "cts00m42_categoria"
let lr_retorno.cponom2 = "cts00m42_cobertura"

if m_prep_sql <> true or
    m_prep_sql is null then
    call cts00m42_prepare()
end if



   if lr_param.c24astcod = "SLV" or
   	  lr_param.c24astcod = "SLT" then


       #-----------------------------------------------
       # Recupera o Servico
       #-----------------------------------------------

       open c_cts00m42_001 using g_documento.succod     ,
                                 g_documento.ramcod     ,
                                 g_documento.aplnumdig  ,
                                 g_documento.itmnumdig  ,
                                 lr_param.c24astcod


       foreach c_cts00m42_001 into lr_retorno.atdsrvnum ,
                                   lr_retorno.atdsrvano


          #-----------------------------------------------
          # Verifica a Etapa do Servico
          #-----------------------------------------------

          open  c_cts00m42_002  using lr_retorno.atdsrvnum,
                                      lr_retorno.atdsrvano,
                                      lr_retorno.atdsrvnum,
                                      lr_retorno.atdsrvano
          whenever error continue
          fetch c_cts00m42_002  into  lr_retorno.atdetpcod
          whenever error stop

          close c_cts00m42_002

         #-----------------------------------------------
         # Soma Se For Serviço Diferente de Cancelado
         #-----------------------------------------------

          if lr_retorno.atdetpcod <> 5 then
             let lr_retorno.qtd = lr_retorno.qtd + 1
          end if


       end foreach

       #-----------------------------------------------
       # Verifica Se Excede o Limite de Quantidades
       #-----------------------------------------------
       if cty31g00_nova_regra_clausula(lr_param.c24astcod) then

       	 call cty31g00_valida_limite(lr_param.c24astcod,
       	                             g_nova.clscod     ,
       	                             g_nova.perfil     ,
       	                             "")
       	 returning lr_retorno.limite
       else
       	  let lr_retorno.limite = 1
       end if
       if lr_retorno.qtd >= lr_retorno.limite then

            call cts08g01('A' ,'N' ,
                          'BENEFICIO EXCEDIDO ' , ''  ,
                          'LIMITADO A UM ATENDIMENTO' ,
                          'DURANTE A VIGENCIA' )
            returning lr_retorno.confirma

            return false

       end if

       #-----------------------------------------------
       # Recupera a Cobertura e Categoria Tarifaria
       #-----------------------------------------------

       open  c_cts00m42_004  using g_documento.succod     ,
                                   g_documento.aplnumdig  ,
                                   g_documento.itmnumdig  ,
                                   g_funapol.dmtsitatu
       whenever error continue
       fetch c_cts00m42_004  into  lr_retorno.cbtcod   ,
                                   lr_retorno.ctgtrfcod
       whenever error stop

       close c_cts00m42_004


       #-------------------------------------------------
       # Verifica se a Categoria Tarifaria Tem Permissao
       #-------------------------------------------------

       open c_cts00m42_003 using lr_retorno.cponom1 ,
                                 lr_retorno.ctgtrfcod
       whenever error continue
       fetch c_cts00m42_003 into lr_retorno.qtd

       whenever error stop

       if sqlca.sqlcode <> 0 then
          error 'Erro ao Recuperar a Categoria Tarifaria / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          return false
       end if

       if lr_retorno.qtd = 0 then

       	  call cts08g01('A' ,'N' ,
       	                'APOLICE SEM DIREITO AO BENEFICIO ' , ''  ,
       	                'VERIFIQUE A CATEGORIA TARIFARIA' ,
       	                'DO DOCUMENTO' )
       	  returning lr_retorno.confirma

       	  return false
       end if

       #-----------------------------------------------
       # Verifica se a Cobertura Tem Permissao
       #-----------------------------------------------

       open c_cts00m42_003 using lr_retorno.cponom2 ,
                                 lr_retorno.cbtcod
       whenever error continue
       fetch c_cts00m42_003 into lr_retorno.qtd

       whenever error stop

       if sqlca.sqlcode <> 0 then
          error 'Erro ao Recuperar a Cobertura / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          return false
       end if

       if lr_retorno.qtd = 0 then

       	  call cts08g01('A' ,'N' ,
       	                'APOLICE SEM DIREITO AO BENEFICIO ' , ''  ,
       	                'VERIFIQUE AS COBERTURAS' ,
       	                'DO DOCUMENTO' )
       	  returning lr_retorno.confirma

       	  return false
       end if

    end if

    return true

end function

#-----------------------------------------------------------------------------
function cts00m42_valida_acesso(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
   qtd    smallint ,
   cponom like iddkdominio.cponom
end record


if m_prep_sql <> true or
    m_prep_sql is null then
    call cts00m42_prepare()
end if


let lr_retorno.qtd    = 0
let lr_retorno.cponom = "cts00m42_acesso"

    #-----------------------------------------------
    # Verifica Se o Assunto Tem Permissao de Saida
    #-----------------------------------------------

    open c_cts00m42_003 using lr_retorno.cponom ,
                              lr_param.c24astcod
    whenever error continue
    fetch c_cts00m42_003 into lr_retorno.qtd

    whenever error stop

    if sqlca.sqlcode <> 0 then
       error 'Erro ao Recuperar o Assunto / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
    end if


    if lr_retorno.qtd = 0 then
    	 return true
    else
    	 return false
    end if


end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_problema(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
   cponom       like iddkdominio.cponom      ,
   c24pbmcod    like datkpbm.c24pbmcod       ,
   c24pbmdes    like datkpbm.c24pbmdes       ,
   c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod ,
   c24pbmgrpdes like datkpbmgrp.c24pbmgrpdes
end record

initialize lr_retorno.* to null

    if lr_param.c24astcod = "SLV" or
       lr_param.c24astcod = "SLT" then

    	 if m_prep_sql <> true or
          m_prep_sql is null then
          call cts00m42_prepare()
       end if


       if lr_param.c24astcod = "SLV" then
            let lr_retorno.cponom = "cts00m42_prob_slv"
       else
            let lr_retorno.cponom = "cts00m42_prob_slt"
       end if

       #-----------------------------------------------
       # Recupera o Problema do Assunto
       #-----------------------------------------------

       open c_cts00m42_005 using lr_retorno.cponom
       whenever error continue
       fetch c_cts00m42_005 into lr_retorno.c24pbmcod

       whenever error stop

       if sqlca.sqlcode <> 0 then
         error 'Erro ao Recuperar o Problema / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       else

       	   #-----------------------------------------------
       	   # Recupera as Descricoes do Problema
       	   #-----------------------------------------------

       	   open c_cts00m42_006 using lr_retorno.c24pbmcod
       	   whenever error continue
       	   fetch c_cts00m42_006 into lr_retorno.c24pbmgrpcod,
       	                             lr_retorno.c24pbmgrpdes,
       	                             lr_retorno.c24pbmdes
       	   whenever error stop

       	   if sqlca.sqlcode <> 0 then
       	     error 'Erro ao Recuperar o Agrupamento do Problema 0 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       	   end if

       end if

    end if

    return lr_retorno.c24pbmgrpcod ,
           lr_retorno.c24pbmgrpdes ,
           lr_retorno.c24pbmcod    ,
           lr_retorno.c24pbmdes


end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_agrupamento(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datkassunto.c24astcod
end record


define lr_retorno record
   cponom       like iddkdominio.cponom      ,
   c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod ,
   acesso       smallint
end record

initialize lr_retorno.* to null



if m_prep_sql <> true or
   m_prep_sql is null then
   call cts00m42_prepare()
end if

let lr_retorno.cponom = "cts00m42_agrupa"

   #-----------------------------------------------
   # Recupera o Agrupamento
   #-----------------------------------------------

   open c_cts00m42_005 using lr_retorno.cponom
   whenever error continue
   fetch c_cts00m42_005 into lr_retorno.c24pbmgrpcod

   whenever error stop

   if sqlca.sqlcode <> 0 then
     error 'Erro ao Recuperar o Agrupamento do Problema 1 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
   end if

   if lr_param.c24astcod = "SLV" or
   	  lr_param.c24astcod = "SLT" then

      let lr_retorno.acesso = 1
   else
   	  let lr_retorno.acesso = 0
   end if


   return lr_retorno.c24pbmgrpcod,
          lr_retorno.acesso


end function

#-----------------------------------------------------------------------------
function cts00m42_email(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   atdsrvnum  like datmservico.atdsrvnum,
   atdsrvano  like datmservico.atdsrvano
end record


define lr_retorno record
	 cappstcod          like avgkcappst.cappstcod    ,
	 emaenvflg          like datmservicocmp.emaenvflg,
   c24astcod          like datkassunto.c24astcod   ,
   c24astdes          like datkassunto.c24astdes   ,
   lignum             like datmligacao.lignum      ,
   succod             like datrligapol.succod      ,
   ramcod             like datrligapol.ramcod      ,
   aplnumdig          like datrligapol.aplnumdig   ,
   itmnumdig          like datrligapol.itmnumdig   ,
   edsnumref          like datrligapol.edsnumref   ,
   dctnumseq          like abbmdoc.dctnumseq       ,
   segnumdig          like abbmdoc.segnumdig       ,
   segnom             like gsakseg.segnom          ,
   dddcod             like gsakend.dddcod          ,
   teltxt             like gsakend.teltxt          ,
   celtxt             like gsakend.teltxt          ,
   srvtxt             like gsakend.teltxt          ,
   vclcoddig          like abbmveic.vclcoddig      ,
   vclanofbc          char(20)                     ,
   vclanomdl          char(20)                     ,
   vcllicnum          like abbmveic.vcllicnum      ,
   vclchs             char(20)                     ,
   vclmrccod          like agbkveic.vclmrccod      ,
   vcltipcod          like agbkveic.vcltipcod      ,
   vclmdlnom          like agbkveic.vclmdlnom      ,
   vclmrcnom          like agbkmarca.vclmrcnom     ,
   vcltipnom          like agbktip.vcltipnom       ,
   c24solnom          like datmservico.c24solnom   ,
   atddat             like datmservico.atddat      ,
   atdhor             like datmservico.atdhor      ,
   atddfttxt          like datmservico.atddfttxt   ,
   vclcorcod          like datmservico.vclcorcod   ,
   ciaempcod          like datmservico.ciaempcod   ,
   vclcordes          char(10)                     ,
   cappstnom          like avgkcappst.cappstnom    ,
   stt                smallint                     ,
   mensagem           char(32766)                  ,
   atdsrvorg          like datmservico.atdsrvorg   ,
   atdcenelrcoiendnom like avgmcappstend.atdcenelrcoiendnom
end record


initialize lr_retorno.* to null



if m_prep_sql <> true or
   m_prep_sql is null then
   call cts00m42_prepare()
end if

   #-----------------------------------------------
   # Recupera os Dados do Servico
   #-----------------------------------------------

   open c_cts00m42_007 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   whenever error continue
   fetch c_cts00m42_007 into lr_retorno.c24astcod,
                             lr_retorno.c24solnom,
                             lr_retorno.atddat   ,
                             lr_retorno.atdhor   ,
                             lr_retorno.atddfttxt,
                             lr_retorno.vclcorcod,
                             lr_retorno.ciaempcod,
                             lr_retorno.atdsrvorg,
                             lr_retorno.cappstcod,
                             lr_retorno.emaenvflg,
                             lr_retorno.c24astdes,
                             lr_retorno.lignum

   whenever error stop

   if sqlca.sqlcode <> 0 then
     error 'Erro ao Recuperar o Servico / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
   end if



   if lr_retorno.cappstcod is not null and
      lr_retorno.emaenvflg is null     then

       if lr_retorno.c24astcod = "SLV" or
       	  lr_retorno.c24astcod = "S10" or
       	  lr_retorno.c24astcod = "I30" or
       	  lr_retorno.c24astcod = "K10" then

       	  #-----------------------------------------------
       	  # Recupera os Dados da Apolice
       	  #-----------------------------------------------

       	  open c_cts00m42_008 using lr_retorno.lignum
          whenever error continue
          fetch c_cts00m42_008 into lr_retorno.succod     ,
                                    lr_retorno.ramcod     ,
                                    lr_retorno.aplnumdig  ,
                                    lr_retorno.itmnumdig  ,
                                    lr_retorno.edsnumref

          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar a Apolice / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if


          #-----------------------------------------------
          # Recupera os Telefones do Servico
          #-----------------------------------------------

          call cts00m42_recupera_telefone(lr_retorno.c24astcod,
                                          lr_param.atdsrvnum  ,
                                          lr_param.atdsrvano  )
          returning  lr_retorno.srvtxt,
                     lr_retorno.celtxt


          case lr_retorno.ciaempcod
          	when 1

              #-----------------------------------------------
              # Recupera os Dados do Veiculo Porto
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_porto(lr_retorno.succod   ,
                                                         lr_retorno.aplnumdig,
                                                         lr_retorno.itmnumdig,
                                                         lr_retorno.vclcorcod)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes

            when 35

            	#-----------------------------------------------
              # Recupera os Dados do Veiculo Azul
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_azul(lr_retorno.succod   ,
                                                        lr_retorno.ramcod   ,
                                                        lr_retorno.aplnumdig,
                                                        lr_retorno.itmnumdig,
                                                        lr_retorno.edsnumref,
                                                        lr_retorno.vclcorcod)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes

            when 84

            	#-----------------------------------------------
              # Recupera os Dados do Veiculo Itau
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_itau(lr_retorno.succod   ,
                                                        lr_retorno.ramcod   ,
                                                        lr_retorno.aplnumdig,
                                                        lr_retorno.itmnumdig,
                                                        lr_retorno.edsnumref)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes


          end case




          #-----------------------------------------------
          # Recupera o Nome do Posto CAPS
          #-----------------------------------------------

          call oavpc071_recupera_nome_posto(lr_retorno.cappstcod)
          returning lr_retorno.cappstnom,
                    lr_retorno.stt


          #-----------------------------------------------
          # Recupera o E-mail do Posto CAPS
          #-----------------------------------------------

          call oavpc071_recupera_email_caps(lr_retorno.cappstcod)
          returning lr_retorno.atdcenelrcoiendnom


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          call cts00m42_monta_mensagem (lr_param.atdsrvnum   ,
                                        lr_param.atdsrvano   ,
                                        lr_retorno.atdsrvorg ,
                                        lr_retorno.c24solnom ,
                                        lr_retorno.atddat    ,
                                        lr_retorno.atdhor    ,
                                        lr_retorno.atddfttxt ,
                                        lr_retorno.segnom    ,
                                        lr_retorno.teltxt    ,
                                        lr_retorno.celtxt    ,
                                        lr_retorno.srvtxt    ,
                                        lr_retorno.vclmrcnom ,
                                        lr_retorno.vcltipnom ,
                                        lr_retorno.vclmdlnom ,
                                        lr_retorno.vclchs    ,
                                        lr_retorno.vcllicnum ,
                                        lr_retorno.vclanofbc ,
                                        lr_retorno.vclanomdl ,
                                        lr_retorno.vclcordes ,
                                        lr_retorno.cappstnom )

          returning lr_retorno.mensagem


          if lr_retorno.atdcenelrcoiendnom is not null then


          	 #-----------------------------------------------
          	 # Dispara o E-mail
          	 #-----------------------------------------------

          	 call cts00m42_dispara_email(lr_param.atdsrvnum           ,
          	                             lr_param.atdsrvano           ,
          	                             lr_retorno.c24astdes         ,
          	                             "E"                          ,
          	                             lr_retorno.mensagem          ,
          	                             lr_retorno.atdcenelrcoiendnom )
          	 returning lr_retorno.stt


          	 if lr_retorno.stt <> 0 then
          	    error "Erro ao Enviar Email Para o CAPS ! " sleep 2
          	 else


          	 	   #-----------------------------------------------
          	 	   # Atualiza o Complemento do Servico
          	 	   #-----------------------------------------------

          	 	   let lr_retorno.emaenvflg = "S"

          	 	   whenever error continue
          	 	   execute p_cts00m42_015 using lr_retorno.emaenvflg,
          	 	                                lr_param.atdsrvnum  ,
          	 	                                lr_param.atdsrvano
          	 	   whenever error stop


          	 	   if sqlca.sqlcode <> 0 then
          	 	     error 'Erro ao Atualizar o CAPS / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          	 	   end if

          	 end if

          end if
       end if
   end if


end function

#-----------------------------------------------------------------------------
function cts00m42_email_cancelamento(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   atdsrvnum  like datmservico.atdsrvnum,
   atdsrvano  like datmservico.atdsrvano
end record


define lr_retorno record
	 cappstcod          like avgkcappst.cappstcod    ,
	 capsemail          char(01)                     ,
   c24astcod          like datkassunto.c24astcod   ,
   c24astdes          like datkassunto.c24astdes   ,
   lignum             like datmligacao.lignum      ,
   succod             like datrligapol.succod      ,
   ramcod             like datrligapol.ramcod      ,
   aplnumdig          like datrligapol.aplnumdig   ,
   itmnumdig          like datrligapol.itmnumdig   ,
   edsnumref          like datrligapol.edsnumref   ,
   dctnumseq          like abbmdoc.dctnumseq       ,
   segnumdig          like abbmdoc.segnumdig       ,
   segnom             like gsakseg.segnom          ,
   dddcod             like gsakend.dddcod          ,
   teltxt             like gsakend.teltxt          ,
   celtxt             like gsakend.teltxt          ,
   srvtxt             like gsakend.teltxt          ,
   vclcoddig          like abbmveic.vclcoddig      ,
   vclanofbc          char(10)                     ,
   vclanomdl          char(10)                     ,
   vcllicnum          like abbmveic.vcllicnum      ,
   vclchs             char(20)                     ,
   vclmrccod          like agbkveic.vclmrccod      ,
   vcltipcod          like agbkveic.vcltipcod      ,
   vclmdlnom          like agbkveic.vclmdlnom      ,
   vclmrcnom          like agbkmarca.vclmrcnom     ,
   vcltipnom          like agbktip.vcltipnom       ,
   c24solnom          like datmservico.c24solnom   ,
   atddat             like datmservico.atddat      ,
   atdhor             like datmservico.atdhor      ,
   atddfttxt          like datmservico.atddfttxt   ,
   ciaempcod          like datmservico.ciaempcod   ,
   vclcorcod          like datmservico.vclcorcod   ,
   vclcordes          char(10)                     ,
   cappstnom          like avgkcappst.cappstnom    ,
   stt                smallint                     ,
   mensagem           char(32766)                  ,
   atdsrvorg          like datmservico.atdsrvorg   ,
   atdcenelrcoiendnom like avgmcappstend.atdcenelrcoiendnom
end record


initialize lr_retorno.* to null


if m_prep_sql <> true or
   m_prep_sql is null then
   call cts00m42_prepare()
end if


   #-----------------------------------------------
   # Recupera os Dados do Servico
   #-----------------------------------------------

   open c_cts00m42_007 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   whenever error continue
   fetch c_cts00m42_007 into lr_retorno.c24astcod,
                             lr_retorno.c24solnom,
                             lr_retorno.atddat   ,
                             lr_retorno.atdhor   ,
                             lr_retorno.atddfttxt,
                             lr_retorno.vclcorcod,
                             lr_retorno.ciaempcod,
                             lr_retorno.atdsrvorg,
                             lr_retorno.cappstcod,
                             lr_retorno.capsemail,
                             lr_retorno.c24astdes,
                             lr_retorno.lignum

   whenever error stop

   if sqlca.sqlcode <> 0 then
     error 'Erro ao Recuperar o Servico / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
   end if


   if lr_retorno.cappstcod is not null then

       if lr_retorno.c24astcod = "SLV" or
       	  lr_retorno.c24astcod = "S10" or
       	  lr_retorno.c24astcod = "I30" or
       	  lr_retorno.c24astcod = "K10" then


       	  #-----------------------------------------------
       	  # Recupera os Dados da Apolice
       	  #-----------------------------------------------

       	  open c_cts00m42_008 using lr_retorno.lignum
          whenever error continue
          fetch c_cts00m42_008 into lr_retorno.succod     ,
                                    lr_retorno.ramcod     ,
                                    lr_retorno.aplnumdig  ,
                                    lr_retorno.itmnumdig  ,
                                    lr_retorno.edsnumref

          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar a Apolice / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if


          #-----------------------------------------------
          # Recupera os Telefones do Servico
          #-----------------------------------------------

          call cts00m42_recupera_telefone(lr_retorno.c24astcod,
                                          lr_param.atdsrvnum  ,
                                          lr_param.atdsrvano  )
          returning  lr_retorno.srvtxt,
                     lr_retorno.celtxt


          case lr_retorno.ciaempcod
          	when 1

              #-----------------------------------------------
              # Recupera os Dados do Veiculo Porto
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_porto(lr_retorno.succod   ,
                                                         lr_retorno.aplnumdig,
                                                         lr_retorno.itmnumdig,
                                                         lr_retorno.vclcorcod)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes

            when 35

            	#-----------------------------------------------
              # Recupera os Dados do Veiculo Azul
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_azul(lr_retorno.succod   ,
                                                        lr_retorno.ramcod   ,
                                                        lr_retorno.aplnumdig,
                                                        lr_retorno.itmnumdig,
                                                        lr_retorno.edsnumref,
                                                        lr_retorno.vclcorcod)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes

            when 84

            	#-----------------------------------------------
              # Recupera os Dados do Veiculo Itau
              #-----------------------------------------------


              call cts00m42_recupera_dados_veiculo_itau(lr_retorno.succod   ,
                                                        lr_retorno.ramcod   ,
                                                        lr_retorno.aplnumdig,
                                                        lr_retorno.itmnumdig,
                                                        lr_retorno.edsnumref)
              returning lr_retorno.segnom
                       ,lr_retorno.teltxt
                       ,lr_retorno.vclmrcnom
                       ,lr_retorno.vclmdlnom
                       ,lr_retorno.vcltipnom
                       ,lr_retorno.vclchs
                       ,lr_retorno.vcllicnum
                       ,lr_retorno.vclanofbc
                       ,lr_retorno.vclanomdl
                       ,lr_retorno.vclcordes


          end case

          #-----------------------------------------------
          # Recupera o Nome do Posto CAPS
          #-----------------------------------------------

          call oavpc071_recupera_nome_posto(lr_retorno.cappstcod)
          returning lr_retorno.cappstnom,
                    lr_retorno.stt


          #-----------------------------------------------
          # Recupera o E-mail do Posto CAPS
          #-----------------------------------------------

          call oavpc071_recupera_email_caps(lr_retorno.cappstcod)
          returning lr_retorno.atdcenelrcoiendnom


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          call cts00m42_monta_mensagem (lr_param.atdsrvnum   ,
                                        lr_param.atdsrvano   ,
                                        lr_retorno.atdsrvorg ,
                                        lr_retorno.c24solnom ,
                                        lr_retorno.atddat    ,
                                        lr_retorno.atdhor    ,
                                        lr_retorno.atddfttxt ,
                                        lr_retorno.segnom    ,
                                        lr_retorno.teltxt    ,
                                        lr_retorno.celtxt    ,
                                        lr_retorno.srvtxt    ,
                                        lr_retorno.vclmrcnom ,
                                        lr_retorno.vcltipnom ,
                                        lr_retorno.vclmdlnom ,
                                        lr_retorno.vclchs    ,
                                        lr_retorno.vcllicnum ,
                                        lr_retorno.vclanofbc ,
                                        lr_retorno.vclanomdl ,
                                        lr_retorno.vclcordes ,
                                        lr_retorno.cappstnom )

          returning lr_retorno.mensagem


          if lr_retorno.atdcenelrcoiendnom is not null then


          	 #-----------------------------------------------
          	 # Dispara o E-mail
          	 #-----------------------------------------------

          	 call cts00m42_dispara_email(lr_param.atdsrvnum           ,
          	                             lr_param.atdsrvano           ,
          	                             lr_retorno.c24astdes         ,
          	                             "C"                          ,
          	                             lr_retorno.mensagem          ,
          	                             lr_retorno.atdcenelrcoiendnom)
          	 returning lr_retorno.stt


          	 if lr_retorno.stt <> 0 then
          	    error "Erro ao Enviar Email Para o CAPS ! " sleep 2
          	 end if

          end if
       end if
   end if


end function

#-----------------------------------------------------------------------------
function cts00m42_grava_complemento_caps(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   cappstcod  like avgkcappst.cappstcod ,
   atdsrvnum  like datmservico.atdsrvnum,
   atdsrvano  like datmservico.atdsrvano
end record


if m_prep_sql <> true or
   m_prep_sql is null then
   call cts00m42_prepare()
end if



   #-----------------------------------------------
   # Atualiza o CAPS no Complemento
   #-----------------------------------------------

   whenever error continue
   execute p_cts00m42_014 using lr_param.cappstcod ,
                                lr_param.atdsrvnum ,
                                lr_param.atdsrvano
   whenever error stop


   if sqlca.sqlcode <> 0 then
     error 'Erro ao Atualizar o CAPS / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
   end if

   return

end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_dados_veiculo_porto(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   succod       like datrligapol.succod      ,
   aplnumdig    like datrligapol.aplnumdig   ,
   itmnumdig    like datrligapol.itmnumdig   ,
   vclcorcod    like datmservico.vclcorcod
end record


define lr_retorno record
   dctnumseq    like abbmdoc.dctnumseq       ,
   segnumdig    like abbmdoc.segnumdig       ,
   segnom       like gsakseg.segnom          ,
   dddcod       like gsakend.dddcod          ,
   teltxt       like gsakend.teltxt          ,
   vclcoddig    like abbmveic.vclcoddig      ,
   vclanofbc    like abbmveic.vclanofbc      ,
   vclanomdl    like abbmveic.vclanomdl      ,
   vcllicnum    like abbmveic.vcllicnum      ,
   vclchsinc    like abbmveic.vclchsinc      ,
   vclchsfnl    like abbmveic.vclchsfnl      ,
   vclmrccod    like agbkveic.vclmrccod      ,
   vcltipcod    like agbkveic.vcltipcod      ,
   vclmdlnom    like agbkveic.vclmdlnom      ,
   vclmrcnom    like agbkmarca.vclmrcnom     ,
   vcltipnom    like agbktip.vcltipnom       ,
   vclcordes    char(10)                     ,
   vclchs       char(20)
end record


          #-----------------------------------------------
          # Recupera a Ultima Sequencia da Apolice
          #-----------------------------------------------

          open c_cts00m42_013 using lr_param.succod     ,
                                    lr_param.aplnumdig  ,
                                    lr_param.itmnumdig
          whenever error continue
          fetch c_cts00m42_013 into lr_retorno.dctnumseq
          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar a Apolice / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if

          #-----------------------------------------------
          # Recupera o Numero do Segurado
          #-----------------------------------------------

          open c_cts00m42_009 using lr_param.succod    ,
                                    lr_param.aplnumdig ,
                                    lr_param.itmnumdig ,
                                    lr_retorno.dctnumseq
          whenever error continue
          fetch c_cts00m42_009 into lr_retorno.segnumdig
          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar o Numero do Segurado / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if

          #-----------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------

          open c_cts00m42_010 using lr_retorno.segnumdig
          whenever error continue
          fetch c_cts00m42_010 into lr_retorno.segnom ,
                                    lr_retorno.dddcod ,
                                    lr_retorno.teltxt
          whenever error stop

          let lr_retorno.teltxt = "(", lr_retorno.dddcod clipped, ")", lr_retorno.teltxt clipped

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar os Dados do Segurado / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if


          #-----------------------------------------------
          # Recupera os Dados do Veiculo
          #-----------------------------------------------

          open c_cts00m42_011 using lr_param.succod    ,
                                    lr_param.aplnumdig ,
                                    lr_param.itmnumdig ,
                                    lr_retorno.dctnumseq
          whenever error continue
          fetch c_cts00m42_011 into lr_retorno.vclcoddig  ,
                                    lr_retorno.vclanofbc  ,
                                    lr_retorno.vclanomdl  ,
                                    lr_retorno.vcllicnum  ,
                                    lr_retorno.vclchsinc  ,
                                    lr_retorno.vclchsfnl  ,
                                    lr_retorno.vclmrccod  ,
                                    lr_retorno.vcltipcod  ,
                                    lr_retorno.vclmdlnom  ,
                                    lr_retorno.vclmrcnom  ,
                                    lr_retorno.vcltipnom

          whenever error stop

          let lr_retorno.vclchs = lr_retorno.vclchsinc clipped , lr_retorno.vclchsfnl clipped

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar os Dados do Veiculo / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if

          #-----------------------------------------------
          # Recupera a Cor do Veiculo
          #-----------------------------------------------

          open c_cts00m42_012 using lr_param.vclcorcod
          whenever error continue
          fetch c_cts00m42_012 into lr_retorno.vclcordes


          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar a Cor de Veiculo / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if


          return  lr_retorno.segnom
                 ,lr_retorno.teltxt
                 ,lr_retorno.vclmrcnom
                 ,lr_retorno.vclmdlnom
                 ,lr_retorno.vcltipnom
                 ,lr_retorno.vclchs
                 ,lr_retorno.vcllicnum
                 ,lr_retorno.vclanofbc
                 ,lr_retorno.vclanomdl
                 ,lr_retorno.vclcordes


end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_dados_veiculo_azul(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   succod       like datrligapol.succod      ,
   ramcod       like datrligapol.ramcod      ,
   aplnumdig    like datrligapol.aplnumdig   ,
   itmnumdig    like datrligapol.itmnumdig   ,
   edsnumref    like datrligapol.edsnumref   ,
   vclcorcod    like datmservico.vclcorcod
end record


define lr_retorno record
   resultado    smallint                     ,
   mensagem     char(60)                     ,
   doc_handle   integer                      ,
   segnom       like gsakseg.segnom          ,
   dddcod       like gsakend.dddcod          ,
   teltxt       like gsakend.teltxt          ,
   vclcoddig    like abbmveic.vclcoddig      ,
   vclanofbc    like abbmveic.vclanofbc      ,
   vclanomdl    like abbmveic.vclanomdl      ,
   vcllicnum    like abbmveic.vcllicnum      ,
   vclchsinc    like abbmveic.vclchsinc      ,
   vclchsfnl    like abbmveic.vclchsfnl      ,
   vclmrccod    like agbkveic.vclmrccod      ,
   vcltipcod    like agbkveic.vcltipcod      ,
   vclmdlnom    like agbkveic.vclmdlnom      ,
   vclmrcnom    like agbkmarca.vclmrcnom     ,
   vcltipnom    like agbktip.vcltipnom       ,
   vclcordes    char(10)                     ,
   vclchs       char(20)
end record


          #-----------------------------------------------
          # Recupera o Codigo do Documento
          #-----------------------------------------------

          call cts42g00_doc_handle(lr_param.succod   ,
                                   lr_param.ramcod   ,
                                   lr_param.aplnumdig,
                                   lr_param.itmnumdig,
                                   lr_param.edsnumref)
          returning lr_retorno.resultado,
                    lr_retorno.mensagem ,
                    lr_retorno.doc_handle


          #-----------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------

          call cts38m00_extrai_dados_seg(lr_retorno.doc_handle)
          returning lr_retorno.segnom,
                    lr_retorno.teltxt


          #-----------------------------------------------
          # Recupera os Dados do Veiculo
          #-----------------------------------------------

          call cts38m00_extrai_dados_veicul(lr_retorno.doc_handle)
          returning lr_retorno.vclmrcnom,
                    lr_retorno.vcltipnom,
                    lr_retorno.vclmdlnom,
                    lr_retorno.vclchs   ,
                    lr_retorno.vcllicnum,
                    lr_retorno.vclanofbc,
                    lr_retorno.vclanomdl

          #-----------------------------------------------
          # Recupera a Cor do Veiculo
          #-----------------------------------------------

          open c_cts00m42_012 using lr_param.vclcorcod
          whenever error continue
          fetch c_cts00m42_012 into lr_retorno.vclcordes


          whenever error stop

          if sqlca.sqlcode <> 0 then
            error 'Erro ao Recuperar a Cor de Veiculo / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          end if


          return  lr_retorno.segnom
                 ,lr_retorno.teltxt
                 ,lr_retorno.vclmrcnom
                 ,lr_retorno.vclmdlnom
                 ,lr_retorno.vcltipnom
                 ,lr_retorno.vclchs
                 ,lr_retorno.vcllicnum
                 ,lr_retorno.vclanofbc
                 ,lr_retorno.vclanomdl
                 ,lr_retorno.vclcordes


end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_dados_veiculo_itau(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   succod       like datrligapol.succod      ,
   ramcod       like datrligapol.ramcod      ,
   aplnumdig    like datrligapol.aplnumdig   ,
   itmnumdig    like datrligapol.itmnumdig   ,
   edsnumref    like datrligapol.edsnumref
end record


define lr_retorno record
   resultado    smallint                     ,
   mensagem     char(60)                     ,
   doc_handle   integer                      ,
   segnom       like gsakseg.segnom          ,
   dddcod       like gsakend.dddcod          ,
   teltxt       like gsakend.teltxt          ,
   vclcoddig    like abbmveic.vclcoddig      ,
   vclanofbc    smallint                     ,
   vclanomdl    smallint                     ,
   vcllicnum    like abbmveic.vcllicnum      ,
   vclchsinc    like abbmveic.vclchsinc      ,
   vclchsfnl    like abbmveic.vclchsfnl      ,
   vclmrccod    like agbkveic.vclmrccod      ,
   vcltipcod    like agbkveic.vcltipcod      ,
   vclmdlnom    like agbkveic.vclmdlnom      ,
   vclmrcnom    like agbkmarca.vclmrcnom     ,
   vcltipnom    like agbktip.vcltipnom       ,
   vclcordes    char(10)                     ,
   vclchs       char(20)
end record


          #-----------------------------------------------
          # Recupera os Dados do Itau
          #-----------------------------------------------

          call cty22g00_rec_dados_itau(33                ,
                                       lr_param.ramcod   ,
                                       lr_param.aplnumdig,
                                       lr_param.edsnumref,
                                       lr_param.itmnumdig)
          returning lr_retorno.resultado,
                    lr_retorno.mensagem

          #-----------------------------------------------
          # Recupera os Dados do Segurado
          #-----------------------------------------------


          let lr_retorno.segnom = g_doc_itau[1].segnom
          let lr_retorno.teltxt = "(", g_doc_itau[1].segresteldddnum clipped , ")",  g_doc_itau[1].segrestelnum clipped


          #-----------------------------------------------
          # Recupera os Dados do Veiculo
          #-----------------------------------------------


           let lr_retorno.vclmrcnom = g_doc_itau[1].autfbrnom
           let lr_retorno.vcltipnom = g_doc_itau[1].autlnhnom
           let lr_retorno.vclmdlnom = g_doc_itau[1].autmodnom
           let lr_retorno.vclchs    = g_doc_itau[1].autchsnum
           let lr_retorno.vcllicnum = g_doc_itau[1].autplcnum
           let lr_retorno.vclanofbc = g_doc_itau[1].autfbrano
           let lr_retorno.vclanomdl = g_doc_itau[1].autmodano

          #-----------------------------------------------
          # Recupera a Cor do Veiculo
          #-----------------------------------------------

          let lr_retorno.vclcordes = g_doc_itau[1].autcornom


          return  lr_retorno.segnom
                 ,lr_retorno.teltxt
                 ,lr_retorno.vclmrcnom
                 ,lr_retorno.vclmdlnom
                 ,lr_retorno.vcltipnom
                 ,lr_retorno.vclchs
                 ,lr_retorno.vcllicnum
                 ,lr_retorno.vclanofbc
                 ,lr_retorno.vclanomdl
                 ,lr_retorno.vclcordes


end function

#-----------------------------------------------------------------------------
function cts00m42_monta_mensagem(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   atdsrvnum  like datmservico.atdsrvnum     ,
   atdsrvano  like datmservico.atdsrvano     ,
   atdsrvorg  like datmservico.atdsrvorg     ,
   c24solnom  like datmservico.c24solnom     ,
   atddat     like datmservico.atddat        ,
   atdhor     like datmservico.atdhor        ,
   atddfttxt  like datmservico.atddfttxt     ,
   segnom     like gsakseg.segnom            ,
   teltxt     like gsakend.teltxt            ,
   celtxt     like gsakend.teltxt            ,
   srvtxt     like gsakend.teltxt            ,
   vclmrcnom  like agbkmarca.vclmrcnom       ,
   vcltipnom  like agbktip.vcltipnom         ,
   vclmdlnom  like agbkveic.vclmdlnom        ,
   vclchs     char(20)                       ,
   vcllicnum  like abbmveic.vcllicnum        ,
   vclanofbc  char(10)                       ,
   vclanomdl  char(10)                       ,
   vclcordes  char(10)                       ,
   cappstnom  like avgkcappst.cappstnom
end record

define lr_retorno record
	mensagem  char(30000)
end record

initialize lr_retorno.* to null


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          let lr_retorno.mensagem = " Dados de Remocao: ","<br><br>"
                                   ,"Numero do Servico: "     , lr_param.atdsrvorg, "/",
                                                                lr_param.atdsrvnum using '<<<&&&&&&&',"-",
                                                                lr_param.atdsrvano using '&&'        ,"<br>"
                                   ,"Solicitante: "           , lr_param.c24solnom clipped ,"<br>"
                                   ,"Data do Atendimento: "   , lr_param.atddat            ,"<br>"
                                   ,"Horario de Atendimento: ", lr_param.atdhor            ,"<br>"
                                   ,"Problema: "              , lr_param.atddfttxt clipped ,"<br><br>"
                                   ,"Dados do Segurado: ","<br><br>"
                                   ,"Nome do Segurado: "      , lr_param.segnom clipped    ,"<br>"
                                   ,"Telefone Contato: "      , lr_param.srvtxt clipped    ,"<br>"
                                   ,"Telefone Celular: "      , lr_param.celtxt clipped    ,"<br>"
                                   ,"Telefone do Segurado: "  , lr_param.teltxt clipped    ,"<br><br>"
                                   ,"Dados do Veiculo: ","<br><br>"
                                   ,"Marca: "                 , lr_param.vclmrcnom clipped ,"<br>"
                                   ,"Tipo: "                  , lr_param.vcltipnom clipped ,"<br>"
                                   ,"Modelo: "                , lr_param.vclmdlnom clipped ,"<br>"
                                   ,"Chassi: "                , lr_param.vclchs    clipped ,"<br>"
                                   ,"Placa: "                 , lr_param.vcllicnum clipped ,"<br>"
                                   ,"Fab/Mod: "               , lr_param.vclanofbc clipped ,"/", lr_param.vclanomdl clipped, "<br>"
                                   ,"Cor: "                   , lr_param.vclcordes clipped ,"<br><br>"
                                   ,"Local de Destino: ","<br><br>"
                                   ,"Nome: "                  , lr_param.cappstnom clipped

          return lr_retorno.mensagem


end function

#-----------------------------------------------------------------------------
function cts00m42_dispara_email(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   atdsrvnum          like datmservico.atdsrvnum     ,
   atdsrvano          like datmservico.atdsrvano     ,
   c24astdes          like datkassunto.c24astdes     ,
   tipo               char(01)                       ,
   mensagem           char(32766)                    ,
   atdcenelrcoiendnom like avgmcappstend.atdcenelrcoiendnom
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


    let lr_mail.de     = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para  = lr_param.atdcenelrcoiendnom
    let lr_mail.cc     = ""
    let lr_mail.cc    = "Leva.Traz@portoseguro.com.br"
    let lr_mail.cco    = ""
    case lr_param.tipo
    	 when "E"
         let lr_mail.assunto = lr_param.c24astdes clipped, " Servico: ", lr_param.atdsrvnum, "-", lr_param.atdsrvano
       when "C"
       	 let lr_mail.assunto = "Cancelamento do ", lr_param.c24astdes clipped," Servico: ", lr_param.atdsrvnum, "-", lr_param.atdsrvano
    end case

    let lr_mail.mensagem  = lr_param.mensagem
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"
    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_mail_send1 (lr_mail.*)
       returning l_erro
                ,msg_erro
    {let lr_mail.comando = ' echo "', lr_mail.mensagem clipped ,
                          '" | send_email.sh ',
                          ' -r ' ,lr_mail.de          clipped,
                          ' -a ' ,lr_mail.para        clipped,
                          ' -cc ',lr_mail.cc          clipped,
                          ' -s "',lr_mail.assunto     clipped, '" '
    run lr_mail.comando
      returning lr_mail.ret}


    return l_erro


end function

#-----------------------------------------------------------------------------
function cts00m42_valida_problema(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datkassunto.c24astcod ,
   c24pbmcod like datkpbm.c24pbmcod     ,
   c24pbmdes like datkpbm.c24pbmdes
end record

define lr_retorno record
   cponom       like iddkdominio.cponom      ,
   c24pbmcod    like datkpbm.c24pbmcod       ,
   c24pbmdes    like datkpbm.c24pbmdes
end record

initialize lr_retorno.* to null

    if lr_param.c24astcod = "SLV" or
    	 lr_param.c24astcod = "SLT" then

    	 if m_prep_sql <> true or
          m_prep_sql is null then
          call cts00m42_prepare()
       end if


       if lr_param.c24astcod = "SLV" then
            let lr_retorno.cponom = "cts00m42_prob_slv"
       else
            let lr_retorno.cponom = "cts00m42_prob_slt"
       end if

       #-----------------------------------------------
       # Recupera o Problema do Assunto
       #-----------------------------------------------

       open c_cts00m42_005 using lr_retorno.cponom
       whenever error continue
       fetch c_cts00m42_005 into lr_retorno.c24pbmcod

       whenever error stop

       if sqlca.sqlcode <> 0 then
         error 'Erro ao Recuperar o Problema / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       else

       	  #-----------------------------------------------
       	  # Recupera as Descricoes do Problema
       	  #-----------------------------------------------

       	  open c_cts00m42_016 using lr_retorno.c24pbmcod
       	  whenever error continue
       	  fetch c_cts00m42_016 into lr_retorno.c24pbmdes
       	  whenever error stop

       	  if sqlca.sqlcode <> 0 then
       	    error 'Erro ao Recuperar o Agrupamento do Problema 2 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       	  else
       	  	 if lr_param.c24pbmcod <> lr_retorno.c24pbmcod then
       	  	 	   let lr_param.c24pbmcod = lr_retorno.c24pbmcod
       	  	 	   let lr_param.c24pbmdes = lr_retorno.c24pbmdes
       	  	 end if
       	  end if
       end if

    end if

    return lr_param.c24pbmcod, lr_param.c24pbmdes



end function

#-----------------------------------------------------------------------------
function cts00m42_recupera_telefone(lr_param)
#-----------------------------------------------------------------------------

define lr_param record
   c24astcod like datkassunto.c24astcod ,
   atdsrvnum like datmservico.atdsrvnum ,
   atdsrvano like datmservico.atdsrvano
end record

define lr_retorno record
   dddcod       like datmlcl.dddcod        ,
   lcltelnum    like datmlcl.lcltelnum     ,
   celteldddcod like datmlcl.celteldddcod  ,
   celtelnum    like datmlcl.celtelnum     ,
   c24endtip    like datmlcl.c24endtip     ,
   celtxt       like gsakend.teltxt        ,
   srvtxt       like gsakend.teltxt
end record

initialize lr_retorno.* to null

if m_prep_sql <> true or
   m_prep_sql is null then
   call cts00m42_prepare()
end if



    case lr_param.c24astcod
       when "SLV"
       	  let lr_retorno.c24endtip = 1
       when "S10"
       	  let lr_retorno.c24endtip = 1
       when "K10"
          let lr_retorno.c24endtip = 1
       when "I30"
          let lr_retorno.c24endtip = 1
       otherwise
          let lr_retorno.c24endtip = 2
    end case


    #-----------------------------------------------
    # Recupera os Telefones do Servico
    #-----------------------------------------------

    open c_cts00m42_017 using lr_param.atdsrvnum   ,
                              lr_param.atdsrvano   ,
                              lr_retorno.c24endtip
    whenever error continue
    fetch c_cts00m42_017 into lr_retorno.dddcod        ,
                              lr_retorno.lcltelnum     ,
                              lr_retorno.celteldddcod  ,
                              lr_retorno.celtelnum

    whenever error stop

    if sqlca.sqlcode <> 0 then
      error 'Erro ao Recuperar os telefones / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
    end if


    let lr_retorno.srvtxt = "(", lr_retorno.dddcod clipped, ")", lr_retorno.lcltelnum   clipped
    let lr_retorno.celtxt = "(", lr_retorno.celteldddcod clipped, ")", lr_retorno.celtelnum  clipped

    return  lr_retorno.srvtxt,
            lr_retorno.celtxt


end function
