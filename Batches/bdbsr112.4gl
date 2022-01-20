#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr112                                                       #
# Analista Resp.: Marcos Federicce                                            #
# PSI......: 209694 - Relatorios de Indexacao de Enderecos                    #
#                     Rel 1: Indexacao por operador                           #
#                     Rel 2: Servicos indexados apos a abertura               #
#                     Rel 3: Servicos enviados sem indexacao                  #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Marcos Federicce                                           #
# Liberacao...: 10/07/2007                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path char(100)
define m_rel1 char(100)
define m_rel2 char(100)
define m_rel3 char(100)

define m_data_inicio date
define m_data_fim    date

main

    call fun_dba_abre_banco("CT24HS")

    call bdbsr112_busca_path()

    call bdbsr112_prepare()

    call cts40g03_exibe_info("I", "bdbsr112")

    set isolation to dirty read

    call bdbsr112()

    call cts40g03_exibe_info("F", "bdbsr112")

end main

#------------------------------#
function bdbsr112_busca_path()
#------------------------------#

    let m_path = null
    let m_rel1 = null
    let m_rel2 = null
    let m_rel3 = null

    # Chama a funcao para buscar o caminho do arquivo de log
    let m_path = f_path("DBS", "LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr112.log"

    call startlog(m_path)

    # Chama a funcao para buscar o caminho do arquivo de relatorio
    let m_path = f_path("DBS", "RELATO")

    if m_path is null then
        let m_path = "."
    end if

    let m_rel1 = m_path clipped, "/bdbsr1121.xls"
    let m_rel2 = m_path clipped, "/bdbsr1122.xls"
    let m_rel3 = m_path clipped, "/bdbsr1123.xls"

end function

#---------------------------#
function bdbsr112_prepare()
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
        let m_data_inicio = l_data_atual - 7 units day
        let m_data_fim = l_data_atual - 1 units day
    end if

    # 1 - Indexacao por operador
    let l_sql = " select f.funmat, ",
                       " f.empcod, ",
                       " f.usrtip, ",
                       " f.funnom, ",
                       " count(*) quant_total ",
                  " from datmsrvidxhst h, ",
                       " datmservico s, ",
                       " isskfunc f ",
                 " where h.atddat between '", m_data_inicio, "' and '", m_data_fim, "'",
                   " and h.funmat = f.funmat ", 
                   " and h.empcod = f.empcod ",
                   " and h.usrtip = f.usrtip ",
                   " and h.atdsrvnum = s.atdsrvnum ",
                   " and h.atdsrvano = s.atdsrvano ", 
                   " and s.atdsrvorg in (1,2,3,4,5,6,7,9,12,13) ",
              " group by f.funmat, ",
                       " f.empcod, ",
                       " f.usrtip, ",
                       " f.funnom "

    prepare pbdbsr112010 from l_sql
    declare cbdbsr112010 cursor for pbdbsr112010

    let l_sql = " select count(*) endidx ",
                  " from datmsrvidxhst h, ",
                       " datmservico s, ",
                       " datkmpacid c ",
                 " where h.atddat between '", m_data_inicio, "' and '", m_data_fim, "'",
                   " and h.atdsrvnum = s.atdsrvnum ",
                   " and h.atdsrvano = s.atdsrvano ",
                   " and s.atdsrvorg in (1,2,3,4,5,6,7,9,12,13) ",
                   " and h.ufdcod = c.ufdcod ",
                   " and h.cidnom = c.cidnom ",
                   " and h.funmat = ? ",
                   " and h.empcod = ? ",
                   " and h.usrtip = ? ",
                   " and ( ",
                       " (h.c24lclpdrcod = 3) or ",
                       " (h.c24lclpdrcod = 2 and c.mpacrglgdflg = 0) ",
                       " ) "

    prepare pbdbsr112011 from l_sql
    declare cbdbsr112011 cursor for pbdbsr112011

    # 2 - Servicos indexados apos a abertura
    let l_sql = " select s.atdsrvorg, ",
                       " h.atdsrvnum, ",
                       " h.atdsrvano, ",
                       " f.funmat, ",
                       " f.funnom, ",
                       " h.lgdtip, ",
                       " h.lgdnom, ",
                       " h.brrnom, ",
                       " h.cidnom, ",
                       " h.ufdcod ", 
                  " from datmsrvidxhst h, ",
                       " datmservico s, ",
                       " isskfunc f, ",
                       " datkmpacid c ",
                 " where h.atddat between '", m_data_inicio, "' and '", m_data_fim, "' ",
                   " and h.atdsrvnum = s.atdsrvnum ",
                   " and h.atdsrvano = s.atdsrvano ", 
                   " and s.atdsrvorg in (1,2,3,4,5,6,7,9,12,13) ",
                   " and h.funmat = f.funmat ", 
                   " and h.empcod = f.empcod ",
                   " and h.usrtip = f.usrtip ",
                   " and h.ufdcod = c.ufdcod ",
                   " and h.cidnom = c.cidnom ",
                   " and h.srvidxseq = 1 ",
                   " and ( ",
                       " (h.c24lclpdrcod = 1) or ",
                       " (h.c24lclpdrcod = 2 and c.mpacrglgdflg = 1) ",
                       " ) "

    prepare pbdbsr112020 from l_sql
    declare cbdbsr112020 cursor for pbdbsr112020

    let l_sql = " select f.funmat, ",
                       " f.funnom, ",
                       " h.lgdtip, ",
                       " h.lgdnom, ",
                       " h.brrnom, ",
                       " h.cidnom, ",
                       " h.ufdcod ", 
                  " from datmsrvidxhst h, ",
                       " isskfunc f, ",
                       " datkmpacid c ",
                 " where h.atddat between '", m_data_inicio, "' and '", m_data_fim, "' ",
                   " and h.funmat = f.funmat ", 
                   " and h.empcod = f.empcod ",
                   " and h.usrtip = f.usrtip ",
                   " and h.ufdcod = c.ufdcod ",
                   " and h.cidnom = c.cidnom ",
                   " and h.srvidxseq > 1 ",
                   " and h.atdsrvnum = ? ",
                   " and h.atdsrvano = ? ",
                   " and ( ",
                       " (h.c24lclpdrcod = 3) or ",
                       " (h.c24lclpdrcod = 2 and c.mpacrglgdflg = 0) ",
                       " ) "

    prepare pbdbsr112021 from l_sql
    declare cbdbsr112021 cursor for pbdbsr112021

    # 3 - Servicos enviados sem indexacao
    let l_sql = " select s.atdsrvorg, ",
                       " h.atdsrvnum, ",
                       " h.atdsrvano, ",
                       " f.funmat, ",
                       " f.funnom ",
                  " from datmsrvidxhst h, ",
                       " datmservico s, ",
                       " isskfunc f, ",
                       " datkmpacid c ",
                 " where h.atddat between '", m_data_inicio, "' and '", m_data_fim, "' ",
                   " and h.atdsrvnum = s.atdsrvnum ",
                   " and h.atdsrvano = s.atdsrvano ", 
                   " and s.atdsrvorg in (1,2,3,4,5,6,7,9,12,13) ",
                   " and h.funmat = f.funmat ", 
                   " and h.empcod = f.empcod ",
                   " and h.usrtip = f.usrtip ",
                   " and h.ufdcod = c.ufdcod ",
                   " and h.cidnom = c.cidnom ",
                   " and h.srvidxseq = 1 ",
                   " and ( ",
                       " (h.c24lclpdrcod = 1) or ",
                       " (h.c24lclpdrcod = 2 and c.mpacrglgdflg = 1) ",
                       " ) "

    prepare pbdbsr112030 from l_sql
    declare cbdbsr112030 cursor for pbdbsr112030

    let l_sql = " select srvidxseq, c24lclpdrcod ", 
                  " from datmsrvidxhst ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and srvidxseq = ( select max(srvidxseq) ",
                                       " from datmsrvidxhst ",
                                      " where atdsrvnum = ? ",
                                        " and atdsrvano = ? ) "

    prepare pbdbsr112031 from l_sql
    declare cbdbsr112031 cursor for pbdbsr112031

    let l_sql = " select f.funmat, ",
                       " f.funnom, ",
                       " h.lgdtip, ",
                       " h.lgdnom, ",
                       " h.brrnom, ",
                       " h.cidnom, ",
                       " h.ufdcod, ", 
                       " c.mpacrglgdflg ",
                  " from isskfunc f, ",
                       " datmsrvidxhst h, ",
                       " datmsrvacp a, ",
                       " datkmpacid c ",
                 " where h.atdsrvnum = ? ",
                   " and h.atdsrvano = ? ",
                   " and h.srvidxseq = ? ",
                   " and a.funmat = f.funmat ", 
                   " and a.empcod = f.empcod ",
                   " and a.atdetpcod in (3, 4, 10) ",
                   " and h.atdsrvnum = a.atdsrvnum ",
                   " and h.atdsrvano = a.atdsrvano ",
                   " and h.ufdcod = c.ufdcod ",
                   " and h.cidnom = c.cidnom "

    prepare pbdbsr112032 from l_sql
    declare cbdbsr112032 cursor for pbdbsr112032

end function

#-------------------#
function bdbsr112()
#-------------------#

    define l_hora datetime hour to second
    
    let l_hora = extend(current, hour to second)
    display l_hora, ": Gerando 'Indexacao por operador'..."
    call bdbsr112_gera1() # Indexacao por operador

    let l_hora = extend(current, hour to second)
    display l_hora, ": Gerando 'Servicos indexados apos a abertura'..."
    call bdbsr112_gera2() # Servicos indexados apos a abertura

    let l_hora = extend(current, hour to second)
    display l_hora, ": Gerando 'Servicos enviados sem indexacao'..."
    call bdbsr112_gera3() # Servicos enviados sem indexacao

    let l_hora = extend(current, hour to second)
    display l_hora, ": Enviando arquivos por e-mail..."
    call bdbsr112_envia_email()

end function

#-----------------------#
function bdbsr112_gera1()
#-----------------------#

    define lr_dados record
            funmat           like isskfunc.funmat,
            empcod           like isskfunc.empcod,
            usrtip           like isskfunc.usrtip,
            funnom           like isskfunc.funnom,
            quant_endnaoidx  integer,
            quant_endidx     integer
    end record

    define l_quant_total        integer
    define l_quant_naoidx_perc  decimal(6,4)
    define l_quant_idx_perc     decimal(6,4)

    initialize lr_dados.*,
               l_quant_total,
               l_quant_idx_perc,
               l_quant_naoidx_perc to null

    start report bdbsr112_rel1 to m_rel1

    open cbdbsr112010
    
    foreach cbdbsr112010 into lr_dados.funmat,
                              lr_dados.empcod,
                              lr_dados.usrtip,
                              lr_dados.funnom,
                              l_quant_total

        # Indexados
        open cbdbsr112011 using lr_dados.funmat,
                                lr_dados.empcod,
                                lr_dados.usrtip

        fetch cbdbsr112011 into lr_dados.quant_endidx
        
        if status = notfound then
            let lr_dados.quant_endidx = 0
        end if

        close cbdbsr112011

        # Total e percentuais
        let lr_dados.quant_endnaoidx = l_quant_total - lr_dados.quant_endidx
        let l_quant_naoidx_perc = lr_dados.quant_endnaoidx / l_quant_total
        let l_quant_idx_perc = lr_dados.quant_endidx / l_quant_total

        output to report bdbsr112_rel1(lr_dados.funmat,
                                       lr_dados.funnom,
                                       l_quant_total,
                                       lr_dados.quant_endidx,
                                       l_quant_idx_perc * 100,
                                       lr_dados.quant_endnaoidx,
                                       l_quant_naoidx_perc * 100)

        initialize lr_dados.*,
                   l_quant_total,
                   l_quant_naoidx_perc,
                   l_quant_idx_perc to null

    end foreach

    close cbdbsr112010

    finish report bdbsr112_rel1

end function

#---------------------------------------#
report bdbsr112_rel1(lr_parametro)
#---------------------------------------#

    define lr_parametro record
        funmat            like isskfunc.funmat,
        funnom            like isskfunc.funnom,
        l_quant_total     integer,
        quant_idx         integer,
        l_quant_idx_perc  decimal(8, 4),
        quant_nidx        integer,
        l_quant_nidx_perc decimal(8, 4)
    end record

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "Matricula",                          ASCII(09),
                  "Atendente",                          ASCII(09),
                  "Total de enderecos ",                ASCII(09),
                  "Quant. enderecos indexados",         ASCII(09),
                  "Enderecos indexados (%)",            ASCII(09),
                  "Quant. enderecos nao-indexados",     ASCII(09),
                  "Enderecos nao-indexados (%)",        ASCII(09);

            skip 1 line

        on every row

            print lr_parametro.funmat,                  ASCII(09),
                  lr_parametro.funnom,                  ASCII(09),
                  lr_parametro.l_quant_total,           ASCII(09),
                  lr_parametro.quant_idx,               ASCII(09),
                  lr_parametro.l_quant_idx_perc, '%',   ASCII(09),
                  lr_parametro.quant_nidx,              ASCII(09),
                  lr_parametro.l_quant_nidx_perc, '%',  ASCII(09);

            skip 1 line

end report

#-----------------------#
function bdbsr112_gera2()
#-----------------------#

    define lr_dados record
        atdsrvorg        like datmservico.atdsrvorg,
        atdsrvnum        like datmsrvidxhst.atdsrvnum,
        atdsrvano        like datmsrvidxhst.atdsrvano,
        funmatnidx       like isskfunc.funmat,
        funnomnidx       like isskfunc.funnom,
        lgdtipnidx       like datmsrvidxhst.lgdtip,
        lgdnomnidx       like datmsrvidxhst.lgdnom,
        cidnomnidx       like datmsrvidxhst.cidnom,
        brrnomnidx       like datmsrvidxhst.brrnom,
        ufdcodnidx       like datmsrvidxhst.ufdcod,
        funmatidx        like isskfunc.funmat,
        funnomidx        like isskfunc.funnom,
        lgdtipidx        like datmsrvidxhst.lgdtip,
        lgdnomidx        like datmsrvidxhst.lgdnom,
        brrnomidx        like datmsrvidxhst.brrnom,
        cidnomidx        like datmsrvidxhst.cidnom,
        ufdcodidx        like datmsrvidxhst.ufdcod
    end record

    define srvnum char(100)
    
    initialize srvnum,
               lr_dados.* to null

    start report bdbsr112_rel2 to m_rel2

    open cbdbsr112020

    foreach cbdbsr112020 into lr_dados.atdsrvorg,
                              lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.funmatnidx,
                              lr_dados.funnomnidx,
                              lr_dados.lgdtipnidx,
                              lr_dados.lgdnomnidx,
                              lr_dados.brrnomnidx,
                              lr_dados.cidnomnidx,
                              lr_dados.ufdcodnidx

        let srvnum = lr_dados.atdsrvorg using "<<#", "/",
                     lr_dados.atdsrvnum using "<<<<<<<<#", "-",
                     lr_dados.atdsrvano using "<<#"

        open cbdbsr112021 using lr_dados.atdsrvnum, lr_dados.atdsrvano

        foreach cbdbsr112021 into lr_dados.funmatidx,
                                  lr_dados.funnomidx,
                                  lr_dados.lgdtipidx,
                                  lr_dados.lgdnomidx,
                                  lr_dados.brrnomidx,
                                  lr_dados.cidnomidx,
                                  lr_dados.ufdcodidx

            output to report bdbsr112_rel2 (srvnum,
                                            lr_dados.funmatnidx,
                                            lr_dados.funnomnidx,
                                            lr_dados.lgdtipnidx,
                                            lr_dados.lgdnomnidx,
                                            lr_dados.brrnomnidx,
                                            lr_dados.cidnomnidx,
                                            lr_dados.ufdcodnidx,
                                            lr_dados.funmatidx, 
                                            lr_dados.funnomidx, 
                                            lr_dados.lgdtipidx, 
                                            lr_dados.lgdnomidx, 
                                            lr_dados.brrnomidx, 
                                            lr_dados.cidnomidx, 
                                            lr_dados.ufdcodidx)
        
        end foreach
        
        close cbdbsr112021
        
        initialize srvnum,
                   lr_dados.* to null

    end foreach

    close cbdbsr112020

    finish report bdbsr112_rel2

end function

#---------------------------------------#
report bdbsr112_rel2(lr_parametro)
#---------------------------------------#

    define lr_parametro record
        srvnum           char(30),
        funmatnidx       like isskfunc.funmat,
        funnomnidx       like isskfunc.funnom,
        lgdtipnidx       like datmsrvidxhst.lgdtip,
        lgdnomnidx       like datmsrvidxhst.lgdnom,
        brrnomnidx       like datmsrvidxhst.brrnom,
        cidnomnidx       like datmsrvidxhst.cidnom,
        ufdcodnidx       like datmsrvidxhst.ufdcod,
        funmatidx        like isskfunc.funmat,
        funnomidx        like isskfunc.funnom,
        lgdtipidx        like datmsrvidxhst.lgdtip,
        lgdnomidx        like datmsrvidxhst.lgdnom,
        brrnomidx        like datmsrvidxhst.brrnom,
        cidnomidx        like datmsrvidxhst.cidnom,
        ufdcodidx        like datmsrvidxhst.ufdcod
    end record
    
    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "Servico",                            ASCII(09),
                  "Matricula de abertura",              ASCII(09),
                  "Nome de abertura",                   ASCII(09),
                  "Tipo logradouro nao indexado",       ASCII(09),
                  "Logradouro nao indexado",            ASCII(09),
                  "Bairro nao indexado",                ASCII(09),
                  "Cidade nao indexada",                ASCII(09),
                  "UF nao indexada",                    ASCII(09),
                  "Matricula indexacao",                ASCII(09),
                  "Nome indexacao",                     ASCII(09),
                  "Tipo logradouro indexado",           ASCII(09),
                  "Logradouro indexado",                ASCII(09),
                  "Bairro indexado",                    ASCII(09),
                  "Cidade indexada",                    ASCII(09),
                  "UF indexada",                        ASCII(09);

            skip 1 line

        on every row

            print lr_parametro.srvnum clipped,          ASCII(09),
                  lr_parametro.funmatnidx,              ASCII(09),
                  lr_parametro.funnomnidx,              ASCII(09),
                  lr_parametro.lgdtipnidx,              ASCII(09),
                  lr_parametro.lgdnomnidx,              ASCII(09),
                  lr_parametro.brrnomnidx,              ASCII(09),
                  lr_parametro.cidnomnidx,              ASCII(09),
                  lr_parametro.ufdcodnidx,              ASCII(09),
                  lr_parametro.funmatidx,               ASCII(09),
                  lr_parametro.funnomidx,               ASCII(09),
                  lr_parametro.lgdtipidx,               ASCII(09),
                  lr_parametro.lgdnomidx,               ASCII(09),
                  lr_parametro.brrnomidx,               ASCII(09),
                  lr_parametro.cidnomidx,               ASCII(09),
                  lr_parametro.ufdcodidx,               ASCII(09);

            skip 1 line

end report

#-----------------------#
function bdbsr112_gera3()
#-----------------------#

    define lr_dados record
        atdsrvorg           like datmservico.atdsrvorg,
        atdsrvnum           like datmsrvidxhst.atdsrvnum,
        atdsrvano           like datmsrvidxhst.atdsrvano,
        lgdtip              like datmsrvidxhst.lgdtip,
        lgdnom              like datmsrvidxhst.lgdnom,
        brrnom              like datmsrvidxhst.brrnom,
        cidnom              like datmsrvidxhst.cidnom,
        ufdcod              like datmsrvidxhst.ufdcod,
        funmatabr           like isskfunc.funmat,
        funnomabr           like isskfunc.funnom,
        funmatacn           like isskfunc.funmat,
        funnomacn           like isskfunc.funnom,
        mpacrglgdflg        like datkmpacid.mpacrglgdflg
    end record

    define l_srvidxseq      like datmsrvidxhst.srvidxseq
    define l_c24lclpdrcod   like datmsrvidxhst.c24lclpdrcod
    define l_srvnum         char(100)
    define l_flgcid         char(3)
    
    initialize lr_dados.*,
               l_srvidxseq,
               l_c24lclpdrcod,
               l_srvnum,
               l_flgcid to null

    start report bdbsr112_rel3 to m_rel3

    open cbdbsr112030
    
    foreach cbdbsr112030 into lr_dados.atdsrvorg,
                              lr_dados.atdsrvnum,
                              lr_dados.atdsrvano,
                              lr_dados.funmatabr,
                              lr_dados.funnomabr

        let l_srvnum = lr_dados.atdsrvorg using "<<#", "/",
                       lr_dados.atdsrvnum using "<<<<<<<<#", "-",
                       lr_dados.atdsrvano using "<<#"

        open cbdbsr112031 using lr_dados.atdsrvnum,
                                lr_dados.atdsrvano,
                                lr_dados.atdsrvnum,
                                lr_dados.atdsrvano

        fetch cbdbsr112031 into l_srvidxseq, l_c24lclpdrcod
        
        close cbdbsr112031
        
        if l_srvidxseq > 1 and l_c24lclpdrcod = 1 then
        
            open cbdbsr112032 using lr_dados.atdsrvnum, lr_dados.atdsrvano, l_srvidxseq
    
            foreach cbdbsr112032 into lr_dados.funmatacn,
                                      lr_dados.funnomacn,
                                      lr_dados.lgdtip,
                                      lr_dados.lgdnom,
                                      lr_dados.brrnom,
                                      lr_dados.cidnom,
                                      lr_dados.ufdcod,
                                      lr_dados.mpacrglgdflg
    
                if lr_dados.mpacrglgdflg = 1 then
                   let l_flgcid = "Sim"
                else
                   let l_flgcid = "Nao"
                end if

                output to report bdbsr112_rel3 (l_srvnum,
                                                lr_dados.lgdtip,
                                                lr_dados.lgdnom,
                                                lr_dados.brrnom,
                                                lr_dados.cidnom,
                                                lr_dados.ufdcod,
                                                lr_dados.funmatabr,
                                                lr_dados.funnomabr,
                                                lr_dados.funmatacn,
                                                lr_dados.funnomacn,
                                                l_flgcid)
            
            end foreach

            close cbdbsr112032

        end if
                
        initialize lr_dados.*,
                   l_srvidxseq,
                   l_c24lclpdrcod,
                   l_srvnum,
                   l_flgcid to null

    end foreach

    close cbdbsr112030

    finish report bdbsr112_rel3

end function

#---------------------------------------#
report bdbsr112_rel3(lr_parametro)
#---------------------------------------#

    define lr_parametro  record
        srvnum           char(100),
        lgdtip           like datmsrvidxhst.lgdtip,
        lgdnom           like datmsrvidxhst.lgdnom,
        brrnom           like datmsrvidxhst.brrnom,
        cidnom           like datmsrvidxhst.cidnom,
        ufdcod           like datmsrvidxhst.ufdcod,
        funmatabr        like isskfunc.funmat,
        funnomabr        like isskfunc.funnom,
        funmatacn        like isskfunc.funmat,
        funnomacn        like isskfunc.funnom,
        flgcid           char(3)
    end record

    output
        left   margin 00
        right  margin 00
        top    margin 00
        bottom margin 00
        page   length 02

    format
        first page header
            print "Servico",                            ASCII(09),
                  "Tipo logradouro nao indexado",       ASCII(09),
                  "Logradouro nao indexado",            ASCII(09),
                  "Bairro nao indexado",                ASCII(09),
                  "Cidade nao indexada",                ASCII(09),
                  "UF nao indexada",                    ASCII(09),
                  "Cidade tem mapa?",                   ASCII(09),
                  "Matricula de abertura",              ASCII(09),
                  "Nome de abertura",                   ASCII(09),
                  "Matricula de acionamento",           ASCII(09),
                  "Nome de acionamento",                ASCII(09);

            skip 1 line

        on every row

            print lr_parametro.srvnum clipped,          ASCII(09),
                  lr_parametro.lgdtip,                  ASCII(09),
                  lr_parametro.lgdnom,                  ASCII(09),
                  lr_parametro.brrnom,                  ASCII(09),
                  lr_parametro.cidnom,                  ASCII(09),
                  lr_parametro.ufdcod,                  ASCII(09),
                  lr_parametro.flgcid,                  ASCII(09),
                  lr_parametro.funmatabr,               ASCII(09),
                  lr_parametro.funnomabr,               ASCII(09),
                  lr_parametro.funmatacn,               ASCII(09),
                  lr_parametro.funnomacn,               ASCII(09);

            skip 1 line

end report

#-------------------------------#
function bdbsr112_envia_email()
#-------------------------------#

   define l_assunto     char(200),
          l_comando     char(200),
          l_erro_envio  integer,
          l_arquivos    char(300)

   # Inicializacao das variaveis
   let l_comando    = null
   let l_erro_envio = null
   let l_arquivos   = null
   let l_assunto    = "Relatorios de Indexacao de Enderecos (", m_data_inicio, " a ", m_data_fim, ")"

   # Compacta arquivos
   let l_comando = "gzip -f ", m_rel1 clipped, " ", m_rel2 clipped, " ", m_rel3 clipped
   run l_comando

   let m_rel1 = m_rel1 clipped, ".gz"
   let m_rel2 = m_rel2 clipped, ".gz"
   let m_rel3 = m_rel3 clipped, ".gz"

   let l_arquivos = m_rel1 clipped, ',', m_rel2 clipped, ',', m_rel3 clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR112", l_assunto clipped, l_arquivos clipped)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email (ctx22g00) - ", m_path
       else
           display "Nao existe email cadastrado para o modulo - bdbsr112"
       end if
   end if

end function
