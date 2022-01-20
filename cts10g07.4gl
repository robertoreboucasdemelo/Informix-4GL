#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
# .............................................................................#
# Sistema       : Central 24 H                                                 #
# Modulo        : cts10g07                                                     #
# Analista Resp : Ligia Mattge                                                 #
# PSI           : 187550                                                       #
#                 Obter quantidade de ligacoes                                 #
#                                                                              #
#------------------------------------------------------------------------------#
# Desenvolvimento : Daniel, Meta                                               #
# Liberacao       : 09/08/2004                                                 #
#------------------------------------------------------------------------------#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 23/09/06   Ligia Mattge  PSI 202720  Implementando cartao saude              #
#------------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS               #
#------------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint

#----------------------------------------------------------------
function cts10g07_prepare()
#----------------------------------------------------------------

 define l_sql char (500)


 let l_sql = " update datmligacao set lighorfnl = ? "
            ," where lignum = ? "

 prepare p_cts10g07_001 from l_sql

 let l_sql = " select count(*) from datrligapol,datmligacao "
            ," where datrligapol.lignum = datmligacao.lignum "
            ," and datrligapol.ramcod = ?    "
            ," and datrligapol.succod = ?    "
            ," and datrligapol.aplnumdig = ? "
            ," and datrligapol.itmnumdig = ? "

 prepare p_cts10g07_002 from l_sql
 declare c_cts10g07_001 cursor for p_cts10g07_002

 let l_sql = " select count(*) from datrligprp,datmligacao "
            ," where datrligprp.lignum = datmligacao.lignum "
            ," and datrligprp.prporg = ? "
            ," and datrligprp.prpnumdig = ?  "

 prepare p_cts10g07_003 from l_sql
 declare c_cts10g07_002 cursor for p_cts10g07_003


 let l_sql = " select count(*) from datrligsin,datmligacao "
            ," where datrligsin.lignum = datmligacao.lignum "
            ," and datrligsin.ramcod = ?  "
            ," and datrligsin.sinano = ?  "
            ," and datrligsin.sinnum = ?  "
            ," and datrligsin.sinitmseq = ?  "

 prepare p_cts10g07_004 from l_sql
 declare c_cts10g07_003 cursor for p_cts10g07_004

 let l_sql = " select count(*) from datrligppt,datmligacao "
            ," where datrligppt.lignum = datmligacao.lignum  "
            ," and datrligppt.cmnnumdig = ? "

 prepare p_cts10g07_005 from l_sql
 declare c_cts10g07_004 cursor for p_cts10g07_005

## CT 308846

 let l_sql = " select count(*) from datrligcor,datmligacao "
	     ," where datrligcor.lignum = datmligacao.lignum  "
             ," and   datrligcor.corsus = ? "

 prepare p_cts10g07_006 from l_sql
 declare c_cts10g07_005 cursor for p_cts10g07_006

 let l_sql = " select count(*) from datrligcgccpf,datmligacao "
            ," where datrligcgccpf.lignum = datmligacao.lignum  "
            ," and   datrligcgccpf.cgccpfnum = ? "
	    ," and   datrligcgccpf.cgcord    = ? "
	    ," and   datrligcgccpf.cgccpfdig = ? "

 prepare p_cts10g07_007 from l_sql
 declare c_cts10g07_006 cursor for p_cts10g07_007

 let l_sql = " select count(*) from datrligmat,datmligacao "
	   ," where datrligmat.lignum = datmligacao.lignum  "
	   ," and   datrligmat.funmat = ? "

 prepare p_cts10g07_008 from l_sql
 declare c_cts10g07_007 cursor for p_cts10g07_008

 let l_sql = " select count(*) from datrligtel,datmligacao "
	   ," where datrligtel.lignum = datmligacao.lignum  "
           ," and   datrligtel.teltxt = ? "

 prepare p_cts10g07_009 from l_sql
 declare c_cts10g07_008 cursor for p_cts10g07_009

 let l_sql = " select count(*) from datrligsau,datmligacao "
            ," where datrligsau.lignum = datmligacao.lignum "
            ," and datrligsau.crtnum = ?    "

 prepare p_cts10g07_010 from l_sql
 declare c_cts10g07_009 cursor for p_cts10g07_010
 let l_sql = " select count(*) from datrcntlig,datmligacao "
            ," where datrcntlig.lignum = datmligacao.lignum "
            ," and datrcntlig.psscntcod = ?    "
 prepare pcts10g07011 from l_sql
 declare ccts10g07011 cursor for pcts10g07011
 let m_prep = true

