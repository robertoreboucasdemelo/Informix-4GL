#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: cty29g00                                                   #
# ANALISTA RESP..: ROBERT LIMA                                                #
# PSI/OSF........: PSI-2011-06258-PR - CRM BASE UNICA - ENVIA AS ALTERAÇÕES NO#
#                  CADASTRO DE PRESTADOR PARA VIA MQ PARA CRM                 #
# ........................................................................... #
# DESENVOLVIMENTO: ROBERT LIMA                                                #
# LIBERACAO......: 22/08/2011                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------  ------------------------------------- #
# 30/05/12   Vinicius (CDS Baltico)     Correcao de tipo de logradouro, trata-#
#                                       mento de CPF/CNPJ, pesquisa de estado #
#                                       civil e data de nascimento            #
#-----------------------------------------------------------------------------#

#mudar para ir a produção
globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"

database porto

#----------------------------------------
function cty29g00_prepare()
#----------------------------------------

  define l_sql char(1000)
  
  #Consulta principal
  let l_sql = "SELECT nomrazsoc,   ", # Razão Social
              "       cgccpfnum,   ", # CPF/CNPJ número
              "       cgcord,      ", # CPF/CNPJ ordem
              "       cgccpfdig,   ", # CPF/CNPJ digito 
              "       pestip,      ", # Tipo da pessoa(F/J)
              "       pcpatvcod,   ", # Atividade principal                         
              "       renfxacod,   ", # Código da Faixa da Renda Salarial PF
              "       maides,      ", # E-mail’s
              "       lgdtip,      ", # Tipo logradouro (único)
              "       endlgd,      ", # Logradouro (único)
              "       lgdnum,      ", # Número Logradouro (único)              
              "       endcep,      ", # CEP
              "       endcepcmp,   ", # CEP Complemento
              "       endbrr,      ", # Bairro
              "       endcid,      ", # Cidade
              "       endufd,      ", # UF
              "       dddcod,      ", # DDD
              "       teltxt,      ", # Número telefone da pessoa
              "       pstcoddig,   ", # Identificação do prestador
              "       liqptrfxacod,", # Faturamento Presumido/capital circulante  da PJ
              "       cmtdat       ", # Data de Contratacao - Vinicius Morais
              "  FROM dpaksocor    ",
              " WHERE pstcoddig = ?"
  prepare pcty29g000001 from l_sql
  declare ccty29g000001 cursor with hold for pcty29g000001
  
  #Consulta para prestadores Pessoa Fisica
  let l_sql = "SELECT dpakctd.ctdtip ",
              "  FROM dparpstctd ,dpakctd               ",
              " WHERE dparpstctd.ctdcod = dpakctd.ctdcod",
              "       AND dparpstctd.pstcoddig = ?"
  prepare pcty29g000002 from l_sql
  declare ccty29g000002 cursor with hold for pcty29g000002
    
  #Busca empresa do prestador
  let l_sql = "SELECT ciaempcod FROM dparpstemp",
              " WHERE pstcoddig = ?",
              " order by ciaempcod"
  prepare pcty29g000003 from l_sql
  declare ccty29g000003 cursor with hold for pcty29g000003
  
  #Consulta de estado civil e data de nascimento
  let l_sql = "SELECT a.estcvlcod, a.nscdat FROM datksrr a, datrsrrpst b",
              " WHERE b.pstcoddig = ?",
              "   AND a.pestip = 'F'",
              "   AND a.srrcoddig = b.srrcoddig"
  prepare pcty29g000004 from l_sql
  declare ccty29g000004 cursor with hold for pcty29g000004 
  
  let l_sql = "SELECT a.srrnom,      ", # Razão Social
              "       a.cgccpfnum,   ", # CPF/CNPJ número
              "       a.cgcord,      ", # CPF/CNPJ ordem
              "       a.cgccpfdig,   ", # CPF/CNPJ digito 
              "       a.pestip,      ", # Tipo da pessoa(F/J)
              "       a.maides,      ", # E-mail’s
              "       b.lgdtip,      ", # Tipo logradouro (único)
              "       b.lgdnom,      ", # Logradouro (único)
              "       b.lgdnum,      ", # Número Logradouro (único)              
              "       b.endcep,      ", # CEP
              "       b.endcepcmp,   ", # CEP Complemento
              "       b.brrnom,      ", # Bairro
              "       b.cidnom,      ", # Cidade
              "       b.ufdcod,      ", # UF
              "       b.dddcod,      ", # DDD
              "       b.telnum,      ", # Número telefone da pessoa
              "       a.srrcoddig,   ", # Identificação do prestador
              "       a.estcvlcod,   ", # Estado Civil
              "       a.nscdat,      ", # Data de nascimento
              "       a.caddat       ", # Data de cadastramento
              "  FROM datksrr a, datksrrend b   ",
              " WHERE a.srrcoddig = ? ",
              "   AND a.srrcoddig = b.srrcoddig"
  prepare pcty29g000005 from l_sql
  declare ccty29g000005 cursor with hold for pcty29g000005          
  
  let l_sql = "select distinct pstcoddig,vigfnl ",
              "  from datrsrrpst    ",
              " where srrcoddig = ? ",
              " group by pstcoddig,vigfnl ",
              " order by vigfnl desc"
  prepare pcty29g000006 from l_sql
  declare ccty29g000006 cursor with hold for pcty29g000006     
  
  let l_sql = "select pcpatvcod     ",
              "  from dpaksocor     ",
              " WHERE pstcoddig = ? "
  prepare pcty29g000007 from l_sql
  declare ccty29g000007 cursor with hold for pcty29g000007
  
   let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco" '
            , '    and cpodes = ?               '
  prepare pcty29g000008 from l_sql
  declare ccty29g000008 cursor for pcty29g000008
  
  let l_sql = ' select count(*)                 '
            , '   from datkdominio              '
            , '  where cponom = "tipo_endereco_nav" '
            , '    and cpodes = ?               '
  prepare pcty29g000009 from l_sql
  declare ccty29g000009 cursor for pcty29g000009
  
