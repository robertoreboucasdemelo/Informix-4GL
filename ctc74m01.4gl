#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctc74m01                                                   #
# ANALISTA RESP..: LIGIA MATTGE                                               #
# PSI/OSF........: PSI 202363                                                 #
#                  Modulo responsavel por obter informacoes das naturezas dos #
#                  socorristas (dbsrntzpstesp)                                #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep_sql smallint

#-------------------------#
function ctc74m01_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = " select 1 ",
                " from dbsrntzpstesp ",
               " where socntzcod = ? ",
                 " and srrcoddig = ? ",
                 " and espcod = ? "

  prepare pctc74m01010 from l_sql
  declare cctc74m01010 cursor for pctc74m01010  

  let l_sql = " select 1 ",
                " from dbsrntzpstesp ",
               " where socntzcod = ? ",
                 " and srrcoddig = ? "
  prepare pctc74m01011 from l_sql
  declare cctc74m01011 cursor for pctc74m01011  

 let m_prep_sql = true

end function

#Funcao que verifica se socorrista atende natureza/especialidade
# passada como parametro
#----------------------------------------------#
function ctc74m01_verificasocnat(param)
#----------------------------------------------#
   define param record
       srrcoddig  like datksrr.srrcoddig,
       socntzcod  like datmsrvre.socntzcod,
       espcod     like datmsrvre.espcod
   end record

   define l_sql  char(200)
   define l_aux  smallint
   
   let l_aux = 0
   
   if m_prep_sql is null or m_prep_sql <> true then
      call ctc74m01_prepare()
   end if
   
   if param.espcod is not null and param.espcod <> 0 then
      open cctc74m01010 using param.socntzcod,
                              param.srrcoddig,
                              param.espcod
      fetch cctc74m01010                        
      if sqlca.sqlcode <> 0 then
         #socorrista nao atende natureza/especialidade
         return false
      end if
      close cctc74m01010
      
   else
      open cctc74m01011 using param.socntzcod,
                              param.srrcoddig
      fetch cctc74m01011                        
      if sqlca.sqlcode <> 0 then
         #socorrista nao atende natureza/especialidade
         return false
      end if
      close cctc74m01011   
       
   end if    
   
   return true

end function

