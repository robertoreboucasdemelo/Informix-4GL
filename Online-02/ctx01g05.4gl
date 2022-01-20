###############################################################################
#                PORTO SEGURO CIA DE SEGUROS GERAIS                           #
#.............................................................................#
# Sistema        : CT24H                                                      #
# Modulo         : ctx01g05                                                   #
#                  Funcoes da apolice do terceiro segurado                    #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 187887                                                     #
# Data           : 20/12/2004                                                 #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
# Data       Autor Fabrica        PSI    Alteracao                            #
# ---------- -------------------  ------ -------------------------------------#
#                                                                             #
###############################################################################

database porto

define m_prep    char(01)
      ,m_log    char(100)

#------------------------------------------------------------------------------
function ctx01g05_prepare()
#------------------------------------------------------------------------------

define l_sql     char(1000)

   let l_sql = " select atdsrvnum, atdsrvano, succod, aplnumdig, itmnumdig "
              ,"   from datmvclapltrc "
              ,"  where atdsrvnum = ? "
              ,"    and atdsrvano = ? "
   prepare p_ctx01g05_001 from l_sql
   declare c_ctx01g05_001 cursor for p_ctx01g05_001
   let l_sql = " insert into datmvclapltrc (atdsrvnum  "
              ,"                           ,atdsrvano  "
              ,"                           ,succod     "
              ,"                           ,aplnumdig  "
              ,"                           ,itmnumdig) "
              ," values (?,?,?,?,?)                    "
   prepare pctx01g05002 from l_sql

   let l_sql = " update datmvclapltrc "
              ,"    set succod = ? "
              ,"       ,aplnumdig = ? "
              ,"       ,itmnumdig = ? "
              ,"  where atdsrvnum = ? "
              ,"    and atdsrvano = ? "
   prepare pctx01g05003 from l_sql
   let m_prep = "S"

end function #ctx01g05_prepare

#------------------------------------------------------------------------------
function ctx01g05_incluir_apol_ter(lr_ctx01g0501)
#------------------------------------------------------------------------------

define lr_ctx01g0501 record
   atdsrvnum         like datmvclapltrc.atdsrvnum
  ,atdsrvano         like datmvclapltrc.atdsrvano
  ,succod            like datmvclapltrc.succod
  ,aplnumdig         like datmvclapltrc.aplnumdig
  ,itmnumdig         like datmvclapltrc.itmnumdig
end record

define lr_ctx01g0502 record
   atdsrvnum         like datmvclapltrc.atdsrvnum
  ,atdsrvano         like datmvclapltrc.atdsrvano
  ,succod            like datmvclapltrc.succod
  ,aplnumdig         like datmvclapltrc.aplnumdig
  ,itmnumdig         like datmvclapltrc.itmnumdig
end record

define lr_ctx01g0506 record
   erro              smallint
  ,msg               char(80)
