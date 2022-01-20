#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTD03G01                                                   #
# ANALISTA RESP..: Sergio Burini                                              #
# PSI/OSF........: PSI-2012-31349/EV                                          #
#   OFERTAR LOJAS DE CARRO EXTRA DE ACORDO COM A EMPRESA DA RESERVA           #
# ........................................................................... #
# DESENVOLVIMENTO: Sergio Burini                                              #
# LIBERACAO......: 16/11/2012                                                 #
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
function ctd03g01_prep()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select ciaempcod, aviestcod ",
                " from datrlcdljaemprlc ",
               " where ciaempcod = ? ",
               "   and aviestcod = ? ",
               "   and lcvcod    = ? "
  prepare pctd03g01001 from l_sql
  declare cctd03g01001 cursor for pctd03g01001
  
  let l_sql = "select ciaempcod ",
              " from datrlcdljaemprlc ",
              " where aviestcod = ? ",
              "   and lcvcod    = ? ",
              " order by ciaempcod "
  prepare pctd03g01002 from l_sql
  declare cctd03g01002 cursor for pctd03g01002            
  
  let l_sql = "delete from datrlcdljaemprlc ",
              " where aviestcod = ? ",
              "   and lcvcod    = ? "
  prepare pctd03g01003 from l_sql
  
  let l_sql = "insert into datrlcdljaemprlc ",
              " (aviestcod, lcvcod, ciaempcod) ",
              " values (?,?,?) "
  prepare pctd03g01004 from l_sql

  let m_prep = true

end function

#Objetivo: validar a empresa e o prestador na tabela
#-----------------------------------------#
function ctd03g01_valida_emploj(param)
#-----------------------------------------#
  define param record
         ciaempcod like datrlcdljaemprlc.ciaempcod,
         lcvcod    like datrlcdljaemprlc.lcvcod,
         aviestcod like datrlcdljaemprlc.aviestcod
  end record

  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100) 

  if m_prep is null or m_prep <> true then
     call ctd03g01_prep()
  end if

  ### INICIALIZACAO DAS VARIAVEIS
  let l_retorno = 0
  let l_mensagem = null

  open cctd03g01001 using param.ciaempcod, param.aviestcod, param.lcvcod 

  whenever error continue
  fetch cctd03g01001 into param.ciaempcod, param.aviestcod 
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_retorno = 2
        let l_mensagem  = "Nao encontrou empresa/prestador relacionados"
     else
        let l_retorno = 3
        let l_mensagem = "Erro SELECT cctd03g01001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  close cctd03g01001

  return l_retorno, l_mensagem

end function

#Objetivo: Buscar todas as empresas cadastradas para o prestador
#-----------------------------------------#
function ctd03g01_empresas(param)
#-----------------------------------------#
  define param record
         tp_retorno  smallint,
         aviestcod   like datrlcdljaemprlc.aviestcod,
         lcvcod      like datrlcdljaemprlc.lcvcod
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
     call ctd03g01_prep()
  end if
  
  open cctd03g01002 using param.aviestcod, param.lcvcod 

  whenever error continue
  foreach cctd03g01002 into a_empresas[l_aux].ciaempcod
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
        let l_mensagem = "Erro SELECT cctd03g01002 / ",
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

  close cctd03g01002
  
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
#-----------------------------------------------#
function ctd03g01_delete_datrlcdljaemprlc(param)
#-----------------------------------------------#
  define param record
         aviestcod   like datrlcdljaemprlc.aviestcod,
         lcvcod      like datrlcdljaemprlc.lcvcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null

  if m_prep is null or m_prep <> true then
     call ctd03g01_prep()
  end if
  
  whenever error continue
  execute pctd03g01003 using param.aviestcod, param.lcvcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro DELETE pctd03g01003 / ",
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
#-----------------------------------------------#
function ctd03g01_insert_datrlcdljaemprlc(param)
#-----------------------------------------------#
  define param record
         aviestcod   like datrlcdljaemprlc.aviestcod,
         ciaempcod   like datrlcdljaemprlc.ciaempcod,
         lcvcod      like datrlcdljaemprlc.lcvcod
  end record
  
  define l_retorno  smallint  # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
  define l_mensagem char(100)   
  
  let l_retorno = 0
  let l_mensagem = null
  
  if m_prep is null or m_prep <> true then
     call ctd03g01_prep()
  end if

  whenever error continue
  execute pctd03g01004 using param.aviestcod,
                             param.lcvcod,
                             param.ciaempcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_retorno = 3
     let l_mensagem = "Erro INSERT pctd03g01004 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
  else
     let l_retorno = 1
     let l_mensagem = null
  end if

  return l_retorno,
         l_mensagem  
end function

  
  
  
  
  
  
  