end function

#----------------------------------------
function cty29g00_EnviaCrm_Prt(param)
#----------------------------------------
   
   define param record
      pstcoddig like dpaksocor.pstcoddig
   end record
   
   define l_cty29g00 record
      nomrazsoc    like dpaksocor.nomrazsoc   ,
      cgccpfnum    like dpaksocor.cgccpfnum   ,
      cgcord       like dpaksocor.cgcord      ,
      cgccpfdig    like dpaksocor.cgccpfdig   ,
      pestip       like dpaksocor.pestip      ,
      pcpatvcod    like dpaksocor.pcpatvcod   ,            
      renfxacod    like dpaksocor.renfxacod   ,
      maides       like dpaksocor.maides      ,
      lgdtip       like dpaksocor.lgdtip      ,
      endlgd       like dpaksocor.endlgd      ,
      lgdnum       like dpaksocor.lgdnum      ,      
      endcep       like dpaksocor.endcep      ,
      endcepcmp    like dpaksocor.endcepcmp   ,
      endbrr       like dpaksocor.endbrr      ,
      endcid       like dpaksocor.endcid      ,
      endufd       like dpaksocor.endufd      ,
      dddcod       like dpaksocor.dddcod      ,
      teltxt       like dpaksocor.teltxt      ,
      pstcoddig    like dpaksocor.pstcoddig   ,
      liqptrfxacod like dpaksocor.liqptrfxacod,
      cmtdat       like dpaksocor.cmtdat
   end record
   
   define ws record
      ctdtip    char(30),
      ciaempcod like dparpstemp.ciaempcod
   end record
   
   define lr_ret record
       errcod      smallint
      ,errdes      char(50)
      ,mensagemRet char(32766)
   end record
      
   define l_retorno    smallint,
          dataCorrente date,
          l_estcivil   smallint          
          
   call cty29g00_prepare()
   
   #---[INICIANDO VARIAVEIS]----
   
   initialize gr_pessoa.*        to null
   initialize gr_grupo_origem.*  to null   
   initialize gr_pes_emails      to null
   initialize gr_pes_logradouros to null
   initialize gr_pes_contatos    to null
   initialize gr_documentos      to null
   initialize gr_doc_prod        to null
   initialize gr_item            to null
   initialize gr_logradouros     to null
   initialize gr_doc_contatos    to null
   initialize gr_doc_emails      to null
   initialize l_cty29g00.*       to null
   initialize ws.* to null  
   let dataCorrente = today     
         
   #---[SELECIONA O PRESTADOR ALTERADO]----
   whenever error continue
   open ccty29g000001 using param.pstcoddig
   fetch ccty29g000001 into l_cty29g00.nomrazsoc,
                            l_cty29g00.cgccpfnum,
                            l_cty29g00.cgcord   ,
                            l_cty29g00.cgccpfdig,
                            l_cty29g00.pestip   ,
                            l_cty29g00.pcpatvcod,                                                    
                            l_cty29g00.renfxacod,
                            l_cty29g00.maides   ,
                            l_cty29g00.lgdtip   ,
                            l_cty29g00.endlgd   ,
                            l_cty29g00.lgdnum   ,
                            l_cty29g00.endcep   ,
                            l_cty29g00.endcepcmp,
                            l_cty29g00.endbrr   ,
                            l_cty29g00.endcid   ,
                            l_cty29g00.endufd   ,
                            l_cty29g00.dddcod   ,
                            l_cty29g00.teltxt   ,
                            l_cty29g00.pstcoddig,
                            l_cty29g00.liqptrfxacod,
                            l_cty29g00.cmtdat                               
   close ccty29g000001
   whenever error stop
   whenever error continue
   open ccty29g000003 using param.pstcoddig
   fetch ccty29g000003 into ws.ciaempcod
   close ccty29g000003
   whenever error stop
   
   if (l_cty29g00.cgccpfnum is null or l_cty29g00.cgccpfnum = "") or      
      (l_cty29g00.cgccpfdig is null or l_cty29g00.cgccpfdig = "") then
      
      let lr_ret.errcod = 1
      let lr_ret.mensagemRet = "CPF/CNPJ NULO OU BRANCO"
      
      return  lr_ret.errcod     
             ,lr_ret.mensagemRet      
   end if 
   
   if l_cty29g00.pestip = "J" and (l_cty29g00.cgcord  is null or l_cty29g00.cgcord    = "")  then
      
      let lr_ret.errcod = 1
      let lr_ret.mensagemRet = "CPF/CNPJ NULO OU BRANCO"
      
      return  lr_ret.errcod     
             ,lr_ret.mensagemRet 
   end if
   
   if l_cty29g00.pestip = 'F' then
      #Para tipo de pessoa como 'F' buscar tipo de relacionamento da pessoa com o prestador
   
      whenever error continue
      open ccty29g000002 using param.pstcoddig
      fetch ccty29g000002 into ws.ctdtip
      close ccty29g000002           
      whenever error stop
      
      case ws.ctdtip
        when 'P' let gr_pessoa.tiprel = 3
        when 'C' let gr_pessoa.tiprel = 2
        when 'A' let gr_pessoa.tiprel = 5
      end case
      
     # Buscar estado civil e data de nascimento - Vinicius Morais
     whenever error continue
     open ccty29g000004 using param.pstcoddig
     fetch ccty29g000004 into l_estcivil, gr_pessoa.nascimento
     close ccty29g000004
     whenever error stop
     
     #De/para - Estado Civil - Vinicius Morais
     case l_estcivil
        when 3 #amasiado
           let gr_pessoa.estcivil = 6
        when 5 #divorciado
           let gr_pessoa.estcivil = 4
        when 6 #Separado
           let gr_pessoa.estcivil = 4
        when 7 #Viuvo
           let gr_pessoa.estcivil = 5       
     otherwise
           let gr_pessoa.estcivil = l_estcivil
     end case
                                  
   else
     initialize gr_pessoa.tiprel to null
   end if 
   
   let gr_grupo_origem.mvtorgcod = 49
   let gr_grupo_origem.xmlgrp = 1
   
   let gr_pessoa.nome                  = cty29g00_remove_caracteres(l_cty29g00.nomrazsoc)
 
   let gr_pessoa.cpfcnpjnum            = l_cty29g00.cgccpfnum    using "<<<<<<<&&&&&"
   let gr_pessoa.cnpjordem             = l_cty29g00.cgcord       using "<<<&"
   let gr_pessoa.cpfcnpjdig            = l_cty29g00.cgccpfdig    using "&&"
   let gr_pessoa.papel                 = 3  #Papel  = 3  Prestador
   let gr_pessoa.origem                = 49 #Origem = 49 Porto Socorro
   let gr_pessoa.situacao              = 1  #Vivo
   let gr_pessoa.tippess               = l_cty29g00.pestip       clipped
   let gr_pessoa.presttip              = l_cty29g00.pcpatvcod    using "<&"
   let gr_pessoa.codemp                = ws.ciaempcod            using "<<<&"
   let gr_pessoa.dtinicio              = l_cty29g00.cmtdat    
   if l_cty29g00.pestip = 'F' then
      let gr_pessoa.fxrendacod         = l_cty29g00.renfxacod    using "&"
   else
      initialize gr_pessoa.fxrendacod to null
   end if

   let gr_pessoa.codprestorigem        = l_cty29g00.pstcoddig    using "<<<<<<<&"
   let gr_pessoa.faturampj             = l_cty29g00.liqptrfxacod using "<&"

   #Carregando contatos do prestador  
   let gr_pes_contatos[1].fonetip      = 2 #Comercial 
   let gr_pes_contatos[1].foneddd      = l_cty29g00.dddcod       using "<<<<&"
   
   display "l_cty29g00.teltxt = ", l_cty29g00.teltxt
   
   call cty29g00_formatatelefone(l_cty29g00.teltxt)
      returning l_cty29g00.teltxt
   
   display "retorno l_cty29g00.teltxt = ", l_cty29g00.teltxt
   
   let gr_pes_contatos[1].fonenum = l_cty29g00.teltxt
   
   display "gr_pes_contatos[1].fonenum = ", gr_pes_contatos[1].fonenum

   #Carregando email do prestador
   let gr_pes_emails[1].emailtip       = 2
   let gr_pes_emails[1].email          = l_cty29g00.maides       clipped
   let gr_pes_emails[1].emailflgopt    = 'N'
   let gr_pes_emails[1].emaildtflgopt  = dataCorrente            using "dd/MM/yyyy"
   
   #Carregando endereço do prestador
   
   #Inicio - Controle do tipo de logradouro - Vinicius Morais
   if l_cty29g00.lgdtip is null then
      call cty29g00_retira_tipo_lougradouro_navteq(l_cty29g00.endlgd)
      returning gr_pes_logradouros[1].logradtip                               
               ,gr_pes_logradouros[1].lograd
                  
      let gr_pes_logradouros[1].logradtip = 
         gr_pes_logradouros[1].logradtip clipped
        
    if gr_pes_logradouros[1].logradtip is null or
        gr_pes_logradouros[1].logradtip = "" then
       call cty29g00_retira_tipo_lougradouro(l_cty29g00.endlgd)
       returning gr_pes_logradouros[1].logradtip                               
                ,gr_pes_logradouros[1].lograd             

       let gr_pes_logradouros[1].logradtip = 
         gr_pes_logradouros[1].logradtip clipped
              
        if gr_pes_logradouros[1].logradtip is null or
           gr_pes_logradouros[1].logradtip = "" then
           let gr_pes_logradouros[1].logradtip = "RUA"
        end if
     end if 
     
     
   else
      let gr_pes_logradouros[1].logradtip = l_cty29g00.lgdtip       clipped
      let gr_pes_logradouros[1].lograd    = cty29g00_remove_caracteres(l_cty29g00.endlgd)
   end if
  #Fim - Controle do tipo de logradouro - Vinicius Morais
  
   let gr_pes_logradouros[1].logradnum   = l_cty29g00.lgdnum       using "<<<<&"
   let gr_pes_logradouros[1].cep         = l_cty29g00.endcep       using "<<<<&"
   let gr_pes_logradouros[1].cepcompl    = l_cty29g00.endcepcmp    using "&&&"
   let gr_pes_logradouros[1].bairro      = cty29g00_remove_caracteres(l_cty29g00.endbrr)
   let gr_pes_logradouros[1].cidade      = cty29g00_remove_caracteres(l_cty29g00.endcid)
   let gr_pes_logradouros[1].uf          = l_cty29g00.endufd       clipped
   let gr_pes_logradouros[1].finalidlogr = 1 #Não temos esta informação, sempre enviar 1(Sede)
   
   call bgclf953_gera_xml_crm()
     returning lr_ret.errcod
              ,lr_ret.errdes
              ,lr_ret.mensagemRet
   
   if lr_ret.errcod < 0 then
      #plano de contingencia
      #call gravaFlagCRM()
      display lr_ret.errdes clipped, ' - ', lr_ret.mensagemRet clipped
   else
      display "DADOS ENVIADOS AO CRM - OK - ",lr_ret.errcod
   end if

   return  lr_ret.errcod                  
          ,lr_ret.mensagemRet