end record
   initialize lr_ctx01g0502 to null
   initialize lr_ctx01g0506 to null
   if lr_ctx01g0501.atdsrvnum is null or lr_ctx01g0501.atdsrvano is null or
      lr_ctx01g0501.succod    is null or lr_ctx01g0501.aplnumdig is null or
      lr_ctx01g0501.itmnumdig is null then
      let lr_ctx01g0506.erro = 3
      let lr_ctx01g0506.msg = "Parametros Nulos"
      return lr_ctx01g0506.*
   end if

   #Retorno: 1-OK; 2-Erro de banco

   if m_prep is null or
      m_prep = ""    then
      call ctx01g05_prepare()
   end if
   let lr_ctx01g0506.erro = 1
   let lr_ctx01g0506.msg = ""

   whenever error continue
      open c_ctx01g05_001 using lr_ctx01g0501.atdsrvnum
                             ,lr_ctx01g0501.atdsrvano
      fetch c_ctx01g05_001 into lr_ctx01g0502.*
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
         let m_log = "Erro no SELECT cctx01g05001.",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(m_log)
         let m_log =  "Funcao ctx01g05_incluir_apol_ter()/",lr_ctx01g0501.atdsrvnum,"/",lr_ctx01g0501.atdsrvano
         call errorlog(m_log)
         let lr_ctx01g0506.erro = 2
         let lr_ctx01g0506.msg = "Erro ",sqlca.sqlcode, " na inclusao/","alteracao de datmvclapltrc"
      end if
      if sqlca.sqlcode = 100 then
         whenever error continue
            execute pctx01g05002 using lr_ctx01g0501.*
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode < 0 then
               let m_log = "Erro no INSERT pctx01g05002.",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
               call errorlog(m_log)
               let m_log = "Funcao ctx01g05_incluir_apol_ter()/",lr_ctx01g0501.atdsrvnum,"/",lr_ctx01g0501.atdsrvano,"/"
                     ,lr_ctx01g0501.succod,"/",lr_ctx01g0501.aplnumdig,"/",lr_ctx01g0501.itmnumdig
               call errorlog(m_log)
               let lr_ctx01g0506.erro = 2
               let lr_ctx01g0506.msg = "Erro ",sqlca.sqlcode, " na inclusao/alteracao de datmvclapltrc"
            end if
         end if
      end if
   else
      whenever error continue
         execute pctx01g05003 using lr_ctx01g0501.succod
                                   ,lr_ctx01g0501.aplnumdig
                                   ,lr_ctx01g0501.itmnumdig
                                   ,lr_ctx01g0501.atdsrvnum
                                   ,lr_ctx01g0501.atdsrvano
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            let m_log = "Erro no UPDATE pctx01g05003.",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(m_log)
            error "Funcao ctx01g05_incluir_apol_ter()/",lr_ctx01g0501.succod,"/",lr_ctx01g0501.aplnumdig,"/"
                  ,lr_ctx01g0501.itmnumdig,"/",lr_ctx01g0501.atdsrvnum,"/",lr_ctx01g0501.atdsrvano
            call errorlog(m_log)
            let lr_ctx01g0506.erro = 2
            let lr_ctx01g0506.msg = "Erro ",sqlca.sqlcode, " na inclusao/","alteracao de datmvclapltrc"
         end if
      end if
   end if
   close c_ctx01g05_001

   return lr_ctx01g0506.*

end function #ctx01g05_incluir_apol_ter

#------------------------------------------------------------------------------
function ctx01g05_obter_apol_ter(lr_ctx01g0503)
#------------------------------------------------------------------------------

define lr_ctx01g0503 record
   atdsrvnum         like datmvclapltrc.atdsrvnum
  ,atdsrvano         like datmvclapltrc.atdsrvano
end record

define lr_ctx01g0504 record
   atdsrvnum         like datmvclapltrc.atdsrvnum
  ,atdsrvano         like datmvclapltrc.atdsrvano
  ,succod            like datmvclapltrc.succod
  ,aplnumdig         like datmvclapltrc.aplnumdig
  ,itmnumdig         like datmvclapltrc.itmnumdig
end record

define lr_ctx01g0505 record
   erro              smallint
  ,msg               char(80)
end record
   initialize lr_ctx01g0504 to null
   initialize lr_ctx01g0505 to null

   if m_prep is null or
      m_prep = ""    then
      call ctx01g05_prepare()
   end if
   whenever error continue
      open c_ctx01g05_001 using lr_ctx01g0503.atdsrvnum
                             ,lr_ctx01g0503.atdsrvano
      fetch c_ctx01g05_001 into lr_ctx01g0504.*
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
         let m_log = "Erro no SELECT cctx01g05001.",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(m_log)
         let m_log = "Funcao ctx01g05_obter_apol_ter()/",lr_ctx01g0503.atdsrvnum,"/",lr_ctx01g0503.atdsrvano
         call errorlog(m_log)
         let lr_ctx01g0505.erro = 3
         let lr_ctx01g0505.msg = "Erro ",sqlca.sqlcode," em datmvclapltrc."
      end if
      if sqlca.sqlcode = 100 then
         let lr_ctx01g0505.erro = 2
         let lr_ctx01g0505.msg = "Apolice do terceiro nao encontrada"
      end if
   else
      let lr_ctx01g0505.erro = 1
      let lr_ctx01g0505.msg = ""
   end if
   close c_ctx01g05_001
   return lr_ctx01g0505.erro
         ,lr_ctx01g0505.msg
         ,lr_ctx01g0504.succod
         ,lr_ctx01g0504.aplnumdig
         ,lr_ctx01g0504.itmnumdig
end function #ctx01g05_obter_apol_ter