end function

#----------------------------------------#
function cts10g07_alt_horafinal(lr_param)
#----------------------------------------#

 define lr_param       record
        lignum         like datmligacao.lignum,
        lighorfnl      like datmligacao.lighorfnl
 end record

 define l_log          char(200)

 define lr_retorno record
        resultado    smallint,
        mensagem     char(60)
 end record

 if m_prep is null or
    m_prep <> true then
    call cts10g07_prepare()
 end if

 initialize lr_retorno.*  to null

 if lr_param.lignum is not null and
    lr_param.lighorfnl is not null then
    let lr_retorno.resultado = 1
    whenever error continue
    execute p_cts10g07_001 using lr_param.lighorfnl, lr_param.lignum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log =  "Erro UPDATE p_cts10g07_001 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log =  "CTS10G07 / cts10g07_alt_horafinal()", lr_param.lighorfnl,"/", lr_param.lignum
       call errorlog(l_log)
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem = 'Erro na atualizacao de datmligacao', sqlca.sqlcode
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem = " Os parametros sao nulos"
 end if

 return lr_retorno.*

end function


#---------------------------------#
function cts10g07_qtdlig(lr_param)
#---------------------------------#

 define lr_param     record
        succod       like datrligapol.succod,
        ramcod       like datrligapol.ramcod,
        aplnumdig    like datrligapol.aplnumdig,
        itmnumdig    like datrligapol.itmnumdig,
        prporg       like datrligprp.prporg,
        prpnumdig    like datrligprp.prpnumdig,
        sinano       like datrligsin.sinano,
        sinnum       like datrligsin.sinnum,
        sinitmseq    like datrligsin.sinitmseq,
        cmnnumdig    like datrligppt.cmnnumdig,
	corsus       like gcaksusep.corsus,      ## CT 308846
	cgccpfnum    like gsakseg.cgccpfnum,
	cgcord       like gsakseg.cgcord,
	cgccpfdig    like gsakseg.cgccpfdig,
	funmat       like isskfunc.funmat,
	ctttel       like datmreclam.ctttel,
        crtsaunum    like datrligsau.crtnum ## PSI 202720
 end record

 define l_count1      smallint
 define l_count2      smallint
 define l_count3      smallint
 define l_count4      smallint
 define l_count5      smallint
 define l_count6      smallint
 define l_count7      smallint
 define l_count8      smallint
 define l_count9      smallint
 define l_log         char(200)

 define lr_retorno    record
        resultado     smallint,
        mensagem      char(60),
        ligacoes      smallint
 end record

 if m_prep is null or
    m_prep <> true then
    call cts10g07_prepare()
 end if

 let l_count1 = 0
 let l_count2 = 0
 let l_count3 = 0
 let l_count4 = 0
 let l_count5 = 0
 let l_count6 = 0
 let l_count7 = 0
 let l_count8 = 0
 let l_count9 = 0

 initialize lr_retorno.*  to  null

 let lr_retorno.ligacoes = 0

 ### PSI 202720
 if  lr_param.crtsaunum is not null  then
     open c_cts10g07_009 using lr_param.crtsaunum
     whenever error continue
     fetch c_cts10g07_009 into l_count1
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_log = "Erro SELECT c_cts10g07_009 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        call errorlog(l_log)
        let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.crtsaunum
        call errorlog(l_log)
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligsau '
        return lr_retorno.*
     end if

     let lr_param.ramcod = null
     let lr_param.succod = null
     let lr_param.aplnumdig = null
     let lr_param.itmnumdig = null

 end if

 if  lr_param.ramcod is not null and
     lr_param.succod is not null and
     lr_param.aplnumdig is not null and
     lr_param.itmnumdig is not null then
     open c_cts10g07_001 using lr_param.ramcod
                            ,lr_param.succod
                            ,lr_param.aplnumdig
                            ,lr_param.itmnumdig
     whenever error continue
     fetch c_cts10g07_001 into l_count1
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_log = "Erro SELECT c_cts10g07_001 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        call errorlog(l_log)
        let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.ramcod, "/", lr_param.succod, "/",
                                                    lr_param.aplnumdig, "/", lr_param.itmnumdig
        call errorlog(l_log)
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligapol '
        return lr_retorno.*
     end if
 end if

 if lr_param.prporg is not null and
    lr_param.prpnumdig is not null then
    open c_cts10g07_002 using lr_param.prporg
                           ,lr_param.prpnumdig
    whenever error continue
    fetch c_cts10g07_002 into l_count2
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT c_cts10g07_002 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.prporg,"/", lr_param.prpnumdig
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligprp '
       return lr_retorno.*
    end if
 end if

 if lr_param.ramcod is not null and
    lr_param.sinano is not null and
    lr_param.sinnum is not null and
    lr_param.sinitmseq is not null then
    open c_cts10g07_003 using lr_param.ramcod
                           ,lr_param.sinano
                           ,lr_param.sinnum
                           ,lr_param.sinitmseq
    whenever error continue
    fetch c_cts10g07_003 into l_count3
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT c_cts10g07_003 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.ramcod,"/",lr_param.sinano, "/",
                                                   lr_param.sinnum,"/", lr_param.sinitmseq
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligsin '
       return lr_retorno.*
    end if
 end if

 if lr_param.cmnnumdig is not null then
    open c_cts10g07_004 using lr_param.cmnnumdig
    whenever error continue
    fetch c_cts10g07_004 into l_count4
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT c_cts10g07_004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.cmnnumdig
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligppt '
       return lr_retorno.*
    end if
 end if

   ## CT 308846
 if lr_param.corsus is not null then
    open c_cts10g07_005 using lr_param.corsus
    whenever error continue
    fetch c_cts10g07_005 into l_count5
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT c_cts10g07_005 / ",sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.corsus
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligcor '
       return lr_retorno.*
    end if
 end if

 ##==============================================================
 ## CT 308846
  if lr_param.cgccpfnum is not null and
     lr_param.cgcord is not null and
     lr_param.cgccpfdig is not null then
     open c_cts10g07_006 using lr_param.cgccpfnum, lr_param.cgcord, lr_param.cgccpfdig

    whenever error continue
    fetch c_cts10g07_006 into l_count6
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT c_cts10g07_006 / ",sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig()", lr_param.cgccpfnum, lr_param.cgcord,"-", lr_param.cgccpfdig
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligcgccpf '
       return lr_retorno.*
    end if
  end if

 ##==============================================================
 ## CT 308846
  if lr_param.funmat then
     open c_cts10g07_007 using lr_param.funmat

     whenever error continue
     fetch c_cts10g07_007 into l_count7
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_log = "Erro SELECT c_cts10g07_007 / ",sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        call errorlog(l_log)
        let l_log = "CTS10G07 / cts10g07_qtdlig() ", lr_param.funmat
        call errorlog(l_log)
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligmat '
        return lr_retorno.*
     end if
  end if
 ##==============================================================
 ## CT 308846

  if lr_param.ctttel then
     open c_cts10g07_008 using lr_param.ctttel

     whenever error continue
     fetch c_cts10g07_008 into l_count8
     whenever error stop
     if sqlca.sqlcode <> 0 then
	let l_log = "Erro SELECT c_cts10g07_008 / ",sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
        call errorlog(l_log)
        let l_log = "CTS10G07 / cts10g07_qtdlig() ", lr_param.ctttel
        call errorlog(l_log)
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrligtel '
        return lr_retorno.*
     end if
  end if

 ##==============================================================
 ## CT 308846

 # PSS
 if g_pss.psscntcod is not null then
    open ccts10g07011 using g_pss.psscntcod
    whenever error continue
    fetch ccts10g07011 into l_count9
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_log = "Erro SELECT ccts10g07011 / ",sqlca.sqlcode, " / ", sqlca.sqlerrd[2]
       call errorlog(l_log)
       let l_log = "CTS10G07 / cts10g07_qtdlig() ", g_pss.psscntcod
       call errorlog(l_log)
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro ',sqlca.sqlcode, ' em datrcntlig '
       return lr_retorno.*
    end if
 end if
 let lr_retorno.ligacoes = l_count1 + l_count2 + l_count3 + l_count4 + l_count5 + l_count6 + l_count7 + l_count8 + l_count9

 if lr_retorno.ligacoes > 0 then
    let lr_retorno.resultado = 1
 else
    let lr_retorno.resultado = 2
    let lr_retorno.mensagem = "Nao existe ligacao"
 end if

 return lr_retorno.*

end function
