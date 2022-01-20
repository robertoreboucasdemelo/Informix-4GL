################################################################################
# Sistema  : CTS      - Central 24 Horas                         DEZEMBRO/2008 #
# Modulo   : ctf00m07 - Localiza a Cidade Sede -                               #
# Analista : Carla Rampazzo                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
#                           * * * Comentarios * * *                            #
#                                                                              #
################################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'


database porto

define mr_param       record
       ufdcod         like glakcid.ufdcod
      ,cidnom         like glakcid.cidnom
end record


define mr_retorno   record
       coderro      smallint
      ,deserro      char(70)
      ,cidsedcod    like datrcidsed.cidsedcod
      ,cidsednom    like glakcid.cidnom
end record


#-------------------------------------------------------------------------------
function ctf00m07(lr_param)
#-------------------------------------------------------------------------------

   define lr_param       record
          ufdcod         like glakcid.ufdcod
         ,cidnom         like glakcid.cidnom
   end record

   initialize mr_retorno.* to null
   set isolation to dirty read

   let mr_retorno.coderro = 0

   ---> Atribui parametros para variavel modular
   let mr_param.* = lr_param.*

   ---> Monta Prepares
   call ctf00m07_prepare()


   ---> Localiza Cidade Sede
   call ctf00m07_localiza()


   return mr_retorno.*

end function

#-------------------------------------------------------------------------------
function ctf00m07_prepare()
#-------------------------------------------------------------------------------

   define l_sql           char(3000)

   initialize l_sql to null

   ---> Busca Codigo da Cidade
   let l_sql = "select cidcod "
              ,"  from glakcid "
              ," where cidnom = ? "
              ,"   and ufdcod = ? "
   prepare p_ctf00m07_001 from l_sql
   declare c_ctf00m07_001 cursor for p_ctf00m07_001


   ---> Verifica Cidade Sede
   let l_sql = "select cidsedcod "
              ,"  from datrcidsed "
              ," where cidcod = ? "
   prepare p_ctf00m07_002 from l_sql
   declare c_ctf00m07_002 cursor for p_ctf00m07_002


   ---> Localiza nome da Cidade Sede
   let l_sql = "select cidnom "
              ,"  from glakcid "
              ," where cidcod = ?  "
   prepare p_ctf00m07_003 from l_sql
   declare c_ctf00m07_003 cursor for p_ctf00m07_003

end function

#-------------------------------------------------------------------------------
function ctf00m07_localiza()
#-------------------------------------------------------------------------------

   define lr_ctf00m07   record
          cidcod        like glakcid.cidcod
         ,cont          smallint
   end record


   initialize  lr_ctf00m07.*  to null

   let lr_ctf00m07.cont = 0

   ---> Valida Parametros
   if mr_param.cidnom    is null  or
      mr_param.ufdcod    is null  then
      let mr_retorno.cidsednom = " "
      let mr_retorno.cidsedcod = " "
      let mr_retorno.coderro   = 1
      let mr_retorno.deserro   = "Parametros de entrada invalidos -->"
                                ," Cidade: " , mr_param.cidnom
                                ," UF: "     , mr_param.ufdcod
      return
   end if


   ---> Localizar Codigo da Cidade pelo Nome / UF
   open    c_ctf00m07_001 using mr_param.cidnom
                             ,mr_param.ufdcod
   foreach c_ctf00m07_001  into lr_ctf00m07.cidcod

      let lr_ctf00m07.cont = lr_ctf00m07.cont + 1

      ---> Localiza Cidade Sede
      whenever error continue
      open  c_ctf00m07_002 using lr_ctf00m07.cidcod
      fetch c_ctf00m07_002 into  mr_retorno.cidsedcod


      if sqlca.sqlcode <> 0 then
         let mr_retorno.cidsednom = " "
         let mr_retorno.cidsedcod = " "
         let mr_retorno.coderro   = sqlca.sqlcode
         let mr_retorno.deserro   = "Esta cidade nao esta relacionada a nenhuma"
                                   ," Cidade Sede."
         return

      end if

      close c_ctf00m07_002
      whenever error stop

      ---> Localiza Nome da Cidade Sede
      whenever error continue
      open  c_ctf00m07_003 using mr_retorno.cidsedcod
      fetch c_ctf00m07_003 into  mr_retorno.cidsednom


      if sqlca.sqlcode <> 0 then
         let mr_retorno.cidsednom = " "
         let mr_retorno.cidsedcod = " "
         let mr_retorno.coderro   = sqlca.sqlcode
         let mr_retorno.deserro   = "Nao consta o cadastro da Cidade Sede."
         return
      end if

      close c_ctf00m07_003
      whenever error stop
   end foreach

   set isolation to committed read

   if lr_ctf00m07.cont = 0 then
      let mr_retorno.cidsednom = " "
      let mr_retorno.cidsedcod = " "
      let mr_retorno.coderro   = 1
      let mr_retorno.deserro   = "Cidade informada nao esta Cadastrada."
   end if

   return

end function  ###  ctf00m07