end function

#----------------------------------------
function cty29g00_EnviaCrm_Srr(param)
#----------------------------------------
   
   define param record
      srrcoddig like datksrr.srrcoddig
   end record
   
   define l_nova record
      nomrazsoc    like datksrr.srrnom         ,
      cgccpfnum    like datksrr.cgccpfnum      ,
      cgcord       like datksrr.cgcord         ,
      cgccpfdig    like datksrr.cgccpfdig      ,
      pestip       like datksrr.pestip         ,
      maides       like datksrr.maides         ,
      lgdtip       like datksrrend.lgdtip      ,
      endlgd       like datksrrend.lgdnom      ,
      lgdnum       like datksrrend.lgdnum      ,      
      endcep       like datksrrend.endcep      ,
      endcepcmp    like datksrrend.endcepcmp   ,
      endbrr       like datksrrend.brrnom      ,
      endcid       like datksrrend.cidnom      ,
      endufd       like datksrrend.ufdcod      ,
      dddcod       like datksrrend.dddcod      ,
      teltxt       like datksrrend.telnum      ,
      srrcoddig    like datksrr.srrcoddig      ,   
      estcvlcod    like datksrr.estcvlcod      , 
      nscdat       like datksrr.nscdat         ,
      dtinicio     like datksrr.caddat         ,
      pcpatvcod    like dpaksocor.pcpatvcod
   end record
   
   define ws record
      ctdtip    char(30),
      ciaempcod like dparpstemp.ciaempcod
   end record
   
   define lr_ret record
       errcod      smallint
      ,errdes      char(50)
      ,mensagemRet char(32766)
   end record
      
   define l_retorno    smallint,
          dataCorrente date,
          l_estcivil   smallint,
          l_pstcoddig  like datrsrrpst.pstcoddig
          
   call cty29g00_prepare()
   
   #---[INICIANDO VARIAVEIS]----
   
   initialize gr_pessoa.*        to null
   initialize gr_grupo_origem.*  to null   
   initialize gr_pes_emails      to null
   initialize gr_pes_logradouros to null
   initialize gr_pes_contatos    to null
   initialize gr_documentos      to null
   initialize gr_doc_prod        to null
   initialize gr_item            to null
   initialize gr_logradouros     to null
   initialize gr_doc_contatos    to null
   initialize gr_doc_emails      to null
   initialize l_nova.*       to null
   initialize ws.* to null  
   let dataCorrente = today
   
   #---[SELECIONA O PRESTADOR ALTERADO]----   
   whenever error continue
   open ccty29g000005 using param.srrcoddig
   fetch ccty29g000005 into l_nova.nomrazsoc,
                            l_nova.cgccpfnum,
                            l_nova.cgcord   ,
                            l_nova.cgccpfdig,
                            l_nova.pestip   ,
                            l_nova.maides   ,
                            l_nova.lgdtip   ,
                            l_nova.endlgd   ,
                            l_nova.lgdnum   ,
                            l_nova.endcep   ,
                            l_nova.endcepcmp,
                            l_nova.endbrr   ,
                            l_nova.endcid   ,
                            l_nova.endufd   ,
                            l_nova.dddcod   ,
                            l_nova.teltxt   ,
                            l_nova.srrcoddig,
                            l_nova.estcvlcod,
                            l_nova.nscdat,
                            l_nova.dtinicio                       
   close ccty29g000005
 
   if (l_nova.cgccpfnum is null or l_nova.cgccpfnum = "") or      
      (l_nova.cgccpfdig is null or l_nova.cgccpfdig = "") then
      
      let lr_ret.errcod = 1
      let lr_ret.mensagemRet = "CPF/CNPJ NULO OU BRANCO"
      
      return  lr_ret.errcod     
             ,lr_ret.mensagemRet      
   end if 
   
   if l_nova.pestip = "J" and (l_nova.cgcord  is null or l_nova.cgcord    = "")  then
      
      let lr_ret.errcod = 1
      let lr_ret.mensagemRet = "CPF/CNPJ NULO OU BRANCO"
      
      return  lr_ret.errcod     
             ,lr_ret.mensagemRet 
   end if
   
   if l_nova.pestip = 'F' then
      #Para tipo de pessoa como 'F' buscar tipo de relacionamento da pessoa com o prestador
   
      let gr_pessoa.tiprel = 7 #Socorrista eh sempre funcionario
      
     # Buscar estado civil e data de nascimento - Vinicius Morais

     #De/para - Estado Civil - Vinicius Morais
     case l_nova.estcvlcod
        when 3 #amasiado
           let gr_pessoa.estcivil = 6
        when 5 #divorciado
           let gr_pessoa.estcivil = 4
        when 6 #Separado
           let gr_pessoa.estcivil = 4
        when 7 #Viuvo
           let gr_pessoa.estcivil = 5       
        otherwise
           let gr_pessoa.estcivil = l_nova.estcvlcod
     end case
                                  
   else
     initialize gr_pessoa.tiprel to null
   end if 
   
   let gr_grupo_origem.mvtorgcod = 49
   let gr_grupo_origem.xmlgrp = 1
   
   let gr_pessoa.nome = cty29g00_remove_caracteres(l_nova.nomrazsoc)

   let gr_pessoa.cpfcnpjnum            = l_nova.cgccpfnum    using "<<<<<<<&&&&&"
   let gr_pessoa.cnpjordem             = l_nova.cgcord       using "<<<&"
   let gr_pessoa.cpfcnpjdig            = l_nova.cgccpfdig    using "&&"
   let gr_pessoa.papel                 = 3  #Papel  = 3  Prestador
   let gr_pessoa.origem                = 49 #Origem = 49 Porto Socorro
   let gr_pessoa.situacao              = 1  #Vivo
   let gr_pessoa.tippess               = l_nova.pestip       clipped
   
   whenever error continue
   open ccty29g000006 using l_nova.srrcoddig
   fetch ccty29g000006 into l_pstcoddig   
   close ccty29g000006
   
   open ccty29g000007 using l_pstcoddig
   fetch ccty29g000007 into l_nova.pcpatvcod
   
   if sqlca.sqlcode <> 0 then
      let gr_pessoa.presttip           = ""
   else
      let gr_pessoa.presttip           = l_nova.pcpatvcod using "<&"
   end if
   
   close ccty29g000007
   
   whenever error stop
   
   let gr_pessoa.codemp                = 1           using "<<<&"
   let gr_pessoa.dtinicio              = l_nova.dtinicio
   let gr_pessoa.dtinirelac            = l_nova.dtinicio
   let gr_pessoa.dtabertura            = l_nova.dtinicio
   
   let gr_pessoa.nascimento            = l_nova.nscdat   
   initialize gr_pessoa.fxrendacod to null

   let gr_pessoa.codprestorigem        = l_nova.srrcoddig    using "<<<<<<<&"
   let gr_pessoa.faturampj             = 0 

   #Carregando contatos do prestador
   let gr_pes_contatos[1].fonetip      = 2 #Comercial
   let gr_pes_contatos[1].foneddd      = l_nova.dddcod       using "<<<<&"
   
   display "l_nova.teltxt = ", l_nova.teltxt
   
   call cty29g00_formatatelefone(l_nova.teltxt)
      returning l_nova.teltxt
   
   display "retorno l_nova.teltxt = ", l_nova.teltxt
   
   let gr_pes_contatos[1].fonenum = l_nova.teltxt
   
   display "gr_pes_contatos[1].fonenum = ", gr_pes_contatos[1].fonenum 

   #Carregando email do prestador
   let gr_pes_emails[1].emailtip       = 2
   let gr_pes_emails[1].email          = l_nova.maides       clipped
   let gr_pes_emails[1].emailflgopt    = 'N'
   let gr_pes_emails[1].emaildtflgopt  = dataCorrente            using "dd/MM/yyyy"
   
   #Carregando endereço do prestador
   
   #Inicio - Controle do tipo de logradouro - Vinicius Morais
   if l_nova.lgdtip is null then
      call cty29g00_retira_tipo_lougradouro_navteq(l_nova.endlgd)
      returning gr_pes_logradouros[1].logradtip                               
               ,gr_pes_logradouros[1].lograd
                  
      let gr_pes_logradouros[1].logradtip = 
         gr_pes_logradouros[1].logradtip clipped
        
    if gr_pes_logradouros[1].logradtip is null or
        gr_pes_logradouros[1].logradtip = "" then
       call cty29g00_retira_tipo_lougradouro(l_nova.endlgd)
       returning gr_pes_logradouros[1].logradtip                               
                ,gr_pes_logradouros[1].lograd             

       let gr_pes_logradouros[1].logradtip = 
         gr_pes_logradouros[1].logradtip clipped
              
        if gr_pes_logradouros[1].logradtip is null or
           gr_pes_logradouros[1].logradtip = "" then
           let gr_pes_logradouros[1].logradtip = "RUA"
        end if
     end if 
     
     
   else
      let gr_pes_logradouros[1].logradtip = l_nova.lgdtip       clipped
      let gr_pes_logradouros[1].lograd    = cty29g00_remove_caracteres(l_nova.endlgd)   

   end if
  #Fim - Controle do tipo de logradouro - Vinicius Morais
  
   let gr_pes_logradouros[1].logradnum   = l_nova.lgdnum       using "<<<<&"
   let gr_pes_logradouros[1].cep         = l_nova.endcep       using "<<<<&"
   let gr_pes_logradouros[1].cepcompl    = l_nova.endcepcmp    using "&&&"
   let gr_pes_logradouros[1].bairro      = cty29g00_remove_caracteres(l_nova.endbrr)
   let gr_pes_logradouros[1].cidade      = cty29g00_remove_caracteres(l_nova.endcid)

   let gr_pes_logradouros[1].uf          = l_nova.endufd       clipped
   let gr_pes_logradouros[1].finalidlogr = 1 #Não temos esta informação, sempre enviar 1(Sede)
   
   call bgclf953_gera_xml_crm()
     returning lr_ret.errcod
              ,lr_ret.errdes
              ,lr_ret.mensagemRet
   
   if lr_ret.errcod < 0 then
      display lr_ret.errdes clipped, ' - ', lr_ret.mensagemRet clipped
   else
      display "DADOS ENVIADOS AO CRM - OK - ",lr_ret.errcod
   end if

