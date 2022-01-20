#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Atendimento Segurado                          #
# Modulo         : cts19g00                                                    #
#                  Funcoes:                                                    #
#                  . Permissao para atendimento por assunto e                  #
#                  . Obtencao de senha do funcionario                          #
# Analista Resp. : Ligia Mattge                                                #
# PSI            : 188425                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 27/10/2004                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
#------------------------------------------------------------------------------#
database porto

define m_flgprep         smallint
define mr_ret            record
       stt               smallint,
       msg               char(80)
end record

# PREPARA COMANDOS SQL UTILIZADOS PELO MODULO
#-------------------------------------------------------------------------------
function cts19g00_prepara()
#-------------------------------------------------------------------------------
   define l_prep         char(1500),
          l_onde         char(80)
   if m_flgprep then
      return true
   end if

   whenever error go to ERROPREP

   let l_onde = "datrastfun"

   let l_prep = "select 1",
                "  from datrastfun",
                " where c24astcod = ?"
   prepare pcts19g000101 from l_prep
   declare ccts19g000101 cursor for pcts19g000101
   let l_prep = l_prep clipped,
                "   and empcod = ?",
                "   and funmat = ?"
   prepare pcts19g000202 from l_prep
   declare ccts19g000202 cursor for pcts19g000202

   let l_onde = "datkfun"
   let l_prep = "select funsnh",
                "  from datkfun",
                " where empcod = ?",
                "   and funmat = ?"
   prepare pcts19g000303 from l_prep
   declare ccts19g000303 cursor for pcts19g000303
   whenever error stop
   let m_flgprep = true
   return true
label ERROPREP:
#-------------
   let l_onde = " PREPARE ", l_onde
   call cts19g00_monta_ret(l_onde)

   return false

end function

# PERMISSAO PARA ATENDIMENTO POR ASSUNTO
#-------------------------------------------------------------------------------
function cts19g00_permissao_assunto(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          c24astcod      like datrastfun.c24astcod,
          empcod         like datrastfun.empcod,
          funmat         like datrastfun.funmat
   end record

#=> PREPARA COMANDOS
   if not cts19g00_prepara() then
      return mr_ret.*
   end if
   whenever error go to ERROPERMISS

#=> VERIFICA PERMISSAO PARA O ATENDIMENTO
   open  ccts19g000101 using lr_param.c24astcod
   fetch ccts19g000101
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 1
      let mr_ret.msg = "Assunto nao requer permissao para atendimento"
      return mr_ret.*
   end if

#=> VERIFICA PERMISSAO DO ATENDENTE
   open  ccts19g000202 using lr_param.*
   fetch ccts19g000202
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 2
      let mr_ret.msg = "Atendente sem permissao para utilizacao do assunto"
      return mr_ret.*
   end if
   whenever error stop
   call cts19g00_monta_ret("")
   return mr_ret.*
label ERROPERMISS:
#----------------
   call cts19g00_monta_ret(" datrastfun")
   return mr_ret.*

end function

#-------------------------------------------------------------------------------
function cts19g00_obter_senha(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          empcod         like datkfun.empcod,
          funmat         like datkfun.funmat
   end record
   define l_funsnh       like datkfun.funsnh
   let l_funsnh = null

#=> PREPARA COMANDOS
   if not cts19g00_prepara() then
      return mr_ret.*, l_funsnh
   end if

   whenever error go to ERROSENHA

#=> APURA SENHA DO ATENDENTE
   open  ccts19g000303 using lr_param.*
   fetch ccts19g000303  into l_funsnh
   if sqlca.sqlcode = notfound then
      let mr_ret.stt = 2
      let mr_ret.msg = "Funcionario nao cadastrado na Central 24h"
      return mr_ret.*, l_funsnh
   end if
   whenever error stop
   call cts19g00_monta_ret("")
   return mr_ret.*, l_funsnh
label ERROSENHA:
#--------------
   call cts19g00_monta_ret(" datkfun")
   return mr_ret.*, l_funsnh

end function

# MONTA RETORNO
#-------------------------------------------------------------------------------
function cts19g00_monta_ret(l_texto)
#-------------------------------------------------------------------------------
   define l_texto        char(80)

   if l_texto is null or
      l_texto = ""    or
      l_texto = " "   then
      let mr_ret.stt = 1
      let mr_ret.msg = null
   else
      let mr_ret.stt = 3
      let mr_ret.msg = "Erro ", sqlca.sqlcode, sqlca.sqlerrd[2], l_texto
   end if

end function
