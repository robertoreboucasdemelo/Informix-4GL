#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd03g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 205206                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DPARPSTEMP           #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 17/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 22/11/2006 Priscila        PSI 205206 inclusao funções                      #
#-----------------------------------------------------------------------------#

database porto

  define m_prep    smallint

#-------------------------#
function ctd03g00_prep()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select ciaempcod, pstcoddig ",
                " from dparpstemp ",
               " where ciaempcod = ? ",
               "   and pstcoddig = ? "
  prepare pctd03g00001 from l_sql
  declare cctd03g00001 cursor for pctd03g00001
  
  let l_sql = "select ciaempcod ",
              " from dparpstemp ",
              " where pstcoddig = ? ",
              " order by ciaempcod "
  prepare pctd03g00002 from l_sql
  declare cctd03g00002 cursor for pctd03g00002            
  
  let l_sql = "delete from dparpstemp ",
              " where pstcoddig = ? "
  prepare pctd03g00003 from l_sql
  
  let l_sql = "insert into dparpstemp ",
              " (pstcoddig, ciaempcod) ",
              " values (?,?) "
  prepare pctd03g00004 from l_sql

  let m_prep = true

end function

#Objetivo: validar a empresa e o prestador na tabela
#-----------------------------------------#
function ctd03g00_valida_emppst(param)
#-----------------------------------------#
  define param record
         ciaempcod like dparpstemp.ciaempcod,
         pstcoddig like dparpstemp.pstcoddig
  end record

  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 

  if m_prep is null or m_prep <> true then
     call ctd03g00_prep()
  end if

  ### INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null

  open cctd03g00001 using param.ciaempcod, param.pstcoddig

  whenever error continue
  fetch cctd03g00001 into param.ciaempcod, param.pstcoddig 
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa/prestador relacionados"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd03g00001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  close cctd03g00001

  return l_retorno, l_mensagem

end function

#Objetivo: Buscar todas as empresas cadastradas para o prestador
#-----------------------------------------#
function ctd03g00_empresas(param)
#-----------------------------------------#
  define param record
         tp_retorno  smallint,
         pstcoddig   like dparpstemp.pstcoddig
  end record
  
  define a_empresas array[15] of record
         ciaempcod like dparpstemp.ciaempcod
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
     call ctd03g00_prep()
  end if
  
  open cctd03g00002 using param.pstcoddig

  whenever error continue
  foreach cctd03g00002 into a_empresas[l_aux].ciaempcod
      let l_aux = l_aux + 1
  end foreach
  whenever error stop
  
  let l_total = l_aux - 1

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa para o prestador"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd03g00002 / ",
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

  close cctd03g00002
  
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
function ctd03g00_delete_dparpstemp(param)
#-----------------------------------------#
  define param record
         pstcoddig   like dparpstemp.pstcoddig
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null

  if m_prep is null or m_prep <> true then
     call ctd03g00_prep()
  end if
  
  whenever error continue
  execute pctd03g00003 using param.pstcoddig
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro DELETE pctd03g00003 / ",
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
function ctd03g00_insert_dparpstemp(param)
#-----------------------------------------#
  define param record
         pstcoddig   like dparpstemp.pstcoddig,
         ciaempcod   like dparpstemp.ciaempcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null
  
  if m_prep is null or m_prep <> true then
     call ctd03g00_prep()
  end if

  whenever error continue
  execute pctd03g00004 using param.pstcoddig,
                             param.ciaempcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro INSERT pctd03g00004 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  return l_retorno,
         l_mensagem  
end function
