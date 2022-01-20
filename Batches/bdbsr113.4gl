#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr113                                                       #
# Analista Resp.: Marcos Federicce                                            #
# Desenvolvimento: Norton Nery (Meta)                                         #
# PSI......: 0214566 - Relatorios Analitico De Solicitacao de Apoio           #
# --------------------------------------------------------------------------- #
# Liberacao...: 10/07/2007                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/05/2015 Fornax, RCP     FX-080515  Incluir coluna data no relatorio.     #
#-----------------------------------------------------------------------------#
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_path      char(100)
define m_path_txt  char(100)
define m_rel1      char(100)

define m_data_inicio date
define m_data_fim    date

main

    call fun_dba_abre_banco("CT24HS")

    call bdbsr113_busca_path()

    call bdbsr113_prepare()

    call cts40g03_exibe_info("I", "bdbsr113")

    set isolation to dirty read

    call bdbsr113()

    call cts40g03_exibe_info("F", "bdbsr113")

end main

#------------------------------#
function bdbsr113_busca_path()
#------------------------------#

    define l_data     date
    define l_dataarq  char(8)

    let l_data = today
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    let m_path = null
    let m_rel1 = null

    # Chama a funcao para buscar o caminho do arquivo de log
    let m_path = f_path("DBS", "LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr113.log"

    call startlog(m_path)

    # Chama a funcao para buscar o caminho do arquivo de relatorio
    let m_path = f_path("DBS", "RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_rel1 = m_path clipped, "/bdbsr113.xls"
    let m_path_txt = m_path clipped, "/bdbsr113_", l_dataarq, ".txt"

    ###let m_rel1 = "bdbsr113.xls"

end function

#---------------------------#
function bdbsr113_prepare()
#---------------------------#

    define l_sql char(1000)
    define l_data_atual date,
           l_hora_atual datetime hour to minute

    # Obter a data e hora do banco
    call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual

    # Calculo das datas dos ultimos 7 dias (semana anterior) ou recebida por parametro
    let m_data_inicio = arg_val(1)
    let m_data_fim = arg_val(2)

    if m_data_inicio is null or m_data_fim is null then
        let m_data_inicio = l_data_atual - 1 units month
        let m_data_fim = l_data_atual - 1 units day
    end if

    # Servicos os servicos de apoio
    let l_sql = " select pbm.atdsrvnum,pbm.atdsrvano ",
		       ",srv.atddat", #--> FX-080515
                  " from datrsrvpbm pbm, ",
                       " datmservico srv, ",
                       " datmsrvacp  acp ",
                 " where pbm.c24pbmseq = 1",    -- PROBLEMA DA ABERTURA
                   " and pbm.c24pbmcod in (select c24pbmcod ",
                          "  from datkpbm ",
                         " where c24pbmgrpcod = 20) ",--GRUPO DE PROBLEMA APOIO
                   " and pbm.atdsrvnum = srv.atdsrvnum ",
                   " and pbm.atdsrvano = srv.atdsrvano ",
                   " and srv.atddat between '",
                         m_data_inicio,"' and '", m_data_fim,"'",
                   " and srv.atdsrvorg in (1,4) " ,
		   " and srv.atdsrvnum = acp.atdsrvnum ",
		   " and srv.atdsrvano = acp.atdsrvano ",
		   " and acp.atdetpcod = 4 ",
		   " and acp.atdsrvseq = (select max(atdsrvseq) ",
		   " from datmsrvacp acp2 ",
		   " where acp2.atdsrvnum = srv.atdsrvnum ",
		   " and   acp2.atdsrvano = srv.atdsrvano) "

    prepare pbdbsr113010 from l_sql
    declare cbdbsr113010 cursor for pbdbsr113010

    # Primeira Ligacao do Servico
    let l_sql = " select min(lignum) ",
                  " from datrligsrv ",
                 " where datrligsrv.atdsrvnum = ? ",
                   " and datrligsrv.atdsrvano = ? "

    prepare pbdbsr113020 from l_sql
    declare cbdbsr113020 cursor for pbdbsr113020

    # Primeira Ligacao do Servico por apolice
    let l_sql = " select datr.succod, " ,
                       " datr.ramcod, ",
                       " datr.aplnumdig, ",
                       " datr.itmnumdig ",
                  " from datrligapol datr",
                 " where datr.lignum  = ? "

    prepare pbdbsr113030 from l_sql
    declare cbdbsr113030 cursor for pbdbsr113030

    # busca servico pai por apolice
    let l_sql = " select srv.atdsrvnum,srv.atdsrvano  ",
                  " from datrligapol apl, ",
                       " datrligsrv srvlig, ",
                       " datmservico srv ",
                 " where apl.succod  = ? " ,
                   " and apl.ramcod  = ? ",
                   " and apl.aplnumdig = ? ",
                   " and apl.itmnumdig = ? ",
                   " and apl.lignum    = srvlig.lignum ",
                   " and srv.atdsrvnum = srvlig.atdsrvnum ",
                   " and srv.atdsrvano = srvlig.atdsrvano ",
                   " and srvlig.lignum < ? ",
                   " and srv.atdsrvorg in (1,4,5) ",
                   " order by srv.atdsrvano desc, srv.atdsrvnum desc "

    prepare pbdbsr113040 from l_sql
    declare cbdbsr113040 cursor for pbdbsr113040

    # Primeira Ligacao do Servico por proposta
    let l_sql = " select prp.prporg, " ,
                       " prp.prpnumdig ",
                  " from datrligprp prp",
                 " where prp.lignum  = ? "

    prepare pbdbsr113050 from l_sql
    declare cbdbsr113050 cursor for pbdbsr113050

    # busca servico pai por proposta
    let l_sql = " select srv.atdsrvnum,srv.atdsrvano  ",
                  " from datrligprp  prp, ",
                       " datrligsrv srvlig, ",
                       " datmservico srv ",
                   " where prp.prporg  = ? ",
                   " and prp.prpnumdig = ? ",
                   " and prp.lignum    = srvlig.lignum ",
                   " and srv.atdsrvnum = srvlig.atdsrvnum ",
                   " and srv.atdsrvano = srvlig.atdsrvano ",
                   " and srvlig.lignum <= ? ",
                   " and srv.atdsrvorg in (1,4,5) ",
                   " order by srv.atdsrvano desc, srv.atdsrvnum desc "

    prepare pbdbsr113060 from l_sql
    declare cbdbsr113060 cursor for pbdbsr113060

    # Primeira Ligacao do Servico sem apolice
    let l_sql = " select apl.ligdcttip, " ,
                       " apl.ligdctnum  ",
                  " from datrligsemapl apl",
                 " where apl.lignum  = ? "

    prepare pbdbsr113070 from l_sql
    declare cbdbsr113070 cursor for pbdbsr113070

    # busca servico pai sem apolice
    let l_sql = " select  srv.atdsrvnum,srv.atdsrvano ",
                  " from datrligsemapl apl, ",
                       " datrligsrv srvlig, ",
                       " datmservico srv ",
                   " where apl.ligdcttip = ? ",
                   " and apl.ligdctnum   = ? ",
                   " and apl.lignum    = srvlig.lignum ",
                   " and srv.atdsrvnum = srvlig.atdsrvnum ",
                   " and srv.atdsrvano = srvlig.atdsrvano ",
                   " and srvlig.lignum < ? ",
                   " and srv.atdsrvorg in (1,4,5) ",
                   " order by srv.atdsrvano desc, srv.atdsrvnum desc "

    prepare pbdbsr113080 from l_sql
    declare cbdbsr113080 cursor for pbdbsr113080

    # Primeira Ligacao do Servico  por cpf
    let l_sql = " select lig.cgccpfnum, " ,
                       " lig.cgcord, ",
                       " lig.cgccpfdig ",
                  " from datrligcgccpf lig",
                 " where lig.lignum  = ? "

    prepare pbdbsr113090 from l_sql
    declare cbdbsr113090 cursor for pbdbsr113090

    # busca servico pai por cpf
    let l_sql = " select  srv.atdsrvnum,srv.atdsrvano ",
                  " from datrligcgccpf lig, ",
                       " datrligsrv srvlig, ",
                       " datmservico srv ",
                 " where lig.cgccpfnum = ? ",
                   " and lig.cgcord    = ? ",
                   " and lig.cgccpfdig = ? ",
                   " and lig.lignum    = srvlig.lignum ",
                   " and srv.atdsrvnum = srvlig.atdsrvnum ",
                   " and srv.atdsrvano = srvlig.atdsrvano ",
                   " and srvlig.lignum < ? ",
                   " and srv.atdsrvorg in (1,4,5) ",
                   " order by srv.atdsrvano desc, srv.atdsrvnum desc "

    prepare pbdbsr113100 from l_sql
    declare cbdbsr113100 cursor for pbdbsr113100

    # Primeira Ligacao do Servico    por matricula
    let l_sql = " select mat.funmat, " ,
                       " mat.empcod, ",
                       " mat.usrtip ",
                  " from  datrligmat mat ",
                 " where mat.lignum  = ? "

    prepare pbdbsr113110 from l_sql
    declare cbdbsr113110 cursor for pbdbsr113110

    # busca servico pai por matricula
    let l_sql = " select  srv.atdsrvnum,srv.atdsrvano ",
                  " from  datrligmat mat, ",
                       "  datrligsrv srvlig, ",
                       "  datmservico srv ",
                 " where mat.funmat    = ? ",
                   " and mat.empcod    = ? ",
                   " and mat.usrtip    = ? ",
                   " and mat.lignum    = srvlig.lignum ",
                   " and srv.atdsrvnum = srvlig.atdsrvnum ",
                   " and srv.atdsrvano = srvlig.atdsrvano ",
                   " and srvlig.lignum < ? ",
                   " and srv.atdsrvorg in (1,4,5) ",
                   " order by srv.atdsrvano desc, srv.atdsrvnum desc "

    prepare pbdbsr113120 from l_sql
    declare cbdbsr113120 cursor for pbdbsr113120

    # busca servico pai por matricula
    let l_sql = " select  s.atdsrvnum,   s.atdsrvano, t.srvtipabvdes, ",
                        " a.asitipabvdes,s.atddfttxt, s.atdsrvorg, ",
                        " s.atdprscod,   v.atdvclsgl, r.srrcoddig, ",
                        " r.srrnom,      r.srrabvnom, p.pstcoddig, ",
                        " p.nomgrr,      d.cpodes ",
                       " from datmservico s, datksrr r,",
                      "    datkveiculo v, dpaksocor p, ",
            " outer datksrvtip t,outer datkasitip a, ",
                        " outer iddkdominio d ",
                        " where s.atdsrvorg   = t.atdsrvorg ",
                        "  and  s.asitipcod   = a.asitipcod ",
                        "  and  s.srrcoddig   = r.srrcoddig ",
                        "  and  s.socvclcod   = v.socvclcod ",
                        "  and  v.pstcoddig   = p.pstcoddig ",
                        "  and  v.socvcltip   = d.cpocod    ",
                        "  and  d.cponom      = 'socvcltip' ",
                        "  and  s.atdsrvorg  in (1,2,3,4,5,6,7,9,12,13) ",
                        "  and  s.atdsrvnum   = ? ",
                        "  and  s.atdsrvano   = ? "

    prepare pbdbsr113140 from l_sql
    declare cbdbsr113140 cursor for pbdbsr113140

    # busca servico por prestador
    let l_sql = " select s.atdsrvnum, ",  -- Numero do Servico apoio
                " s.atdsrvano,   ",  -- Ano do Servico apoio
                " t.srvtipabvdes,",  -- Descricao Abreviada do Servico apoio
                " a.asitipabvdes, ", -- Descr. Abrev. do tipo de Assist. apoio
                " s.atddfttxt, ",    -- Descricao do problema apoio
                " s.atdsrvorg, ",    -- Codigo de Origem apoio
                " p.pstcoddig, ",    -- Codigo do Prestador apoio
                " p.nomgrr ",        -- Nome do Prestador apoio
    " from datmservico s, dpaksocor p, ",
    " outer datksrvtip t, outer datkasitip a ",
    " where s.atdsrvnum = ? ",       -- Servico Apoio
    " and s.atdsrvano   = ? ",       -- Ano Servico Apoio
    " and s.atdprscod   = p.pstcoddig ",
    " and s.atdsrvorg   = t.atdsrvorg ",
    " and s.asitipcod   = a.asitipcod "

    prepare pbdbsr113150 from l_sql
    declare cbdbsr113150 cursor for pbdbsr113150

end function

#-------------------#
function bdbsr113()
#-------------------#

    define l_hora datetime hour to second

    let l_hora = extend(current, hour to second)
    display l_hora, ": Gerando 'Relatorio Analitico'..."

    call bdbsr113_analitico() # Sintetico

    let l_hora = extend(current, hour to second)
    display l_hora, ": Enviando arquivos por e-mail..."
    call bdbsr113_envia_email()

end function

#---------------------------#
function bdbsr113_analitico()
#---------------------------#

 define  lr_dados_orig    record
          atdsrvnum            like datmservico.atdsrvnum,
          atdsrvano            like datmservico.atdsrvano,
          srvtipabvdes         like datksrvtip.srvtipabvdes,
          asitipabvdes         like datkasitip.asitipabvdes,
          atddfttxt            like datmservico.atddfttxt,
          atdsrvorg            like datmservico.atdsrvorg,
          atdprscod            like datmservico.atdprscod,
          atdvclsgl            like datmservico.atdvclsgl,
          srrcoddig            like datksrr.srrcoddig,
          srrnom               like datksrr.srrnom,
          srrabvnom            like datksrr.srrabvnom,
          pstcoddig            like dpaksocor.pstcoddig,
          nomgrr               like dpaksocor.nomgrr,
          cpodes               like iddkdominio.cpodes
  end record

 define  lr_dados_apoio   record
          atdsrvnum            like datmservico.atdsrvnum,
          atdsrvano            like datmservico.atdsrvano,
          srvtipabvdes         like datksrvtip.srvtipabvdes,
          asitipabvdes         like datkasitip.asitipabvdes,
          atddfttxt            like datmservico.atddfttxt,
          atdsrvorg            like datmservico.atdsrvorg,
          atdprscod            like datmservico.atdprscod,
          atdvclsgl            like datmservico.atdvclsgl,
          srrcoddig            like datksrr.srrcoddig,
          srrnom               like datksrr.srrnom,
          srrabvnom            like datksrr.srrabvnom,
          pstcoddig            like dpaksocor.pstcoddig,
          nomgrr               like dpaksocor.nomgrr,
          cpodes               like iddkdominio.cpodes
  end record

  define lr_apoio record
          atdsrvnum        like datrsrvpbm.atdsrvnum,
          atdsrvano        like datrsrvpbm.atdsrvano,
	  atddat           like datmservico.atddat #--> FX-080515
  end record

  define lr_origem record
          atdsrvnum        like datrsrvpbm.atdsrvnum,
          atdsrvano        like datrsrvpbm.atdsrvano
  end record

  define lr_ligsrv  record
          lignum           like datrligsrv.lignum
  end record

  start report bdbsr113_rel1 to m_rel1
  start report bdbsr113_rel1_txt to m_path_txt

  open cbdbsr113010

  foreach cbdbsr113010 into lr_apoio.atdsrvnum,
                            lr_apoio.atdsrvano,
			    lr_apoio.atddat #--> FX-080515

    # busca a primeira ligacao do servico
     open cbdbsr113020 using lr_apoio.atdsrvnum,
                              lr_apoio.atdsrvano

     fetch cbdbsr113020 into lr_ligsrv.lignum
     close cbdbsr113020

    # busca o documento de apolice
     call  bdbsr113_apolice( lr_ligsrv.lignum )
               returning lr_origem.atdsrvnum, lr_origem.atdsrvano

    # busca o documento proposta
     if lr_origem.atdsrvnum is  null then
        call  bdbsr113_proposta( lr_ligsrv.lignum )
               returning lr_origem.atdsrvnum, lr_origem.atdsrvano
     end if

    # busca o documento sem apolice
     if lr_origem.atdsrvnum is  null then
        call  bdbsr113_sem_apolice( lr_ligsrv.lignum )
               returning lr_origem.atdsrvnum, lr_origem.atdsrvano
     end if

    # busca o documento com o cpf
     if lr_origem.atdsrvnum is  null then
        call  bdbsr113_cpf( lr_ligsrv.lignum )
               returning lr_origem.atdsrvnum, lr_origem.atdsrvano
     end if

    # busca o documento com a matricula
     if lr_origem.atdsrvnum is  null then
        call  bdbsr113_matricula( lr_ligsrv.lignum )
               returning lr_origem.atdsrvnum, lr_origem.atdsrvano
     end if

    # Verifica se servico de origem eh o mesmo que de apoio

     if lr_origem.atdsrvnum = lr_apoio.atdsrvnum then
	let lr_origem.atdsrvnum = null
	let lr_origem.atdsrvano = null
        continue foreach
     end if

     if  lr_origem.atdsrvnum is not null then
        #--Gera arquivo de origem do servico
        call  bdbsr113_servicos( lr_origem.atdsrvnum, lr_origem.atdsrvano)
                  returning lr_dados_orig.*

        if lr_dados_orig.atdsrvnum  is null then
            let m_path = "Nao encontrado servico de origem ",
                         lr_origem.atdsrvnum,"-",lr_origem.atdsrvano
            call errorlog(m_path)
        end if

        #--Gera arquivo de servico de apoio
        call  bdbsr113_servicos( lr_apoio.atdsrvnum, lr_apoio.atdsrvano)
                  returning lr_dados_apoio.*

        if lr_dados_apoio.atdsrvnum  is null then
            let m_path = "Nao encontrado servico de apoio ",
                         lr_apoio.atdsrvnum  ,"-",lr_apoio.atdsrvano
            call errorlog(m_path)
        end if

        if lr_dados_apoio.atdsrvnum is null then
	     # busca a primeira ligacao do servico
           open cbdbsr113150 using lr_apoio.atdsrvnum,lr_apoio.atdsrvano
           fetch cbdbsr113150 into lr_dados_apoio.atdsrvnum,
				   lr_dados_apoio.atdsrvano,
				   lr_dados_apoio.srvtipabvdes,
	                           lr_dados_apoio.asitipabvdes,
	                           lr_dados_apoio.atddfttxt,
	                           lr_dados_apoio.atdsrvorg,
	                           lr_dados_apoio.pstcoddig,
	                           lr_dados_apoio.nomgrr
           close cbdbsr113150
	end if

        if lr_dados_orig.atdsrvnum  is not null then
        ## output to report bdbsr113_rel1(lr_dados_orig.*,lr_dados_apoio.*) #--> FX080515
           output to report bdbsr113_rel1(lr_dados_orig.*,lr_dados_apoio.*  #--> FX080515
					                 ,lr_apoio.atddat)  #--> FX080515
           output to report bdbsr113_rel1_txt(lr_dados_orig.*,lr_dados_apoio.*, lr_apoio.atddat)
        end if
      else
        let m_path = "Nao encontrado servico de origem.ligacao : ",
                     lr_ligsrv.lignum
        call errorlog(m_path)
      end if

  end foreach

  close cbdbsr113010

  finish report bdbsr113_rel1
  finish report bdbsr113_rel1_txt

end function

#--------------------------------------------#
report bdbsr113_rel1(lr_rel_orig,lr_rel_apoio)
#--------------------------------------------#

  define  lr_rel_orig      record
        atdsrvnum            like datmservico.atdsrvnum,
        atdsrvano            like datmservico.atdsrvano,
        srvtipabvdes         like datksrvtip.srvtipabvdes,
        asitipabvdes         like datkasitip.asitipabvdes,
        atddfttxt            like datmservico.atddfttxt,
        atdsrvorg            like datmservico.atdsrvorg,
        atdprscod            like datmservico.atdprscod,
        atdvclsgl            like datmservico.atdvclsgl,
        srrcoddig            like datksrr.srrcoddig,
        srrnom               like datksrr.srrnom,
        srrabvnom            like datksrr.srrabvnom,
        pstcoddig            like dpaksocor.pstcoddig,
        nomgrr               like dpaksocor.nomgrr,
        cpodes               like iddkdominio.cpodes
  end record

  define  lr_rel_apoio     record
        atdsrvnum            like datmservico.atdsrvnum,
        atdsrvano            like datmservico.atdsrvano,
        srvtipabvdes         like datksrvtip.srvtipabvdes,
        asitipabvdes         like datkasitip.asitipabvdes,
        atddfttxt            like datmservico.atddfttxt,
        atdsrvorg            like datmservico.atdsrvorg,
        atdprscod            like datmservico.atdprscod,
        atdvclsgl            like datmservico.atdvclsgl,
        srrcoddig            like datksrr.srrcoddig,
        srrnom               like datksrr.srrnom,
        srrabvnom            like datksrr.srrabvnom,
        pstcoddig            like dpaksocor.pstcoddig,
        nomgrr               like dpaksocor.nomgrr,
        cpodes               like iddkdominio.cpodes,
	atddat               like datmservico.atddat #--> FX-080515
  end record

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "Numero do Servico origem",              ASCII(09),
                  "Ano do Servico origem",                ASCII(09),
                  "Descricao Abreviada do Servico origem", ASCII(09),
                 "Descricao Abrevidada do tipo de Assistencia origem",ASCII(09),
                  "Descricao do problema origem",          ASCII(09),
                  "Codigo de Origem ",                    ASCII(09),
                  "Sigla do Veiculo origem ",             ASCII(09),
                  "Codigo do Socorrista origem ",          ASCII(09),
                  "Nome do Socorrista origem ",          ASCII(09),
                  "Nome do Socorrista Abreviado origem ",ASCII(09),
                 "Codigo do Prestador origem",           ASCII(09),
                  "Nome do Prestador origem ",           ASCII(09),
                  "Tipo de Veiculo origem ",             ASCII(09),
                  "Numero do Servico apoio ",              ASCII(09),
                  "Ano do Servico apoio ",                ASCII(09),
                  "Descricao Abreviada do Servico apoio ", ASCII(09),
                 "Descricao Abrevidada do tipo de Assistencia apoio ",ASCII(09),
                  "Descricao do problema apoio ",          ASCII(09),
                  "Codigo de Origem apoio ",             ASCII(09),
                  "Sigla do Veiculo apoio ",             ASCII(09),
                  "Codigo do Socorrista apoio ",          ASCII(09),
                  "Nome do Socorrista apoio ",          ASCII(09),
                  "Nome do Socorrista Abreviado apoio  ",ASCII(09),
                  "Codigo do Prestador apoio ",           ASCII(09),
                  "Nome do Prestador apoio ",           ASCII(09),
                  "Tipo de Veiculo apoio ",             ASCII(09),
                  "Data de Atendimento apoio ",         ASCII(09); #--> FX-080515

            skip 1 line

        on every row

           print lr_rel_orig.atdsrvnum,              ASCII(09),
                 lr_rel_orig.atdsrvano,              ASCII(09),
                 lr_rel_orig.srvtipabvdes,           ASCII(09),
                 lr_rel_orig.asitipabvdes,           ASCII(09),
                 lr_rel_orig.atddfttxt,              ASCII(09),
                 lr_rel_orig.atdsrvorg,              ASCII(09),
                 lr_rel_orig.atdvclsgl,              ASCII(09),
                 lr_rel_orig.srrcoddig,              ASCII(09),
                 lr_rel_orig.srrnom,                 ASCII(09),
                 lr_rel_orig.srrabvnom,              ASCII(09),
                 lr_rel_orig.pstcoddig,              ASCII(09),
                 lr_rel_orig.nomgrr,                 ASCII(09),
                 lr_rel_orig.cpodes,                 ASCII(09),
                 lr_rel_apoio.atdsrvnum,             ASCII(09),
                 lr_rel_apoio.atdsrvano,             ASCII(09),
                 lr_rel_apoio.srvtipabvdes,          ASCII(09),
                 lr_rel_apoio.asitipabvdes,          ASCII(09),
                 lr_rel_apoio.atddfttxt,             ASCII(09),
                 lr_rel_apoio.atdsrvorg,             ASCII(09),
                 lr_rel_apoio.atdvclsgl,             ASCII(09),
                 lr_rel_apoio.srrcoddig,             ASCII(09),
                 lr_rel_apoio.srrnom,                ASCII(09),
                 lr_rel_apoio.srrabvnom,             ASCII(09),
                 lr_rel_apoio.pstcoddig,             ASCII(09),
                 lr_rel_apoio.nomgrr,                ASCII(09),
                 lr_rel_apoio.cpodes,                ASCII(09),
                 lr_rel_apoio.atddat,                ASCII(09);

skip 1 line

end report

#-------------------------------#
function bdbsr113_envia_email()
#-------------------------------#

   define l_assunto     char(200),
          l_comando     char(200),
          l_erro_envio  integer,
          l_arquivos    char(300)

   # Inicializacao das variaveis
   let l_comando    = null
   let l_erro_envio = null
   let l_arquivos   = null
   let l_assunto    = "Relatorios de Apoio aos Prestadores (", m_data_inicio, " a ", m_data_fim, ")"

   # Compacta arquivos
   let l_comando = "gzip -f ", m_rel1 clipped
   run l_comando

   let m_rel1 = m_rel1 clipped, ".gz"

   let l_arquivos = m_rel1 clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR113", l_assunto clipped, l_arquivos clipped)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email (ctx22g00) - ", l_assunto, " ",l_arquivos
       else
           display "Nao existe email cadastrado para o modulo - bdbsr113"
       end if
   end if

end function

#-------------------------------------#
function bdbsr113_apolice(param_lignum)
#-------------------------------------#

  define param_lignum like datrligsrv.lignum

  define lr_ligapol record
     succod           like datrligapol.succod,
     ramcod           like datrligapol.ramcod,
     aplnumdig        like datrligapol.aplnumdig,
     itmnumdig        like datrligapol.itmnumdig
  end record

 define lr_aux record
    atdsrvnum    like datrsrvpbm.atdsrvnum,
    atdsrvano    like datrsrvpbm.atdsrvano
 end record

  # busca a primeira ligacao do servico

  open cbdbsr113030 using param_lignum

  fetch cbdbsr113030 into lr_ligapol.succod,
                          lr_ligapol.ramcod,
                          lr_ligapol.aplnumdig,
                          lr_ligapol.itmnumdig

  if sqlca.sqlcode <> notfound then
     Open cbdbsr113040 using lr_ligapol.succod,
                             lr_ligapol.ramcod,
                             lr_ligapol.aplnumdig,
                             lr_ligapol.itmnumdig,
                             param_lignum

     fetch cbdbsr113040 into lr_aux.*

     close cbdbsr113040
   else

     initialize lr_ligapol.*  to null

  end if

  close cbdbsr113030

  return lr_aux.atdsrvnum, lr_aux.atdsrvano

end function

#---------------------------------------#
function bdbsr113_proposta(param_lignum)
#---------------------------------------#

 define param_lignum like datrligsrv.lignum

 define lr_aux record
    atdsrvnum    like datrsrvpbm.atdsrvnum,
    atdsrvano    like datrsrvpbm.atdsrvano
 end record

 define lr_prp  record
    prporg      like datrligprp.prporg,
    prpnumdig   like datrligprp.prpnumdig
 end record

# busca a primeira ligacao do servico
  open cbdbsr113050 using param_lignum

  fetch cbdbsr113050 into lr_prp.prporg,
                          lr_prp.prpnumdig

   if sqlca.sqlcode <> notfound then
      Open cbdbsr113060 using lr_prp.prporg,
                              lr_prp.prpnumdig,
                              param_lignum

      fetch cbdbsr113060 into lr_aux.*
      close cbdbsr113060
   else
     initialize lr_aux.*  to null
  end if

  close cbdbsr113050

  return lr_aux.atdsrvnum, lr_aux.atdsrvano

end function

#-----------------------------------------#
function bdbsr113_sem_apolice(param_lignum)
#-----------------------------------------#

 define param_lignum like datrligsrv.lignum

 define lr_aux record
    atdsrvnum    like datrsrvpbm.atdsrvnum,
    atdsrvano    like datrsrvpbm.atdsrvano
 end record

 define lr_semapl  record
    ligdcttip        like datrligsemapl.ligdcttip,
    ligdctnum        like datrligsemapl.ligdctnum
 end record

# busca a primeira ligacao do servico sem apolice
  open cbdbsr113070 using param_lignum

  fetch cbdbsr113070 into lr_semapl.ligdcttip,
                          lr_semapl.ligdctnum

   if sqlca.sqlcode <> notfound then
      Open cbdbsr113080 using lr_semapl.ligdcttip,
                              lr_semapl.ligdctnum,
                              param_lignum

      fetch cbdbsr113080 into lr_aux.atdsrvnum,
                              lr_aux.atdsrvano

      close cbdbsr113080
   else
     initialize lr_aux.*  to null
  end if

  close cbdbsr113070

  return lr_aux.atdsrvnum, lr_aux.atdsrvano

end function

#---------------------------------#
function bdbsr113_cpf(param_lignum)
#---------------------------------#

 define param_lignum like datrligsrv.lignum

 define lr_cgccpf  record
         cgccpfnum        like datrligcgccpf.cgccpfnum,
         cgcord           like datrligcgccpf.cgcord,
         cgccpfdig        like datrligcgccpf.cgccpfdig
 end record

 define lr_aux record
    atdsrvnum    like datrsrvpbm.atdsrvnum,
    atdsrvano    like datrsrvpbm.atdsrvano
 end record

# busca a primeira ligacao do servico sem apolice
  open cbdbsr113090 using param_lignum

  fetch cbdbsr113090 into lr_cgccpf.*

  if sqlca.sqlcode <> notfound then
     Open cbdbsr113100 using lr_cgccpf.cgccpfnum,
                             lr_cgccpf.cgcord,
                             lr_cgccpf.cgccpfdig,
                             param_lignum

     fetch cbdbsr113100 into lr_aux.*
     close cbdbsr113100
   else
    initialize lr_aux.*  to null
  end if

  close cbdbsr113090

  return lr_aux.atdsrvnum, lr_aux.atdsrvano

end function

#---------------------------------------#
function bdbsr113_matricula(param_lignum)
#---------------------------------------#

 define param_lignum like datrligsrv.lignum

 define lr_ligmat  record
    funmat       like datrligmat.funmat,
    empcod       like datrligmat.empcod,
    usrtip       like datrligmat.usrtip
 end record

 define lr_aux    record
    atdsrvnum    like datrsrvpbm.atdsrvnum,
    atdsrvano    like datrsrvpbm.atdsrvano
  end record

# busca a primeira ligacao do servico sem apolice
  open cbdbsr113110 using param_lignum

  fetch cbdbsr113110 into lr_ligmat.funmat,
                          lr_ligmat.empcod,
                          lr_ligmat.usrtip

  if sqlca.sqlcode <> notfound then
     Open cbdbsr113120 using lr_ligmat.funmat,
                             lr_ligmat.empcod,
                             lr_ligmat.usrtip,
                             param_lignum

     fetch cbdbsr113120 into lr_aux.atdsrvnum,
                             lr_aux.atdsrvano
     close cbdbsr113120
   else
    initialize lr_aux.*  to null
  end if

  close cbdbsr113110

  return lr_aux.atdsrvnum,lr_aux.atdsrvano

end function

#------------------------------------------------------------#
function bdbsr113_servicos(lparam_atdsrvnum,lparam_atdsrvano)
#------------------------------------------------------------#

  define lparam_atdsrvnum        like datrsrvpbm.atdsrvnum,
         lparam_atdsrvano        like datrsrvpbm.atdsrvano

  define  lr_dados    record
          atdsrvnum            like datmservico.atdsrvnum,
          atdsrvano            like datmservico.atdsrvano,
          srvtipabvdes         like datksrvtip.srvtipabvdes,
          asitipabvdes         like datkasitip.asitipabvdes,
          atddfttxt            like datmservico.atddfttxt,
          atdsrvorg            like datmservico.atdsrvorg,
          atdprscod            like datmservico.atdprscod,
          atdvclsgl            like datmservico.atdvclsgl,
          srrcoddig            like datksrr.srrcoddig,
          srrnom               like datksrr.srrnom,
          srrabvnom            like datksrr.srrabvnom,
          pstcoddig            like dpaksocor.pstcoddig,
          nomgrr               like dpaksocor.nomgrr,
          cpodes               like iddkdominio.cpodes
  end record

  initialize lr_dados.*  to null

# busca a primeira ligacao do servico sem apolice
  open cbdbsr113140 using lparam_atdsrvnum, lparam_atdsrvano

  fetch cbdbsr113140 into lr_dados.*

  if sqlca.sqlcode =  notfound then
    initialize lr_dados.*  to null
  end if

  close cbdbsr113140

  return lr_dados.*

end function


#--------------------------------------------#
report bdbsr113_rel1_txt(lr_rel_orig,lr_rel_apoio)
#--------------------------------------------#

  define  lr_rel_orig      record
        atdsrvnum            like datmservico.atdsrvnum,
        atdsrvano            like datmservico.atdsrvano,
        srvtipabvdes         like datksrvtip.srvtipabvdes,
        asitipabvdes         like datkasitip.asitipabvdes,
        atddfttxt            like datmservico.atddfttxt,
        atdsrvorg            like datmservico.atdsrvorg,
        atdprscod            like datmservico.atdprscod,
        atdvclsgl            like datmservico.atdvclsgl,
        srrcoddig            like datksrr.srrcoddig,
        srrnom               like datksrr.srrnom,
        srrabvnom            like datksrr.srrabvnom,
        pstcoddig            like dpaksocor.pstcoddig,
        nomgrr               like dpaksocor.nomgrr,
        cpodes               like iddkdominio.cpodes
  end record

  define  lr_rel_apoio     record
        atdsrvnum            like datmservico.atdsrvnum,
        atdsrvano            like datmservico.atdsrvano,
        srvtipabvdes         like datksrvtip.srvtipabvdes,
        asitipabvdes         like datkasitip.asitipabvdes,
        atddfttxt            like datmservico.atddfttxt,
        atdsrvorg            like datmservico.atdsrvorg,
        atdprscod            like datmservico.atdprscod,
        atdvclsgl            like datmservico.atdvclsgl,
        srrcoddig            like datksrr.srrcoddig,
        srrnom               like datksrr.srrnom,
        srrabvnom            like datksrr.srrabvnom,
        pstcoddig            like dpaksocor.pstcoddig,
        nomgrr               like dpaksocor.nomgrr,
        cpodes               like iddkdominio.cpodes,
	atddat               like datmservico.atddat #--> FX-080515
  end record

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 01

    format
        on every row

           print lr_rel_orig.atdsrvnum,              ASCII(09),
                 lr_rel_orig.atdsrvano,              ASCII(09),
                 lr_rel_orig.srvtipabvdes,           ASCII(09),
                 lr_rel_orig.asitipabvdes,           ASCII(09),
                 lr_rel_orig.atddfttxt,              ASCII(09),
                 lr_rel_orig.atdsrvorg,              ASCII(09),
                 lr_rel_orig.atdvclsgl,              ASCII(09),
                 lr_rel_orig.srrcoddig,              ASCII(09),
                 lr_rel_orig.srrnom,                 ASCII(09),
                 lr_rel_orig.srrabvnom,              ASCII(09),
                 lr_rel_orig.pstcoddig,              ASCII(09),
                 lr_rel_orig.nomgrr,                 ASCII(09),
                 lr_rel_orig.cpodes,                 ASCII(09),
                 lr_rel_apoio.atdsrvnum,             ASCII(09),
                 lr_rel_apoio.atdsrvano,             ASCII(09),
                 lr_rel_apoio.srvtipabvdes,          ASCII(09),
                 lr_rel_apoio.asitipabvdes,          ASCII(09),
                 lr_rel_apoio.atddfttxt,             ASCII(09),
                 lr_rel_apoio.atdsrvorg,             ASCII(09),
                 lr_rel_apoio.atdvclsgl,             ASCII(09),
                 lr_rel_apoio.srrcoddig,             ASCII(09),
                 lr_rel_apoio.srrnom,                ASCII(09),
                 lr_rel_apoio.srrabvnom,             ASCII(09),
                 lr_rel_apoio.pstcoddig,             ASCII(09),
                 lr_rel_apoio.nomgrr,                ASCII(09),
                 lr_rel_apoio.cpodes,                ASCII(09),
                 lr_rel_apoio.atddat

end report
