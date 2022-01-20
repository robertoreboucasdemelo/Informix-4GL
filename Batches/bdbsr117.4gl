#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr117                                                       #
# Analista Resp.: Andre Pinto                                                 #
# Desenvolvimento: Andre Pinto                                                #
# PSI......: 227005 - Relatorios Saude + Casa    	                            #
# --------------------------------------------------------------------------- #
# Liberacao...:                                                               #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
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

    call bdbsr117_prepare()

    call bdbsr117_busca_path()

    set isolation to dirty read

    call bdbsr117()

end main

#------------------------------#
function bdbsr117_busca_path()
#------------------------------#

    define l_dataarq char(8)
    define l_data    date

    let l_data = today
    display "l_data: ", l_data
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    display "l_dataarq: ", l_dataarq

    let m_path = null
    let m_rel1 = null

    # Chama a funcao para buscar o caminho do arquivo de log
    let m_path = f_path("DBS", "LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr117.log"

    call startlog(m_path)

    # Chama a funcao para buscar o caminho do arquivo de relatorio
    let m_path = f_path("DBS", "RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_rel1 = m_path clipped, "/AtendimentosSaude", month(m_data_inicio) using "&&",
    						       year(m_data_inicio) using "&&&&" ,".xls"

    let m_path_txt = m_path clipped, "/AtendimentosSaude_", l_dataarq, ".txt"



end function

#---------------------------#
function bdbsr117_prepare()
#---------------------------#

    define l_sql char(10000)
    define l_data char(10)
    define l_mes char(2)
    define l_ano char(4)

    let l_mes = month(current) using "&&"
    if l_mes > 1 then
    	let l_mes = l_mes - 1
    end if

    let l_data = "01/", l_mes clipped ,"/", year(current) using "&&&&"

    let m_data_inicio = l_data

    if month(m_data_inicio) = 1 then
    	let m_data_inicio = m_data_inicio - 1 units year
    end if

    let m_data_fim = m_data_inicio + 1 units month
    let m_data_fim = m_data_fim - 1 units day

    let l_ano = year(m_data_inicio)
    let l_ano = l_ano[3,4]



    # Servicos os servicos de apoio
    let l_sql =  " select succod    ,                                      "
		,"         ramcod    ,                                     "
		,"         aplnumdig ,                                     "
		,"         crtnum    ,                                     "
		,"         bnfnum    ,                                     "
		,"         atddat    ,                                     "
		,"         apl.atdsrvnum ,                                 "
		,"         apl.atdsrvano ,                                 "
		,"         acp.atdetpcod ,                                 "
		,"         re.socntzcod ,                                  "
		,"         ntz.socntzdes,                                  "
		,"         atdcstvlr,                                      "
		,"         brrnom,                                         "
		,"         cidnom,                                         "
		,"         ufdcod                                          "
		,"  from datrsrvsau apl, datmsrvacp acp, datmservico srv,  "
		,"         datmsrvre re, datksocntz ntz, datmlcl lcl       "
		,"  where apl.atdsrvnum >= 1000000                         "
		,"  and apl.atdsrvano = '", l_ano clipped, "'"
		,"  and srv.atddat >= '",m_data_inicio clipped, "'"
		,"  and srv.atddat <= '",m_data_fim clipped, "'"
		,"  and apl.ramcod in (85,86,87)                           "
		,"  and acp.atdsrvnum = apl.atdsrvnum                      "
		,"  and acp.atdsrvano = apl.atdsrvano                      "
		,"  and srv.atdsrvnum = apl.atdsrvnum                      "
		,"  and srv.atdsrvano = apl.atdsrvano                      "
		,"  and re.atdsrvnum = apl.atdsrvnum                       "
		,"  and re.atdsrvano = apl.atdsrvano                       "
		,"  and acp.atdetpcod in (3,10)                            "
                ,"  and acp.atdsrvseq = (select max(atdsrvseq)             "
                ,"                    from datmsrvacp acp2                 "
                ,"                   where acp2.atdsrvnum = apl.atdsrvnum  "
                ,"                     and acp2.atdsrvano = apl.atdsrvano) "
                ,"  and ntz.socntzcod = re.socntzcod                       "
                ,"  and lcl.atdsrvano = srv.atdsrvano                      "
                ,"  and lcl.atdsrvnum = srv.atdsrvnum                      "
                ,"  and lcl.c24endtip = 1                                  "

    prepare pbdbsr117010 from l_sql
    declare cbdbsr117010 cursor for pbdbsr117010

end function

#-------------------#
function bdbsr117()
#-------------------#
    call bdbsr117_relatorio()

    call bdbsr117_envia_email()

end function

#---------------------------#
function bdbsr117_relatorio()
#---------------------------#

  define  lr_dados  record
       succod    like datrsrvsau.succod    ,
       ramcod    like datrsrvsau.ramcod    ,
       aplnumdig like datrsrvsau.aplnumdig ,
       crtnum    like datrsrvsau.crtnum    ,
       bnfnum    like datrsrvsau.bnfnum    ,
       atddat    like datmservico.atddat   ,
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano,
       atdetpcod like datmservico.atdetpcod,
       socntzcod like datksocntz.socntzcod ,
       socntzdes like datksocntz.socntzdes ,
       atdcstvlr like datmservico.atdcstvlr,
       brrnom	 like datmlcl.brrnom,
       cidnom	 like datmlcl.cidnom,
       ufdcod	 like datmlcl.ufdcod
  end record

  start report bdbsr117_rel1 to m_rel1
  start report bdbsr117_rel1_txt to m_path_txt

  open cbdbsr117010

  foreach cbdbsr117010 into lr_dados.succod
    			    ,lr_dados.ramcod
    			    ,lr_dados.aplnumdig
    			    ,lr_dados.crtnum
    			    ,lr_dados.bnfnum
    			    ,lr_dados.atddat
    			    ,lr_dados.atdsrvnum
    			    ,lr_dados.atdsrvano
    			    ,lr_dados.atdetpcod
    			    ,lr_dados.socntzcod
    			    ,lr_dados.socntzdes
    			    ,lr_dados.atdcstvlr
    			    ,lr_dados.brrnom
    			    ,lr_dados.cidnom
     			    ,lr_dados.ufdcod

  output to report bdbsr117_rel1(lr_dados.*)
  output to report bdbsr117_rel1_txt(lr_dados.*)

  end foreach

  close cbdbsr117010

  finish report bdbsr117_rel1
  finish report bdbsr117_rel1_txt

end function

#--------------------------------------------#
report bdbsr117_rel1(lr_dados)
#--------------------------------------------#


  define  lr_dados  record
       succod    like datrsrvsau.succod    ,
       ramcod    like datrsrvsau.ramcod    ,
       aplnumdig like datrsrvsau.aplnumdig ,
       crtnum    like datrsrvsau.crtnum    ,
       bnfnum    like datrsrvsau.bnfnum    ,
       atddat    like datmservico.atddat   ,
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano,
       atdetpcod like datmservico.atdetpcod,
       socntzcod like datksocntz.socntzcod ,
       socntzdes like datksocntz.socntzdes ,
       atdcstvlr like datmservico.atdcstvlr,
       brrnom	 like datmlcl.brrnom,
       cidnom	 like datmlcl.cidnom,
       ufdcod	 like datmlcl.ufdcod
  end record

  define l_crtnum char(30)
  define l_bnfnum char(30)

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00


    format
        first page header
            print "Sucursal"			, ASCII(09),
                  "Ramo"			, ASCII(09),
                  "Apólice"			, ASCII(09),
                  "Cartão"			, ASCII(09),
                  "Benificiário"		, ASCII(09),
                  "Data"			, ASCII(09),
                  "Serviço"			, ASCII(09),
                  "Ano"				, ASCII(09),
                  "Etapa (3-Acionado, 10-Retorno)", ASCII(09),
                  "Código Natureza"		, ASCII(09),
                  "Desc. Natureza"		, ASCII(09),
                  "Valor Pago"			, ASCII(09),
                  "Bairro"			, ASCII(09),
                  "Cidade"			, ASCII(09),
                  "UF"				, ASCII(09)

        on every row

  	   let l_crtnum = "", lr_dados.crtnum
  	   let l_bnfnum = "", lr_dados.bnfnum

           print lr_dados.succod                           , ASCII(09),
                 lr_dados.ramcod                           , ASCII(09),
                 lr_dados.aplnumdig                        , ASCII(09),
                 l_crtnum             	                   , ASCII(09),
                 l_bnfnum	                                 , ASCII(09),
                 lr_dados.atddat using "yyyy-mm-dd"        , ASCII(09),
                 lr_dados.atdsrvnum                        , ASCII(09),
                 lr_dados.atdsrvano                        , ASCII(09),
                 lr_dados.atdetpcod                        , ASCII(09),
                 lr_dados.socntzcod                        , ASCII(09),
                 lr_dados.socntzdes                        , ASCII(09),
                 lr_dados.atdcstvlr using "---------&,&&"  , ASCII(09),
                 lr_dados.brrnom	                         , ASCII(09),
                 lr_dados.cidnom	                         , ASCII(09),
                 lr_dados.ufdcod	                         , ASCII(09)

end report

#-------------------------------#
function bdbsr117_envia_email()
#-------------------------------#

   define l_assunto     char(200),
          l_comando     char(200),
          l_erro_envio  integer,
          l_arquivos    char(300)

   # Inicializacao das variaveis
   let l_comando    = null
   let l_erro_envio = null
   let l_arquivos   = null
   let l_assunto    = "Relatorio de Resumo de Servicos Saude+Casa (", m_data_inicio, " a ", m_data_fim, ")"

   # Compacta arquivos
   let l_comando = "gzip -f ", m_rel1 clipped
   run l_comando

   let m_rel1 = m_rel1 clipped, ".gz"

   let l_arquivos = m_rel1 clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR117", l_assunto clipped, l_arquivos clipped)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email (ctx22g00) - ", l_assunto, " ",l_arquivos
       else
           display "Nao existe email cadastrado para o modulo - bdbsr117"
       end if
   end if

end function

#--------------------------------------------#
report bdbsr117_rel1_txt(lr_dados)
#--------------------------------------------#


  define  lr_dados  record
       succod    like datrsrvsau.succod    ,
       ramcod    like datrsrvsau.ramcod    ,
       aplnumdig like datrsrvsau.aplnumdig ,
       crtnum    like datrsrvsau.crtnum    ,
       bnfnum    like datrsrvsau.bnfnum    ,
       atddat    like datmservico.atddat   ,
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano,
       atdetpcod like datmservico.atdetpcod,
       socntzcod like datksocntz.socntzcod ,
       socntzdes like datksocntz.socntzdes ,
       atdcstvlr like datmservico.atdcstvlr,
       brrnom	 like datmlcl.brrnom,
       cidnom	 like datmlcl.cidnom,
       ufdcod	 like datmlcl.ufdcod
  end record

  define l_crtnum char(30)
  define l_bnfnum char(30)

    output
        left   margin  00
        right  margin  00
        top    margin  00
        bottom margin  00
        page   length  01


    format
       on every row

  	   let l_crtnum = "", lr_dados.crtnum
  	   let l_bnfnum = "", lr_dados.bnfnum

           print lr_dados.succod                             , ASCII(09),
                 lr_dados.ramcod                             , ASCII(09),
                 lr_dados.aplnumdig                          , ASCII(09),
                 l_crtnum             	                     , ASCII(09),
                 l_bnfnum	                                   , ASCII(09),
                 lr_dados.atddat using "yyyy-mm-dd"          , ASCII(09),
                 lr_dados.atdsrvnum                          , ASCII(09),
                 lr_dados.atdsrvano                          , ASCII(09),
                 lr_dados.atdetpcod                          , ASCII(09),
                 lr_dados.socntzcod                          , ASCII(09),
                 lr_dados.socntzdes                          , ASCII(09),
                 lr_dados.atdcstvlr using "---------&,&&"    , ASCII(09),
                 lr_dados.brrnom	                           , ASCII(09),
                 lr_dados.cidnom	                           , ASCII(09),
                 lr_dados.ufdcod

end report
