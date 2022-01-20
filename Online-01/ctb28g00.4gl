#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CT24H                                                      #
# MODULO.........: CTB28G00                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: 249.203                                                    #
# OBJETIVO.......: FUNCOES GERAIS DO RIS.                                     #
# ........................................................................... #
# DESENVOLVIMENTO: META                                                       #
# LIBERACAO......: 17/11/2009                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM            ALTERACAO                      #
# ---------- --------------  ----------------- ------------------------------ #
# 07/05/2012 BRQ             PSI-2011-22593/PR Liberação do Laudo RIS via GPS #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'
       
  define m_ctb28g00_prep smallint

#-------------------------#
function ctb28g00_prepare()
#-------------------------#

  define l_sql char(1000)

  let l_sql = "select pstcoddig, socvclcod ",
              "  from datmsrvacp acp       ",
              " where acp.atdsrvnum = ?    ",
              "   and acp.atdsrvano = ?    ",
              "   and acp.atdsrvseq =  (select max(atdsrvseq)        ",
              "                           from datmsrvacp maxseq     ",
              "                          where maxseq.atdsrvnum = ?  ",
              "                            and maxseq.atdsrvano = ? )"
  prepare p_ctb28g00_001 from l_sql
  declare c_ctb28g00_001 cursor for p_ctb28g00_001

  let l_sql = "select risprcflg ",
              "  from dpaksocor ",
              " where pstcoddig = ? "
  prepare p_ctb28g00_002 from l_sql
  declare c_ctb28g00_002 cursor for p_ctb28g00_002

  let l_sql = "select atdsrvorg, atdrsdflg, ciaempcod ",
              "  from datmservico ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare p_ctb28g00_003 from l_sql
  declare c_ctb28g00_003 cursor for p_ctb28g00_003

  let l_sql = " select datkassunto.risprcflg ",
              "  from datkassunto, datmligacao ",
              " where datkassunto.c24astcod = datmligacao.c24astcod  ",
                " and datmligacao.atdsrvnum = ? ",
                " and datmligacao.atdsrvano = ? ",
                " and datmligacao.lignum    = (select min(lignum)",
                                             " from datmligacao ligpri ",
                                            " where ligpri.atdsrvnum = datmligacao.atdsrvnum ",
                                              " and ligpri.atdsrvano = datmligacao.atdsrvano)"
  prepare p_ctb28g00_004 from l_sql
  declare c_ctb28g00_004 cursor for p_ctb28g00_004

  let l_sql = "select mdt.mdtcod, mdt.mdtcfgcod, mdt.mdtctrcod ", #PSI-2011-22593/PR - mdt.mdtcod
              "  from datkmdt mdt, datkveiculo vcl ",
              " where mdt.mdtcod = vcl.mdtcod ",
              "   and vcl.socvclcod = ? "
  prepare p_ctb28g00_005 from l_sql
  declare c_ctb28g00_005 cursor for p_ctb28g00_005

  let l_sql = "select rislaucod ",
              "  from dpcmgpsrislau ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare p_ctb28g00_006 from l_sql
  declare c_ctb28g00_006 cursor for p_ctb28g00_006
  let l_sql = "select atdsrvnum,    ",
              "       atdsrvano     ",
              "  from dpamris       ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare pctb28g00007 from l_sql
  declare cctb28g00007 cursor for pctb28g00007

  let l_sql = "select eqptip        ",
              "  from datkveiculo   ",
              " where socvclcod = ? "
  prepare pctb28g00008 from l_sql
  declare cctb28g00008 cursor for pctb28g00008

  let l_sql = "select mdtcfgcod   ",
              "  from datkmdt     ",
              " where mdtcod = ?  "
  prepare pctb28g00009 from l_sql
  declare cctb28g00009 cursor for pctb28g00009

  let l_sql = "select cpodes      ",
              "  from iddkdominio ",
              " where cponom = 'eqttipcod' ",
              "   and cpocod = ? "
  prepare pctb28g00010 from l_sql
  declare cctb28g00010 cursor for pctb28g00010

  let l_sql = "select 1           ",
              "  from iddkdominio ",
              " where cponom = 'mdlwvtris' ",
              "   and cpodes = ? "              
  prepare pctb28g00011 from l_sql
  declare cctb28g00011 cursor for pctb28g00011

    let m_ctb28g00_prep = true

end function