end function

function cty29g00_formatatelefone(l_teltxt)

 define l_teltxt char(40),
        l_count  smallint,
        l_indice smallint,
        l_txt    like dpaksocor.teltxt
      
 let l_teltxt = l_teltxt[1,9]
 let l_count = length(l_teltxt)     
 
 for l_indice = 1 to l_count
    
    if l_teltxt[l_indice] = '/' or
       l_teltxt[l_indice] = '-' or
       l_teltxt[l_indice] = ' ' then
       continue for
    end if
    
    let l_txt = l_txt clipped, l_teltxt[l_indice] clipped
 end for
 
 display "l_txtt = ", l_txt
 
 return l_txt
end function



# -----------------------------------------------------------------------------
function cty29g00_retira_tipo_lougradouro(l_string)
# -----------------------------------------------------------------------------
 define l_string      char(100)
 define l_j           smallint
 define l_i           smallint
 define l_tamanho     smallint
 define l_rua         char(100)
 define l_tipo_logradouro char(30)
 define l_count       smallint

 let l_i = 1
 let l_tamanho = 0
 let l_rua = ''
 let l_tipo_logradouro = ''

 #REMOVE ESPACOS DO INICIO DO LOGRADOURO
 let l_string = cty29g00_ltrim(l_string)

 let l_tamanho = length(l_string)

 for l_i = 1 to l_tamanho
     if l_string[l_i] = ' ' then
        let l_tipo_logradouro = l_string[1,l_i-1]

        whenever error continue
          open ccty29g000008 using l_tipo_logradouro
          fetch ccty29g000008 into l_count
        whenever error stop

        if l_count > 0 then
           let l_rua = l_string[l_i+1,l_tamanho]
        end if

        exit for
     end if
 end for
 close ccty29g000008

 let l_tamanho = length(l_tipo_logradouro)
 for l_j = 1 to l_tamanho
     if l_tipo_logradouro[l_j] = '.' then
        let l_tipo_logradouro[l_j] = ' '
     end if
 end for

 let l_tipo_logradouro = l_tipo_logradouro clipped

 if l_rua = ''  or
    l_rua = ' ' or
    l_rua is null then
    return ' ', l_string
 else
    return l_tipo_logradouro
         , l_rua

 end if

