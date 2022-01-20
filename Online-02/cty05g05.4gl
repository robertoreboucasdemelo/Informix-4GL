#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTY05G05                                                   #
# ANALISTA RESP..: Roberto Melo                                               #
# PSI/OSF........: Projeto Leveza das Apolices Automovel                      #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: Amilton, Meta                                              #
# LIBERACAO......: 25/10/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_prep smallint
define m_host like ibpkdbspace.srvnom #Humberto Segregacao

function cty05g05_prepare()

    define l_sql char(500)

   let m_host = fun_dba_servidor("CT24HS")
   let l_sql = " delete from porto@",m_host clipped,":abdmparc ",
               " where succod = ? ",
               " and aplnumdig = ? "
   prepare cty05g05001 from l_sql

   let l_sql = " delete from porto@",m_host clipped,":abbm0km ",
               " where succod = ? ",
               " and aplnumdig = ? "
   prepare cty05g05002 from l_sql

   let l_sql = " delete from porto@",m_host clipped,":abbmapp ",
               " where succod = ? ",
               " and aplnumdig = ? "
   prepare cty05g05003 from l_sql

   let l_sql = " delete from porto@",m_host clipped,":abbmcondesp ",
               " where succod = ? ",
               " and aplnumdig = ? "
   prepare cty05g05004 from l_sql

   let l_sql = "delete from porto@",m_host clipped,":abcmaces ",
               "where succod = ? ",
               "and aplnumdig = ? "
   prepare cty05g05005 from l_sql

   let l_sql = "delete from porto@",m_host clipped,":abbmquestionario ",
               "where succod = ? ",
               "and aplnumdig = ? "
   prepare cty05g05006 from l_sql

   let l_sql = "delete from porto@",m_host clipped,":abbmquesttxt ",
               "where succod = ? ",
               "and aplnumdig = ? "
   prepare cty05g05007 from l_sql

   let l_sql = "delete from porto@",m_host clipped,":abcmdoc ",
               "where succod = ? ",
               "and aplnumdig = ? "
   prepare cty05g05008 from l_sql

   let l_sql = "delete from porto@",m_host clipped,":abbmvida2 ",
               "where succod = ? ",
               "and aplnumdig = ? "
   prepare cty05g05009 from l_sql


   let m_prep = true


end function


function cty05g05_exclui_apolice(lr_param)

    define lr_param record
           succod    smallint
          ,aplnumdig decimal(9,0)
    end record

    define lr_retorno record
           coderro smallint
          ,mens    char(300)
    end record

    initialize lr_retorno.* to null
    let lr_retorno.coderro = 0

    if (lr_param.succod is null or
        lr_param.succod = 0) or
       (lr_param.aplnumdig is null or
        lr_param.aplnumdig = 0 ) then
        let lr_retorno.coderro = 999
        let lr_retorno.mens = "Paramentros de Entrada estão nulos "
        return lr_retorno.*
   end if

   if m_prep is null or
      m_prep = 0 then
      call cty05g05_prepare()
   end if

   let lr_retorno.coderro = 0


   whenever error continue
   execute cty05g05001 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop


   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abdmparc "
      return lr_retorno.*
   end if

   whenever error continue

   execute cty05g05002 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbm0km "
      return lr_retorno.*
   end if

   whenever error continue


   execute cty05g05003 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbmapp "
      return lr_retorno.*
   end if


   whenever error continue



   execute cty05g05004 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbmcondesp "
      return lr_retorno.*
   end if


   whenever error continue

   execute cty05g05005 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abcmaces "
      return lr_retorno.*
   end if


   whenever error continue

   execute cty05g05006 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbmquestionario "
      return lr_retorno.*
   end if


   whenever error continue

   execute cty05g05007 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbmquesttxt "
      return lr_retorno.*
   end if


   whenever error continue

   execute cty05g05008 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abcmdoc "
      return lr_retorno.*
   end if


   whenever error continue

   execute cty05g05009 using lr_param.succod
                            ,lr_param.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.mens = "Erro < ",sqlca.sqlcode clipped , " > ao excluir apolice da tabela abbmvida2 "
      return lr_retorno.*
   end if

   return lr_retorno.*

end function