#-------------------------------------------#
function ctb28g00_com_ris(lr_parametro)
#-------------------------------------------#
  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         tipo         char(3)
  end record

  define ws  record
         pstcoddig     like dpaksocor.pstcoddig,
         socvclcod     like datkveiculo.socvclcod,
         mdtcod        like datkmdt.mdtcod,
         prs_risprcflg like dpaksocor.risprcflg,
         ast_risprcflg like datkassunto.risprcflg,
         mdtcfgcod     like datkmdt.mdtcfgcod,
         mdtctrcod     like datkmdt.mdtctrcod,
         atdsrvorg     like datmservico.atdsrvorg,
         atdrsdflg     like datmservico.atdrsdflg,
         ciaempcod     like datmservico.ciaempcod
  end record
  
  define l_consulta    smallint               #PSI-2011-22593/PR
  define l_mdtcfgcod  like datkmdt.mdtcfgcod  #PSI-2011-22593/PR
  define l_cpodes     like iddkdominio.cpodes #PSI-2011-22593/PR
  
  
  if m_ctb28g00_prep is null or
     m_ctb28g00_prep <> true then
     call ctb28g00_prepare()
  end if

  initialize ws, l_consulta, l_mdtcfgcod, l_cpodes to null

  # --RECUPERA O PRESTADOR DO SERVICO-- #
  open c_ctb28g00_001 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_ctb28g00_001 into ws.pstcoddig,
                          ws.socvclcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_ctb28g00_001 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
  end if

  # --RECUPERA SE O PRESTADOR PREENCHE RIS-- #
  open c_ctb28g00_002 using ws.pstcoddig
  whenever error continue
  fetch c_ctb28g00_002 into ws.prs_risprcflg
  whenever error stop
  if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_ctb28g00_002 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
  end if

  # --RECUPERA INFORMACAO DO SERVICO-- #
  open c_ctb28g00_003  using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_ctb28g00_003 into ws.atdsrvorg,
                            ws.atdrsdflg,
                            ws.ciaempcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_ctb28g00_003 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
  end if

  # --RECUPERA INFORMACAO DO ASSUNTO-- #
  open c_ctb28g00_004 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_ctb28g00_004 into ws.ast_risprcflg
  whenever error stop
  if sqlca.sqlcode <> 0 then
        error 'Erro SELECT c_ctb28g00_004 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
  end if

  # --VERIFICA SE JA FOI PREENCHIDO-- #
  open c_ctb28g00_006 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch c_ctb28g00_006 into ws.ast_risprcflg
  whenever error stop
  if sqlca.sqlcode = 0 then
     error 'RIS ja preenchido!'
     return false
  else
     if sqlca.sqlcode <> 100 then
           error 'Erro SELECT c_ctb28g00_006 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
           return false
     end if  	
  end if

  # --VERIFICA SE RIS JA FOI PREENCHIDO EM OUTRA TABELA-- #
  open cctb28g00007 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error continue
  fetch cctb28g00007 into lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  whenever error stop
  if sqlca.sqlcode = 0 then
     error 'RIS ja preenchido!'
     return false
  else
     if sqlca.sqlcode <> 100 then
           error 'Erro SELECT cctb28g00007 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
           return false
     end if  	
  end if

  #PSI-2011-22593/PR
  # --VERIFICA EQUIPAMENTO - VIA GPS OU WEB-- #
  let lr_parametro.tipo = "WEB"
  open cctb28g00008 using ws.socvclcod
  whenever error continue
  fetch cctb28g00008 into l_consulta 
  whenever error stop
  if sqlca.sqlcode < 0 then
     error 'Erro SELECT cctb28g00008 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
     return false
  end if
  # Verifica se o codigo do equipamento <> de nulo, caso seja então é alterado o parametro para GPS  
  if l_consulta is not null then
     let lr_parametro.tipo = "GPS"
  end if
  #FIM PSI-2011-22593/PR

  if lr_parametro.tipo = "GPS" then
     # --RECUPERA INFORMACAO DO MDT-- #
     open c_ctb28g00_005 using ws.socvclcod
     whenever error continue
     fetch c_ctb28g00_005 into ws.mdtcod,
                               ws.mdtcfgcod,
                               ws.mdtctrcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
           error 'Erro SELECT c_ctb28g00_005 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
           return false
     end if

     #PSI-2011-22593/PR
     # --BUSCA O CODIGO DO EQUIPAMENTO PARA VALIDAR NA IDDKDOMINIO-- #
     let l_consulta = 0
     open cctb28g00009 using ws.mdtcod
     whenever error continue
     fetch cctb28g00009 into l_mdtcfgcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro SELECT cctb28g00009 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
     end if
     
     # --BUSCA NOME EQUIPAMENTO PRESTADOR NA TABELA DE DOMINIO-- #
     open cctb28g00010 using l_mdtcfgcod
     whenever error continue
     fetch cctb28g00010 into l_cpodes
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error 'Erro SELECT cctb28g00010 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
        return false
     end if    
     
     # --VERIFICA EQUIPAMENTO PRESTADOR NA TABELA DE DOMINIO HABILITADO-- #
     open cctb28g00011 using l_cpodes
     whenever error continue
     fetch cctb28g00011 into l_consulta
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error 'Erro SELECT cctb28g00011 ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
           return false
        else
           let l_consulta = 0
        end if
     end if           
     #FIM PSI-2011-22593/PR

     if ws.prs_risprcflg = "S" and  # PRESTADOR PREENCHE RIS
        ws.ast_risprcflg = "S" and  # ASSUNTO SOLICITA RIS
        ws.atdrsdflg    <> "S" and  # NAO EM RESIDENCIA
        #ws.mdtcfgcod     = 5   and  # EQUIPAMENTO W700 #PSI-2011-22593/PR
        l_consulta       = 1   and   # PSI-2011-22593/PR - Verifica Equipamento Habilitado
        ws.atdsrvorg     = 4   then  # ORIGEM ROMOCAO
        #ws.mdtctrcod     = 3   then # CONTROLADORA 3 - PSI-2011-22593/PR Validação Retirada
        return true
     else
        return false
     end if
  else # WEB
     if ws.prs_risprcflg = "S" and  # PRESTADOR PREENCHE RIS
        ws.ast_risprcflg = "S" and  # ASSUNTO SOLICITA RIS
        ws.atdrsdflg    <> "S" and  # NAO EM RESIDENCIA
        ws.atdsrvorg     = 4   then  # ORIGEM ROMOCAO
        return true
     else
        return false
     end if
  end if

end function
