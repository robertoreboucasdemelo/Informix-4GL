#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd05g00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: 205206                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATRVCLEMP           #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 25/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

  define m_prep    smallint

#-------------------------#
function ctd05g00_prep()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select ciaempcod, socvclcod ",
                " from datrvclemp ",
               " where ciaempcod = ? ",
               "   and socvclcod = ? "
  prepare pctd05g00001 from l_sql
  declare cctd05g00001 cursor for pctd05g00001
  
  let l_sql = "select ciaempcod ",
              " from datrvclemp ",
              " where socvclcod = ? ",
              " order by ciaempcod "
  prepare pctd05g00002 from l_sql
  declare cctd05g00002 cursor for pctd05g00002            
  
  let l_sql = "delete from datrvclemp ",
              " where socvclcod = ? "
  prepare pctd05g00003 from l_sql
  
  let l_sql = "insert into datrvclemp ",
              " (socvclcod, ciaempcod) ",
              " values (?,?) "
  prepare pctd05g00004 from l_sql

  let m_prep = true

end function

#Objetivo: validar a empresa e a locadora/veiculo na tabela
#-----------------------------------------#
function ctd05g00_valida_empveic(param)
#-----------------------------------------#
  define param record
         ciaempcod like datrvclemp.ciaempcod,
         socvclcod like datrvclemp.socvclcod
  end record

  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 

  if m_prep is null or m_prep <> true then
     call ctd05g00_prep()
  end if

  ### INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null

  open cctd05g00001 using param.ciaempcod, 
                          param.socvclcod

  whenever error continue
  fetch cctd05g00001 into param.ciaempcod, 
                          param.socvclcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa/prestador relacionados"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd05g00001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  close cctd05g00001

  return l_retorno, l_mensagem

end function

#Objetivo: Buscar todas as empresas cadastradas para a locadora/veiculo
#-----------------------------------------#
function ctd05g00_empresas(param)
#-----------------------------------------#
  define param record
         tp_retorno  smallint,
         socvclcod   like datrvclemp.socvclcod
  end record
  
  define a_empresas array[15] of record
         ciaempcod like datrvclemp.ciaempcod
  end record
  
  define l_aux      smallint
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 
  define l_total    smallint
  
  initialize a_empresas to null
  let l_aux = 1
  let l_retorno = 1
  let l_mensagem = null
  let l_total = 0
  
  if m_prep is null or m_prep <> true then
     call ctd05g00_prep()
  end if
  
  open cctd05g00002 using param.socvclcod

  whenever error continue
  foreach cctd05g00002 into a_empresas[l_aux].ciaempcod
      let l_aux = l_aux + 1
  end foreach
  whenever error stop
  
  let l_total = l_aux - 1

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa para o veiculo."
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd05g00002 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  else
     let l_retorno = 1
     if l_total > 15 then
        let l_mensagem = "Foram encontrados mais de 15 empresas. AVISE A INFORMATICA!"
     else
        let l_mensagem = null
     end if   
  end if

  close cctd05g00002
  
  if param.tp_retorno = 1 then
     #retorna a qtde e o array com as empresas do prestador
     return l_retorno,
            l_mensagem,
            l_total,
            a_empresas[1].ciaempcod,
            a_empresas[2].ciaempcod,
            a_empresas[3].ciaempcod,
            a_empresas[4].ciaempcod,
            a_empresas[5].ciaempcod,
            a_empresas[6].ciaempcod,
            a_empresas[7].ciaempcod,
            a_empresas[8].ciaempcod,
            a_empresas[9].ciaempcod,
            a_empresas[10].ciaempcod,
            a_empresas[11].ciaempcod,
            a_empresas[12].ciaempcod,
            a_empresas[13].ciaempcod,
            a_empresas[14].ciaempcod,
            a_empresas[15].ciaempcod
   else
     if param.tp_retorno = 2 then
        #retorna a qtde de empresas para o prestador
        return l_retorno,
               l_mensagem,
               l_total
     end if
   end if   

end function

#Objetivo: exclui todos os registros de um prestador
#-----------------------------------------#
function ctd05g00_delete_datrvclemp(param)
#-----------------------------------------#
  define param record
         socvclcod    like datrvclemp.socvclcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null

  if m_prep is null or m_prep <> true then
     call ctd05g00_prep()
  end if
  
  whenever error continue
  execute pctd05g00003 using param.socvclcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro DELETE pctd05g00003 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  return l_retorno,
         l_mensagem  
  
end function

#Objetivo: incluir registros
#-----------------------------------------#
function ctd05g00_insert_datrvclemp(param)
#-----------------------------------------#
  define param record
         socvclcod   like datrvclemp.socvclcod,
         ciaempcod   like datrvclemp.ciaempcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null
  
  if m_prep is null or m_prep <> true then
     call ctd05g00_prep()
  end if

  whenever error continue
  execute pctd05g00004 using param.socvclcod,
                             param.ciaempcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro INSERT pctd05g00004 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  return l_retorno,
         l_mensagem  
         
end function