end function

# -----------------------------------------------------------------------------
 function cty29g00_retira_tipo_lougradouro_navteq(l_string)
# -----------------------------------------------------------------------------
 define l_string          char(100)
 define l_j               smallint
 define l_i               smallint
 define l_tamanho         smallint
 define l_rua             char(100)
 define l_tipo_logradouro char(30)
 define l_count           smallint

 let l_i = 1
 let l_tamanho = 0
 let l_rua = ''
 let l_tipo_logradouro = ''

 #REMOVE ESPACOS DO INICIO DO LOGRADOURO
 let l_string = cty29g00_ltrim(l_string)

 let l_tamanho = length(l_string)

  for l_i = 1 to l_tamanho
     if l_string[l_i] = ' ' then
        let l_tipo_logradouro = l_string[1,l_i-1]

        whenever error continue
          open ccty29g000009 using l_tipo_logradouro
          fetch ccty29g000009 into l_count
        whenever error stop

        if l_count > 0 then
           let l_rua = l_string[l_i+1,l_tamanho]
        end if

        exit for
     end if
 end for
 close ccty29g000009

 let l_tamanho = length(l_tipo_logradouro)
 for l_j = 1 to l_tamanho
     if l_tipo_logradouro[l_j] = '.' then
        let l_tipo_logradouro[l_j] = ' '
     end if
 end for

 let l_tipo_logradouro = l_tipo_logradouro clipped

 if l_rua = ''  or
    l_rua = ' ' or
    l_rua is null then
    return ' ', l_string
 else
    return l_tipo_logradouro
         , l_rua

 end if

