#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24 horas                                           #
# Modulo        : cts16m03.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 172.111                                                    #
# OSF           : 029343                                                     #
#                 Gravar complemento ligacao sem servico                     #
#............................................................................#
# Desenvolvimento: Meta, Paulo Dalle Laste                                   #
# Liberacao      : 26/11/2003                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 24/09/2004 Marcio Hashiguti  CT-247510  mudanca de linha do begin work,    #
#                                         para depois da chamada da funcao   #
#                                         call cta03n00                      #
#----------------------------------------------------------------------------#
# 03/02/2006  Priscila       Zeladoria    Buscar data e hora no banco de dado#
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql   smallint

#------------------------------------------------------------------------------
 function cts16m03_prepare()
#------------------------------------------------------------------------------
 define l_sql        char(300)

 let l_sql = ' select ligcvntip '
            ,'   from datmligacao '
            ,'  where lignum = ? '

 prepare p_cts16m03_001 from l_sql
 declare c_cts16m03_001 cursor for p_cts16m03_001

 let l_sql = ' insert into datrligcnslig (lignum,cnslignum) values (?,?) '
 prepare p_cts16m03_002 from l_sql

 let m_prep_sql = true

 end function

#------------------------------------------------------------------------------
 function cts16m03(lr_parm)
#------------------------------------------------------------------------------
 define lr_parm         record
        nr_ligacao      like datmligacao.lignum
       ,data            date
       ,hora            datetime hour to minute
       ,c24solnom       like datmligacao.c24solnom
       ,c24soltip       like datmligacao.c24soltip
 end record

 define lr_aux          record
        nr_servico      like datmligacao.atdsrvnum
       ,ano_servico     like datmligacao.atdsrvano
       ,sqlcacode       integer
       ,msg             char(80)
 end record

 define lr_cts10g00      record
        lignum           like datmligacao.lignum,
        ligdat           like datmligacao.ligdat,
        lighorinc        like datmligacao.lighorinc,
        c24soltipcod     like datksoltip.c24soltipcod,
        c24solnom        like datmligacao.c24solnom,
        c24astcod        like datmligacao.c24astcod,
        c24funmat        like datmligacao.c24funmat,
        ligcvntip        like datmligacao.ligcvntip,
        c24paxnum        like datmligacao.c24paxnum,
        atdsrvnum        like datrligsrv.atdsrvnum,
        atdsrvano        like datrligsrv.atdsrvano,
        sinvstnum        like datrligsinvst.sinvstnum,
        sinvstano        like datrligsinvst.sinvstano,
        sinavsnum        like datrligsinavs.sinavsnum,
        sinavsano        like datrligsinavs.sinavsano,
        succod           like datrligapol.succod,
        ramcod           like datrligapol.ramcod,
        aplnumdig        like datrligapol.aplnumdig,
        itmnumdig        like datrligapol.itmnumdig,
        edsnumref        like datrligapol.edsnumref,
        prporg           like datrligprp.prporg,
        prpnumdig        like datrligprp.prpnumdig,
        fcapacorg        like datrligpac.fcapacorg,
        fcapacnum        like datrligpac.fcapacnum,
        sinramcod        like ssamsin.ramcod    ,
        sinano           like ssamsin.sinano    ,
        sinnum           like ssamsin.sinnum    ,
        sinitmseq        like ssamitem.sinitmseq,
        caddat           like datmligfrm.caddat,
        cadhor           like datmligfrm.cadhor,
        cademp           like datmligfrm.cademp,
        cadmat           like datmligfrm.cadmat
 end record

 define l_tabname    like systables.tabname
       ,l_sqlcode    integer

 define l_msg        char(90)
 define l_data     date,
        l_hora1    datetime hour to second

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts16m03_prepare()
 end if

 let  g_documento.acao         = "CON"

 initialize  lr_cts10g00  to null

 call cts40g03_data_hora_banco(1)
      returning l_data, l_hora1
 let  lr_cts10g00.ligdat       = l_data
 let  lr_cts10g00.lighorinc    = l_hora1
 let  lr_cts10g00.c24soltipcod = lr_parm.c24soltip
 let  lr_cts10g00.c24solnom    = lr_parm.c24solnom
 let  lr_cts10g00.c24astcod    = "CON"
 let  lr_cts10g00.c24funmat    = g_issk.funmat
 let  lr_cts10g00.c24paxnum    = g_c24paxnum
 let  lr_cts10g00.ramcod       = g_documento.ramcod
 let  lr_cts10g00.succod       = g_documento.succod
 let  lr_cts10g00.aplnumdig    = g_documento.aplnumdig
 let  lr_cts10g00.itmnumdig    = g_documento.itmnumdig
 let  lr_cts10g00.edsnumref    = g_documento.edsnumref
 open c_cts16m03_001 using lr_parm.nr_ligacao
 whenever error continue
 fetch c_cts16m03_001 into lr_cts10g00.ligcvntip
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error 'Tipo da ligacao nao encontrado' sleep 2
    else
       error 'Erro SELECT ccts16m03001: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'cts16m03() / ', lr_parm.nr_ligacao sleep 2
    end if
    return
 end if

 begin work

 call cts10g03_numeracao(1,"")
      returning lr_cts10g00.lignum
               ,lr_aux.nr_servico
               ,lr_aux.ano_servico
               ,lr_aux.sqlcacode
               ,lr_aux.msg

 if lr_aux.sqlcacode <> 0 then
    let l_msg = "CTS16M03 ",lr_aux.msg
    call ctx13g00(lr_aux.sqlcacode,"DATKGERAL",l_msg)
    rollback work
    return
 end if
 commit work

 ---> Decreto - 6523
 let g_lignum_dcr = lr_cts10g00.lignum

 call cta03n00(lr_parm.nr_ligacao,g_issk.funmat,lr_parm.data,lr_parm.hora)
 ##CT-247510
 begin work

 call cts10g00_ligacao(lr_cts10g00.*)
      returning l_tabname,l_sqlcode

 if l_sqlcode <> 0 then
    error "Erro ",l_sqlcode  using "-----&"," na tabela ",l_tabname  clipped, " AVISE INFORMATICA"
    rollback work
    return
 end if

 whenever error continue
 execute p_cts16m03_002 using lr_cts10g00.lignum,lr_parm.nr_ligacao
 whenever error stop
 if sqlca.sqlcode = 0 then
    commit work
 else
    error 'Erro INSERT pcts16m03002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
    error 'cts16m03() / ', lr_cts10g00.lignum,' / ',lr_parm.nr_ligacao sleep 2
    rollback work
 end if

 end function
