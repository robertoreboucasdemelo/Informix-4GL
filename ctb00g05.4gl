#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Porto Socorro                                               #
# Modulo         : ctb00g05                                                    #
#                  Interface VB - 4GL com Sinistros                            #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 183440 - Modulo de interface VB-4GL para recuperacao dos    #
#                           dados de contabilizacao de Carro-Extra             #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Liberacao      : 20/09/2004                                                  #
#..............................................................................#
#                                                                              #
#                         * * *  ALTERACOES  * * *                             #
#                                                                              #
# Data       Analista Resp/Autor Fabrica PSI/Alteracao                         #
# ---------- --------------------------- --------------------------------------#
# 30/12/2009 Patricia W.                 Projeto SUCCOD - Smallint             #
#------------------------------------------------------------------------------#
#
globals "/homedsa/projetos/dssqa/producao/I4GLParams.4gl"

define mr_saida           record
       empcod             like ctimsocprvrat.empcod,
       succod             like ctimsocprvrat.succod,
       cctcod             like ctimsocprvrat.cctcod,
       ratvlr             like ctimsocprvrat.ratvlr
end record
define m_atdsrvnum        like datrservapol.atdsrvnum,
       m_atdsrvano        like datrservapol.atdsrvano
define m_retorno          char(5000),
       m_msgerr           char(500),
       m_flgprep          smallint

# FUNCAO PRINCIPAL => TRATA PARAMETRO E COMANDA DEMAIS FUNCOES
#------------------------------------------------------------------------------#
function executeService (l_servico) #=> NOME FIXO (Utilizado pelo MQ-SERVICE)
#------------------------------------------------------------------------------#
   define l_servico          char(50)
    
   let mr_saida.empcod = 0
   let mr_saida.succod = 0
   let mr_saida.cctcod = 0
   let mr_saida.ratvlr = 0
   let m_retorno = null

   if not ctb00g05_prepare() then
      return m_retorno
   end if

   if l_servico = "BuscaDadosContabilizacaoCarroExtra" then
      call ctb00g05_busca_dados_cce()
   else
      let m_msgerr = "ERRO - SERVICO - ", l_servico
      call ctb00g05_monta_ret()
   end if
    
   return m_retorno
    
end function

# PREPARA COMANDOS 'SQL'
#------------------------------------------------------------------------------#
function ctb00g05_prepare ()
#------------------------------------------------------------------------------#
   define l_prep             char(1500)

   if m_flgprep then
      return true
   end if

   whenever error go to ERROPREP

   let l_prep = "select a.atdsrvano, a.atdsrvnum",
                "  from datrservapol a, datmavisrent r",
                " where a.succod    = ?",
                "   and a.ramcod    = ?",
                "   and a.aplnumdig = ?",
                "   and a.itmnumdig = ?",
                "   and r.atdsrvnum = a.atdsrvnum",
                "   and r.atdsrvano = a.atdsrvano",
                "   and r.avialgmtv = 3", # Benef Oficinas
                " order by 1 desc, 2 desc"
   prepare pctb00g050101 from l_prep
   declare cctb00g050101 cursor for pctb00g050101

   let l_prep = "select empcod, succod, cctcod, ratvlr",
                "  from ctimsocprvrat",
                " where atdsrvnum = ?",
                "   and atdsrvano = ?"
   prepare pctb00g050202 from l_prep
   declare cctb00g050202 cursor for pctb00g050202
   
   whenever error stop
   
   let m_flgprep = true
   
   return true
   
label ERROPREP:

   let m_msgerr = "ERRO - PREPARE - ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
   call ctb00g05_monta_ret()
   
   return false

end function

# EFETUA OS ACESSOS AS TABELAS DO BANCO 'PORTO'
#------------------------------------------------------------------------------#
function ctb00g05_busca_dados_cce()
#------------------------------------------------------------------------------#
   define l_succod           like datrservapol.succod,
          l_ramcod           like datrservapol.ramcod,
          l_aplnumdig        like datrservapol.aplnumdig,
          l_itmnumdig        like datrservapol.itmnumdig

   let l_succod    = g_paramval[1]
   let l_ramcod    = g_paramval[2]
   let l_aplnumdig = g_paramval[3]
   let l_itmnumdig = g_paramval[4]

#=> JOIN:: DATRSERVAPOL e DATMAVISRENT (ORDER BY DESC) -> PEGA O MAIOR...
   whenever error continue
   open  cctb00g050101 using l_succod,
                             l_ramcod,
                             l_aplnumdig,
                             l_itmnumdig
   fetch cctb00g050101  into m_atdsrvano,
                             m_atdsrvnum
   whenever error stop
   if ctb00g05_excecao() then
      return
   end if

#=> CTIMSOCRVRAT -> DADOS PARA RETORNO
   whenever error continue
   open  cctb00g050202 using m_atdsrvnum,
                             m_atdsrvano
   fetch cctb00g050202  into mr_saida.empcod,
                             mr_saida.succod,
                             mr_saida.cctcod,
                             mr_saida.ratvlr
   whenever error stop
   if ctb00g05_excecao() then
      return
   end if

   let m_msgerr = ""
   call ctb00g05_monta_ret()

end function

# TRATA EXCECOES DOS ACESSOS
#------------------------------------------------------------------------------#
function ctb00g05_excecao()
#------------------------------------------------------------------------------#

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let m_msgerr = "PAGAMENTO PORTO SOCORRO NAO ENCONTRADO"
      else
         let m_msgerr = "ERRO - SELECT - ", sqlca.sqlcode," - ",sqlca.sqlerrd[2]
      end if
      call ctb00g05_monta_ret()
      return true
   end if

   if m_atdsrvnum is null     or
      m_atdsrvano is null     or
      mr_saida.empcod is null or
      mr_saida.succod is null or
      mr_saida.cctcod is null or
      mr_saida.ratvlr is null then
      let m_msgerr = "PAGAMENTO PORTO SOCORRO NAO ENCONTRADO"
      call ctb00g05_monta_ret()
      return true
   end if

   return false

end function

# MONTA O RETORNO NO FORMATO 'XML'
#------------------------------------------------------------------------------#
function ctb00g05_monta_ret()
#------------------------------------------------------------------------------#

   let m_retorno =
       "<?xml version='1.0' encoding='ISO-8859-1'?>",
          "<Retorno>",
             "<Empresa>",
                mr_saida.empcod using "<<<<",
                "</Empresa>",
             "<Sucursal>",
                mr_saida.succod using "<<<<<",  #"<<<<",  #projeto succod
                "</Sucursal>",
             "<CodigoCentroCusto>",
                mr_saida.cctcod using "<<<<<<<<",
                "</CodigoCentroCusto>",
             "<Valor>",
                mr_saida.ratvlr using "<<<<<<<<<<<<<<<&.&&",
                "</Valor>",
             "<MensagemErro>",
                m_msgerr clipped,
                "</MensagemErro>",
          "</Retorno>"

end function
