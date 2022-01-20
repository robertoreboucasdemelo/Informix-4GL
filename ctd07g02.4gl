#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd07g02                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........:                                                            #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datrservapol         #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 15/01/2007                                                 #
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
function ctd07g02_prep()
#-------------------------#

  define l_sql char(200)

  let l_sql = " select succod, ramcod, aplnumdig, ",
              "  itmnumdig, edsnumref ",
              " from datrservapol ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare pctd07g02001 from l_sql
  declare cctd07g02001 cursor for pctd07g02001
  
end function    

#Objetivo: Buscar a apólice correspondente ao servico
#-----------------------------------------#
function ctd07g02_busca_apolice_servico(param)
#-----------------------------------------#
    define param record
        tp_retorno smallint,
        atdsrvnum  like datrservapol.atdsrvnum,
        atdsrvano  like datrservapol.atdsrvano
    end record
    
    define l_retorno    smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
           l_mensagem   char(50)
           
    define l_succod    like datrservapol.succod   ,
           l_ramcod    like datrservapol.ramcod   ,
           l_aplnumdig like datrservapol.aplnumdig,
           l_itmnumdig like datrservapol.itmnumdig,
           l_edsnumref like datrservapol.edsnumref     
           
    let l_retorno   = 0
    let l_mensagem  = null       
    let l_succod    = null
    let l_ramcod    = null
    let l_aplnumdig = null
    let l_itmnumdig = null
    let l_edsnumref = null

    if m_prep is null or m_prep <> true then              
       call ctd07g02_prep()                 
    end if 
    
    open cctd07g02001 using param.atdsrvnum,
                            param.atdsrvano
    fetch cctd07g02001 into l_succod   ,
                            l_ramcod   ,
                            l_aplnumdig,
                            l_itmnumdig,
                            l_edsnumref
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let l_retorno = 2
          let l_mensagem = "Não encontrado apolice para o servico. "
       else
          let l_retorno = 3
          let l_mensagem = "ERRO, ", sqlca.sqlcode, " em ctd07g02_busca_apolice_servico."      
       end if
    else
       let l_retorno = 1
       let l_mensagem = null   
    end if                       
        
    case param.tp_retorno     
       when 1
          return l_retorno,
                 l_mensagem,
                 l_succod,
                 l_ramcod,
                 l_aplnumdig,
                 l_itmnumdig,
                 l_edsnumref
       
       when 2
          return l_retorno,
                 l_mensagem,
                 l_succod,
                 l_ramcod,
                 l_aplnumdig,
                 l_itmnumdig   
       
       otherwise
          return l_retorno,
                 l_mensagem      
       
    end case    
end function