end function


#--------------------------------#
function cty29g00_ltrim(l_string)
#--------------------------------#
# RETINA ESPACOS DO INICIO DO TEXTO
 define l_string          char(100)

 while l_string[1] = ' '
    let l_string = l_string[2,99]
 end while

 return l_string

end function

#----------------------------------------#
function cty29g00_remove_caracteres(texto)
#----------------------------------------#

   define texto char(250)

   define l_i, l_j, l_texto, l_acento integer
   define l_caracter char(1)
   define l_especiais,l_limpa,l_textoLimpo  char(200)

   let l_especiais = "´`^~¨#¬$%&*'()_{}:;[]<>=?!ªº§¢£@ÄÅÁÂÀÃäáâàãÉÊËÈéêëèÍÎÏÌíîïìÖÓÔÒÕöóôòõÜÚÛüúûùÇçÑñ",'"'
   let l_limpa     = "                                AAAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUuuuuCcNn",' '
   let l_texto = length (texto)
   let l_acento = length (l_especiais)
   let l_textoLimpo = texto


    for l_i = 1 to l_texto
      let l_caracter = texto[l_i]

      for l_j = 1 to l_acento
         if l_caracter = l_especiais[l_j] then
            let l_textoLimpo[l_i] = l_limpa[l_j]
         end if
      end for

   end for
   return l_textoLimpo clipped

end function