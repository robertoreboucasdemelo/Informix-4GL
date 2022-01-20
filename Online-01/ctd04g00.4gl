#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd04g00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: 205206                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATRAVSEMP           #
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
function ctd04g00_prep()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select ciaempcod, lcvcod, avivclcod ",
                " from datravsemp ",
               " where ciaempcod = ? ",
               "   and lcvcod = ? ",
               "   and avivclcod = ? "
  prepare pctd04g00001 from l_sql
  declare cctd04g00001 cursor for pctd04g00001
  
  let l_sql = "select ciaempcod ",
              " from datravsemp ",
              " where lcvcod = ? ",
              "   and avivclcod = ?",
              " order by ciaempcod "
  prepare pctd04g00002 from l_sql
  declare cctd04g00002 cursor for pctd04g00002            
  
  let l_sql = "delete from datravsemp ",
              " where lcvcod = ? ",
              "   and avivclcod = ?"
  prepare pctd04g00003 from l_sql
  
  let l_sql = "insert into datravsemp ",
              " (lcvcod, avivclcod, ciaempcod) ",
              " values (?,?,?) "
  prepare pctd04g00004 from l_sql
  
  let l_sql = "select count(avivclcod) ",
              " from datravsemp ",
              " where lcvcod = ? ",
              "   and ciaempcod = ? "
  prepare pctd04g00005 from l_sql
  declare cctd04g00005 cursor for pctd04g00005               

  let m_prep = true

end function

#Objetivo: validar a empresa e a locadora/veiculo na tabela
#-----------------------------------------#
function ctd04g00_valida_emploc(param)
#-----------------------------------------#
  define param record
         ciaempcod like datravsemp.ciaempcod,
         lcvcod    like datravsemp.lcvcod,
         avivclcod like datravsemp.avivclcod 
  end record

  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 

  if m_prep is null or m_prep <> true then
     call ctd04g00_prep()
  end if

  ### INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null

  open cctd04g00001 using param.ciaempcod, 
                          param.lcvcod,
                          param.avivclcod

  whenever error continue
  fetch cctd04g00001 into param.ciaempcod, 
                          param.lcvcod,
                          param.avivclcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa/prestador relacionados"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd04g00001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  close cctd04g00001

  return l_retorno, l_mensagem

end function

#Objetivo: Buscar todas as empresas cadastradas para a locadora/veiculo
#-----------------------------------------#
function ctd04g00_empresas(param)
#-----------------------------------------#
  define param record
         tp_retorno  smallint,
         lcvcod    like datravsemp.lcvcod,
         avivclcod like datravsemp.avivclcod          
  end record
  
  define a_empresas array[15] of record
         ciaempcod like datravsemp.ciaempcod
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
     call ctd04g00_prep()
  end if
  
  open cctd04g00002 using param.lcvcod,
                          param.avivclcod

  whenever error continue
  foreach cctd04g00002 into a_empresas[l_aux].ciaempcod
      let l_aux = l_aux + 1
  end foreach
  whenever error stop
  
  let l_total = l_aux - 1

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa para a locadora/veiculo"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd04g00002 / ",
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

  close cctd04g00002
  
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

#Objetivo: conta quantos veiculos de uma locadora
# estao vinculados a uma empresa
#-----------------------------------------#
function ctd04g00_conta_veicemp(param)
#-----------------------------------------#
  define param record
         lcvcod    like datravsemp.lcvcod,
         ciaempcod like datravsemp.ciaempcod    
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)  
  define l_qtde     smallint
  
  let l_retorno = 0
  let l_mensagem = null
  let l_qtde = 0

  if m_prep is null or m_prep <> true then
     call ctd04g00_prep()
  end if
  
  open cctd04g00005 using param.lcvcod,
                          param.ciaempcod
  fetch cctd04g00005 into l_qtde
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then 
        let l_retorno = 2
        let l_mensagem = "Nao encontrado nenhum veiculo para a locadora/empresa"        
     else
        let l_retorno = 3
        let l_mensagem = "Erro DELETE pctd04g00005 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]        
     end if
  else
     let l_retorno = 1
     let l_mensagem = null
  end if
  
  return l_retorno,
         l_mensagem,
         l_qtde

end function


#Objetivo: exclui todos os registros de um prestador
#-----------------------------------------#
function ctd04g00_delete_datravsemp(param)
#-----------------------------------------#
  define param record
         lcvcod    like datravsemp.lcvcod,
         avivclcod like datravsemp.avivclcod    
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null

  if m_prep is null or m_prep <> true then
     call ctd04g00_prep()
  end if
  
  whenever error continue
  execute pctd04g00003 using param.lcvcod,
                             param.avivclcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro DELETE pctd04g00003 / ",
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
function ctd04g00_insert_datravsemp(param)
#-----------------------------------------#
  define param record
         lcvcod    like datravsemp.lcvcod,
         avivclcod like datravsemp.avivclcod,  
         ciaempcod   like datravsemp.ciaempcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null
  
  if m_prep is null or m_prep <> true then
     call ctd04g00_prep()
  end if

  whenever error continue
  execute pctd04g00004 using param.lcvcod,
                             param.avivclcod,
                             param.ciaempcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro INSERT pctd04g00004 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  return l_retorno,
         l_mensagem  
end function
