#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: cts10g10                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 15/01/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- --------------------------------------#
#-----------------------------------------------------------------------------#

# utilizar módulo para criar funções que acessam as tabelas
# datmligacao e datrligapol

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts10g10_prep smallint

#---------------------------#
function cts10g10_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select a.lignum ",
                    " from datrligapol a, datmligacao b, datrligrcuccsmtv c ",
                    " where a.lignum = b.lignum ",
                    "   and a.lignum = c.lignum ",
                    " and a.succod  = ? ",
                    " and a.ramcod = ? ",
                    " and a.aplnumdig = ? ",
                    " and a.itmnumdig  =  ? ",
                    " and a.edsnumref =  ? ",
                    " and b.c24astcod = ? ",
                    " and b.lignum <> ? ",
                    " and c.rcuccsmtvcod in(2,3,4,7) ",
                    " order by 1 desc "

   prepare p_cts10g10_001 from l_sql_stmt
   declare c_cts10g10_001 cursor for p_cts10g10_001

   let m_cts10g10_prep = true

end function

#------- Verifica se tem ligacao para o assunto/apolice do parametro
# com motivo de terceiro
function cts10g10_ass_apol(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param     record
          ramcod       like datrligapol.ramcod,
          succod       like datrligapol.succod,
          aplnumdig    like datrligapol.aplnumdig,
          itmnumdig    like datrligapol.itmnumdig,
          edsnumref    like datrligapol.edsnumref,
          c24astcod    like datmligacao.c24astcod,
          lignum       like datmligacao.lignum
   end record

   define l_resultado      smallint,
          l_mensagem       char(70),
          l_lignum         like datmligacao.lignum

   let l_resultado = null
   let l_mensagem = null
   let l_lignum = null

   if m_cts10g10_prep is null or
      m_cts10g10_prep <> true then
      call cts10g10_prepare()
   end if

   let l_resultado = 1

   open c_cts10g10_001 using lr_param.succod,
                           lr_param.ramcod,
                           lr_param.aplnumdig,
                           lr_param.itmnumdig,
                           lr_param.edsnumref,
                           lr_param.c24astcod,
                           lr_param.lignum

   whenever error continue

   fetch c_cts10g10_001 into l_lignum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2 ## nao tem ligacao
         let l_mensagem = "Nao tem ligacao para o assunto informado"
      else
         let l_resultado = 3
         let l_mensagem = "Erro em ccts10g06001: ", sqlca.sqlcode
      end if
   end if

   close c_cts10g10_001

   return l_resultado, l_mensagem, l_lignum

end function
