#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema        : Porto Socorro                                               #
# Modulo         : ctx25g00                                                    #
#                  Interface Java-4GL para coordenadas                         #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 196541 - Modulo de interface Java-4GL para coordenadas      #
#------------------------------------------------------------------------------#
#                         * * *  ALTERACOES  * * *                             #
# Data       Analista Resp/Autor Fabrica PSI/Alteracao                         #
#------------------------------------------------------------------------------#
#23/04/2010  Geraldo Souza               Remocao de mensagem indevida XML Retor#
#                                        no                                    #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/dssqa/producao/I4GLParams.4gl"

define mr_request_id record
    uf              like datkmpacid.ufdcod,
    cidade          like datkmpacid.cidnom,
    tipo            like datkmpalgd.lgdtip,
    logradouro      like datkmpalgd.lgdnom,
    numero          like datkmpalgdsgm.mpalgdincnum,
    bairro          like datkmpabrr.brrnom,
    cep             like datkmpalgdsgm.cepcod,
    codigo          like datkmpalgdsgm.mpalgdcod,
    fonetica1       like datkmpalgd.prifoncod,
    fonetica2       like datkmpalgd.segfoncod,
    fonetica3       like datkmpalgd.terfoncod
end record

define ma_response_id array[100] of record
    tipoend         char(50),
    uf              like datkmpacid.ufdcod,
    cidade          like datkmpacid.cidnom,
    tipo            like datkmpalgd.lgdtip,
    logradouro      like datkmpalgd.lgdnom,
    numero          like datkmpalgdsgm.mpalgdincnum,
    bairro          like datkmpabrr.brrnom,
    cep             like datkmpalgdsgm.cepcod,
    codigo          like datkmpalgdsgm.mpalgdcod
end record

define mr_request_geo record
    tipoend         char(50),
    uf              like datkmpacid.ufdcod,
    cidade          like datkmpacid.cidnom,
    tipo            like datkmpalgd.lgdtip,
    logradouro      like datkmpalgd.lgdnom,
    numero          like datkmpalgdsgm.mpalgdincnum,
    bairro          like datkmpabrr.brrnom,
    cep             like datkmpalgdsgm.cepcod,
    codigo          like datkmpalgdsgm.mpalgdcod
end record

define mr_response_geo record
    tipo_geo        char(10),    #-- 'LAM' ou 'WGS84'
    x               like datkmpalgdsgm.lcllgt,
    y               like datkmpalgdsgm.lclltt
end record

define m_mpacidcod  like datkmpacid.mpacidcod   #-- Auxiliar
define m_mpabrrcod  like datkmpabrr.mpabrrcod   #-- Auxiliar
define m_logradouro char(70)                    #-- Auxiliar

define m_retorno    char(32000)
define m_msgerr     char(500)
define m_docHandle  integer
define m_contador   integer

#------------------------------------------------------------
# Funcao Principal: Trata parametros e comanda demais funcoes
#------------------------------------------------------------
function executeService(l_xml)
    
    define l_xml        char(32000)
    define l_temErro    char(100)
    define l_servico    char(100)
    
    for m_contador = 1 to 100
        initialize  ma_response_id[m_contador].* to null
    end for
    
    let m_contador  = 1
    let m_docHandle = 0
    let m_retorno   = null
    let l_temErro   = ""
    
    #---------------------------------
    # Inicializa a operacao de parse
    #---------------------------------
    call figrc011_inicio_parse()
    
    #--------------------------
    # Efetua o parse do request
    #--------------------------
    let m_docHandle = figrc011_parse(l_xml clipped)
    
    let l_servico = figrc011_xpath(m_docHandle,"/REQUEST/SERVICO")
    
    #------------------------------------------
    # Desvia de acordo com o servico solicitado
    #------------------------------------------
    case l_servico
        when "IdentificarEnderecoIfx"
            call ctx25g00_identificar_endereco_ifx()
        when "GeocodificarEnderecoIfx"
            call ctx25g00_geocodificar_endereco_ifx()
        otherwise
            let m_retorno = ctx25g00_erroxml(999,"Servico Invalido")
    end case
    
    call figrc011_fim_parse()
    return m_retorno
    
end function

#----------------------------
# Recupera lista de enderecos
#----------------------------
function ctx25g00_identificar_endereco_ifx()
    
    define l_select         char(1500)
    define l_selcmp         char(1500)
    
    let mr_request_id.uf         = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/UF")
    let mr_request_id.cidade     = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/CIDADE")
    let mr_request_id.tipo       = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/TIPO")
    let mr_request_id.logradouro = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/LOGRADOURO")
    let mr_request_id.numero     = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/NUMERO")
    let mr_request_id.bairro     = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/BAIRRO")
    let mr_request_id.cep        = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/CEP")
    let mr_request_id.codigo     = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/CODIGO")
    let mr_request_id.fonetica1  = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/FONETICA1")
    let mr_request_id.fonetica2  = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/FONETICA2")
    let mr_request_id.fonetica3  = figrc011_xpath(m_docHandle,"/REQUEST/LISTA/ENDERECO/FONETICA3")
    
    #----------------------------------
    # Contador de enderecos encontrados
    #----------------------------------
    let m_contador   = 1
    
    #-------------------
    # Codigos auxiliares
    #-------------------
    let m_mpacidcod  = 0
    let m_mpabrrcod  = 0
    let m_logradouro = ""
    
    #-----------------------------------------------
    # Transforma uf e nome da cidade para maiusculas
    #-----------------------------------------------
    let mr_request_id.uf     = upshift(mr_request_id.uf)
    let mr_request_id.cidade = upshift(mr_request_id.cidade)
    
    #----------------------------
    # Recupera o codigo da cidade
    #----------------------------
    select datkmpacid.mpacidcod
      into m_mpacidcod
      from datkmpacid
     where datkmpacid.ufdcod = mr_request_id.uf
       and datkmpacid.cidnom = mr_request_id.cidade
    
    #----------------------------------------
    # Se nao encontrou a cidade, retorna erro
    #----------------------------------------
    if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
            let m_msgerr = "CODIGO DA CIDADE NAO ENCONTRADO NA BASE DE MAPAS"
        else
            let m_msgerr = "ERRO - SELECT - ", sqlca.sqlcode," - ",sqlca.sqlerrd[2]
        end if
        call ctx25g00_monta_retorno_ident()
        return
    end if
    
    #-------------------------------
    # Se nao enviou endereco nem cep
    #-------------------------------
    if (mr_request_id.logradouro is null or
        mr_request_id.logradouro = "*"   or
        mr_request_id.logradouro = " ")  and
       (mr_request_id.cep is null        or
        mr_request_id.cep <= 0)          then
        
        #--------------------------------------------------
        # Se nao enviou o bairro identifica apenas a cidade
        #--------------------------------------------------
        if mr_request_id.bairro is null or
           mr_request_id.bairro = "*"   or
           mr_request_id.bairro = " "   then
            call ctx25g00_identificar_cidade()
            return
        else
            #---------------------------------------
            # Se enviou o bairro identifica o bairro
            #---------------------------------------
            call ctx25g00_identificar_bairro()
            return
        end if
        
    end if
    
    #-------------------
    # Pesquisa principal
    #-------------------
    let l_select = " select datkmpalgd.lgdtip,    ", #-- Tipo logradouro
                   "        datkmpalgd.lgdnom,    ", #-- Nome logradouro
                   "        datkmpabrr.brrnom,    ", #-- Nome do bairro
                   "        datkmpalgdsgm.cepcod, ", #-- CEP
                   "        datkmpalgd.mpalgdcod  ", #-- Codigo
                   "   from datkmpalgd,           ",
                   "        datkmpalgdsgm,        ",
                   "  outer datkmpabrr            ",
                   "  where datkmpalgd.mpacidcod    = ? ",
                   "    and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod    ",
                   "    and datkmpabrr.mpacidcod    = datkmpalgdsgm.mpacidcod ",
                   "    and datkmpabrr.mpabrrcod    = datkmpalgdsgm.mpabrrcod "
                   
    #----------------------------
    # Verifica se enviou o numero
    #----------------------------
    if mr_request_id.numero is not null and
       mr_request_id.numero  > 0        then
        
        #-- display "-- Pesquisa com numero --"
        
        if mr_request_id.logradouro is not null and
           mr_request_id.logradouro <> "*"      and
           mr_request_id.logradouro <> " "      then
            
            #-------------------------------------
            # Pesquisa logradouro exato COM numero
            #-------------------------------------
            #-- display "-- Pesq log exato com nr --"
            let m_logradouro = '"', mr_request_id.logradouro clipped, '"'
            let m_logradouro = upshift(m_logradouro)
            
            let l_selcmp = l_select clipped, " and datkmpalgd.lgdnom = ",
                                             m_logradouro clipped,
                                             " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                             " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            prepare p_lgd0n from l_selcmp
            declare c_lgd0n cursor for p_lgd0n
            
            open    c_lgd0n using m_mpacidcod,
                                  mr_request_id.numero,
                                  mr_request_id.numero
            foreach c_lgd0n  into ma_response_id[m_contador].tipo,
                                  ma_response_id[m_contador].logradouro,
                                  ma_response_id[m_contador].bairro,
                                  ma_response_id[m_contador].cep,
                                  ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #---------------------------------------
        # Se nao encontrou pelo logradouro exato
        #---------------------------------------
        if m_contador = 1 then
            
            if mr_request_id.fonetica1 is not null and
               mr_request_id.fonetica1 <> "*"      and
               mr_request_id.fonetica1 <> " "      then
                
                #---------------------------------------------
                # Pesquisa primeiro codigo fonetico COM numero
                #---------------------------------------------
                #-- display "-- Pesq pri cod fon com nr --"
                let l_selcmp = l_select clipped, " and datkmpalgd.prifoncod        = ? ",
                                                 " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                                 " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd1n from l_selcmp
                declare c_lgd1n cursor for p_lgd1n
                
                open    c_lgd1n using m_mpacidcod,
                                      mr_request_id.fonetica1,
                                      mr_request_id.numero,
                                      mr_request_id.numero
                foreach c_lgd1n  into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo primeiro codigo fonetico
        #-----------------------------------------------
        if m_contador = 1 then
            
            if mr_request_id.fonetica2 is not null and
               mr_request_id.fonetica2 <> "*"      and
               mr_request_id.fonetica2 <> " "      then
                
                #--------------------------------------------
                # Pesquisa segundo codigo fonetico COM numero
                #--------------------------------------------
                #-- display "-- Pesq seg cod fon com nr --"
                let l_selcmp = l_select clipped, " and datkmpalgd.segfoncod        = ? ",
                                                 " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                                 " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd2n from l_selcmp
                declare c_lgd2n cursor for p_lgd2n
                
                open    c_lgd2n using m_mpacidcod,
                                      mr_request_id.fonetica2,
                                      mr_request_id.numero,
                                      mr_request_id.numero
                foreach c_lgd2n  into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo segundo codigo fonetico
        #-----------------------------------------------
        if m_contador = 1 then
            
            if mr_request_id.fonetica3 is not null and
               mr_request_id.fonetica3 <> "*"      and
               mr_request_id.fonetica3 <> " "      then
                
                #---------------------------------------------
                # Pesquisa terceiro codigo fonetico COM numero
                #---------------------------------------------
                #-- display "-- Pesq ter cod fon com nr --"
                let l_selcmp = l_select clipped, " and datkmpalgd.terfoncod        = ? ",
                                                 " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                                 " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd3n from l_selcmp
                declare c_lgd3n cursor for p_lgd3n
                
                open    c_lgd3n using m_mpacidcod,
                                      mr_request_id.fonetica3,
                                      mr_request_id.numero,
                                      mr_request_id.numero
                foreach c_lgd3n  into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo terceiro codigo fonetico
        #-----------------------------------------------
        if m_contador = 1 then
            
            if mr_request_id.logradouro is not null and
               mr_request_id.logradouro <> "*"      and
               mr_request_id.logradouro <> " "      then
                
                #---------------------------------------
                # Pesquisa logradouro parcial COM numero
                #---------------------------------------
                #-- display "-- Pesq log parcial com nr --"
                let m_logradouro = '"*', mr_request_id.logradouro clipped, '*"'
                let m_logradouro = upshift(m_logradouro)
                
                let l_selcmp = l_select clipped, " and datkmpalgd.lgdnom matches ",
                                                 m_logradouro clipped,
                                                 " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                                 " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd4n from l_selcmp
                declare c_lgd4n cursor for p_lgd4n
                
                open    c_lgd4n using m_mpacidcod,
                                      mr_request_id.numero,
                                      mr_request_id.numero
                foreach c_lgd4n  into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
        #-----------------------------------------
        # Se nao encontrou pelo logradouro parcial
        #-----------------------------------------
        if m_contador = 1 then
            
            #---------------------------------
            # Se enviou o CEP pesquisa por CEP
            #---------------------------------
            if mr_request_id.cep > 0 then
                
                #----------------------------
                # Pesquisa por CEP COM numero
                #----------------------------
                #-- display "-- Pesq cep com nr --"
                let l_selcmp = l_select clipped, " and datkmpalgdsgm.cepcod        = ? ",
                                                 " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                                 " and datkmpalgdsgm.mpalgdfnlnum >= ? ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd5n from l_selcmp
                declare c_lgd5n cursor for p_lgd5n
                
                open    c_lgd5n using m_mpacidcod,
                                      mr_request_id.cep,
                                      mr_request_id.numero,
                                      mr_request_id.numero
                foreach c_lgd5n  into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
    #---------------------------------------------------------------------
    else # Pesquisas SEM numero de logradouro consideram primeiro segmento
    #---------------------------------------------------------------------
        
        #-- display "-- Pesquisa sem numero --"
        
        if mr_request_id.logradouro is not null and
           mr_request_id.logradouro <> "*"      and
           mr_request_id.logradouro <> " "      then
            
            #-------------------------------------
            # Pesquisa logradouro exato SEM numero
            #-------------------------------------
            #-- display "-- Pesq log exato sem nr --"
            let m_logradouro = '"', mr_request_id.logradouro clipped, '"'
            let m_logradouro = upshift(m_logradouro)
            
            let l_selcmp = l_select clipped, " and datkmpalgd.lgdnom = ",
                                             m_logradouro clipped,
                                             " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            
            prepare p_lgd0 from l_selcmp
            declare c_lgd0 cursor for p_lgd0
            
            open    c_lgd0 using m_mpacidcod
            foreach c_lgd0  into ma_response_id[m_contador].tipo,
                                 ma_response_id[m_contador].logradouro,
                                 ma_response_id[m_contador].bairro,
                                 ma_response_id[m_contador].cep,
                                 ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #---------------------------------------
        # Se nao encontrou pelo logradouro exato
        #---------------------------------------
        if m_contador = 1                      and
           mr_request_id.fonetica1 is not null and
           mr_request_id.fonetica1 <> "*"      and
           mr_request_id.fonetica1 <> " "      then
            
            #---------------------------------------------
            # Pesquisa primeiro codigo fonetico SEM numero
            #---------------------------------------------
            #-- display "-- Pesq pri cod fon sem nr --"
            let l_selcmp = l_select clipped, " and datkmpalgd.prifoncod       = ? ",
                                             " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            prepare p_lgd1 from l_selcmp
            declare c_lgd1 cursor for p_lgd1
            
            open    c_lgd1  using m_mpacidcod,
                                  mr_request_id.fonetica1
            foreach c_lgd1   into ma_response_id[m_contador].tipo,
                                  ma_response_id[m_contador].logradouro,
                                  ma_response_id[m_contador].bairro,
                                  ma_response_id[m_contador].cep,
                                  ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo primeiro codigo fonetico
        #-----------------------------------------------
        if m_contador = 1                      and
           mr_request_id.fonetica2 is not null and
           mr_request_id.fonetica2 <> "*"      and
           mr_request_id.fonetica2 <> " "      then
            
            #--------------------------------------------
            # Pesquisa segundo codigo fonetico SEM numero
            #--------------------------------------------
            #-- display "-- Pesq seg cod fon sem nr --"
            let l_selcmp = l_select clipped, " and datkmpalgd.segfoncod       = ? ",
                                             " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            prepare p_lgd2 from l_selcmp
            declare c_lgd2 cursor for p_lgd2
            
            open    c_lgd2  using m_mpacidcod,
                                  mr_request_id.fonetica2
            foreach c_lgd2   into ma_response_id[m_contador].tipo,
                                  ma_response_id[m_contador].logradouro,
                                  ma_response_id[m_contador].bairro,
                                  ma_response_id[m_contador].cep,
                                  ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo segundo codigo fonetico
        #-----------------------------------------------
        if m_contador = 1                      and
           mr_request_id.fonetica3 is not null and
           mr_request_id.fonetica3 <> "*"      and
           mr_request_id.fonetica3 <> " "      then
            
            #---------------------------------------------
            # Pesquisa terceiro codigo fonetico SEM numero
            #---------------------------------------------
            #-- display "-- Pesq ter cod fon sem nr --"
            let l_selcmp = l_select clipped, " and datkmpalgd.terfoncod       = ? ",
                                             " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            prepare p_lgd3 from l_selcmp
            declare c_lgd3 cursor for p_lgd3
            
            open    c_lgd3  using m_mpacidcod,
                                  mr_request_id.fonetica3
            foreach c_lgd3   into ma_response_id[m_contador].tipo,
                                  ma_response_id[m_contador].logradouro,
                                  ma_response_id[m_contador].bairro,
                                  ma_response_id[m_contador].cep,
                                  ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #-----------------------------------------------
        # Se nao encontrou pelo terceiro codigo fonetico
        #-----------------------------------------------
        if m_contador = 1                       and
           mr_request_id.logradouro is not null and
           mr_request_id.logradouro <> "*"      and
           mr_request_id.logradouro <> " "      then
            
            #----------------------------
            # Pesquisa parcial SEM numero
            #----------------------------
            #-- display "-- Pesq log parcial sem nr --"
            let m_logradouro = '"*', mr_request_id.logradouro clipped, '*"'
            let m_logradouro = upshift(m_logradouro)
            
            let l_selcmp = l_select clipped, " and datkmpalgd.lgdnom matches ",
                                             m_logradouro clipped,
                                             " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                             " group by 1,2,3,4,5 ",
                                             " order by 1,2,3,4,5 "
            prepare p_lgd4 from l_selcmp
            declare c_lgd4 cursor for p_lgd4
            
            open    c_lgd4  using m_mpacidcod
            foreach c_lgd4   into ma_response_id[m_contador].tipo,
                                  ma_response_id[m_contador].logradouro,
                                  ma_response_id[m_contador].bairro,
                                  ma_response_id[m_contador].cep,
                                  ma_response_id[m_contador].codigo
                
                #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                
                #-------------------------------
                # Se ocorreu erro de sql retorna
                #-------------------------------
                if ctx25g00_excecao_ident() then
                    return
                end if
                
                #-----------------------------------
                # Se nao encontrou, para de procurar
                #-----------------------------------
                if sqlca.sqlcode = notfound then
                    exit foreach
                end if
                
                #------------------------------
                # Tipo de pesquisa = 'ENDERECO'
                #------------------------------
                let ma_response_id[m_contador].tipoend = "ENDERECO"
                
                #---------------------------------------------
                # Incrementa contador de enderecos encontrados
                #---------------------------------------------
                let m_contador = m_contador + 1
                
                #------------------------------------
                # Limite de 100 enderecos encontrados
                #------------------------------------
                if m_contador > 100 then
                    exit foreach
                end if
                
            end foreach
            
        end if
        
        #-----------------------------------------
        # Se nao encontrou pelo logradouro parcial
        #-----------------------------------------
        if m_contador = 1 then
            
            #-------------------------------------------
            # Se enviou o CEP utiliza a pesquisa por CEP
            #-------------------------------------------
            if mr_request_id.cep > 0 then
                
                #----------------------------
                # Pesquisa por CEP SEM numero
                #----------------------------
                #-- display "-- Pesq cep sem nr --"
                let l_selcmp = l_select clipped, " and datkmpalgdsgm.cepcod       = ? ",
                                                 " and datkmpalgdsgm.mpalgdsgmseq = 1 ",
                                                 " group by 1,2,3,4,5 ",
                                                 " order by 1,2,3,4,5 "
                prepare p_lgd5 from l_selcmp
                declare c_lgd5 cursor for p_lgd5
                
                open    c_lgd5  using m_mpacidcod,
                                      mr_request_id.cep
                foreach c_lgd5   into ma_response_id[m_contador].tipo,
                                      ma_response_id[m_contador].logradouro,
                                      ma_response_id[m_contador].bairro,
                                      ma_response_id[m_contador].cep,
                                      ma_response_id[m_contador].codigo
                    
                    #-- display "Cont: ", m_contador, " Encontrou cod log ", ma_response_id[m_contador].codigo
                    
                    #-------------------------------
                    # Se ocorreu erro de sql retorna
                    #-------------------------------
                    if ctx25g00_excecao_ident() then
                        return
                    end if
                    
                    #-----------------------------------
                    # Se nao encontrou, para de procurar
                    #-----------------------------------
                    if sqlca.sqlcode = notfound then
                        exit foreach
                    end if
                    
                    #------------------------------
                    # Tipo de pesquisa = 'ENDERECO'
                    #------------------------------
                    let ma_response_id[m_contador].tipoend = "ENDERECO"
                    
                    #---------------------------------------------
                    # Incrementa contador de enderecos encontrados
                    #---------------------------------------------
                    let m_contador = m_contador + 1
                    
                    #------------------------------------
                    # Limite de 100 enderecos encontrados
                    #------------------------------------
                    if m_contador > 100 then
                        exit foreach
                    end if
                    
                end foreach
                
            end if
            
        end if
        
    end if
    
    #--------------------------
    # Se nao encontrou endereco
    #--------------------------
    if m_contador = 1 then
        
        #--------------------------------------------------
        # Se nao enviou o bairro identifica apenas a cidade
        #--------------------------------------------------
        if mr_request_id.bairro is null or
           mr_request_id.bairro = "*"   or
           mr_request_id.bairro = " "   then
            call ctx25g00_identificar_cidade()
            return
        else
            #---------------------------------------
            # Se enviou o bairro identifica o bairro
            #---------------------------------------
            call ctx25g00_identificar_bairro()
            return
        end if
        
    end if
    
    let m_msgerr = ""
    call ctx25g00_monta_retorno_ident()
    
end function

#----------------------------------------------------------------------------
# Se nao enviou ou nao encontrou endereco e bairro identifica apenas a cidade
#----------------------------------------------------------------------------
function ctx25g00_identificar_cidade()
    
    #-- display "-- Retorna apenas codigo da cidade --"
    
    let ma_response_id[m_contador].tipoend    = "CIDADE"
    let ma_response_id[m_contador].tipo       = ""
    let ma_response_id[m_contador].logradouro = ""
    let ma_response_id[m_contador].bairro     = ""
    let ma_response_id[m_contador].cep        = 0
    let ma_response_id[m_contador].codigo     = m_mpacidcod
    
    let m_contador = m_contador + 1
    
    let m_msgerr = ""
    call ctx25g00_monta_retorno_ident()
    
end function

#-------------------------------------------------------------------
# Se nao enviou ou nao encontrou endereco identifica apenas o bairro
#-------------------------------------------------------------------
function ctx25g00_identificar_bairro()
    
    define l_select         char(1500)
    define l_selcmp         char(1500)
    
    #--------------------------------
    # Recupera bairro pelo nome exato
    #--------------------------------
    #-- display "-- Pesquisa bairro exato --"
    select datkmpabrr.mpabrrcod
      into m_mpabrrcod
      from datkmpabrr
     where datkmpabrr.mpacidcod = m_mpacidcod
       and datkmpabrr.brrnom    = mr_request_id.bairro
    
    #-------------------------------
    # Se ocorreu erro de sql retorna
    #-------------------------------
    if ctx25g00_excecao_ident() then
        return
    end if
    
    #-----------------------------------------------------
    # Se encontrou pelo nome exato do bairro monta retorno
    #-----------------------------------------------------
    if sqlca.sqlcode <> notfound then
        
        let ma_response_id[m_contador].tipoend    = "BAIRRO"
        let ma_response_id[m_contador].tipo       = ""
        let ma_response_id[m_contador].logradouro = ""
        let ma_response_id[m_contador].cep        = 0
        let ma_response_id[m_contador].codigo     = m_mpabrrcod
        let ma_response_id[m_contador].bairro     = mr_request_id.bairro
        
        let m_contador = m_contador + 1
        
    else
        
        #---------------------------------------------------------
        # Se nao encontrou pelo nome exato do bairro tenta parcial
        #---------------------------------------------------------
        
        let m_logradouro = '"*', mr_request_id.bairro clipped, '*"'
        let m_logradouro = upshift(m_logradouro)
        
        #-- display "-- Pesquisa bairro parcial -- [", m_logradouro clipped, "]"
        
        #----------------------------------
        # Recupera bairro pelo nome parcial
        #----------------------------------
        let l_select = "select datkmpabrr.mpabrrcod,     ",
                       "       datkmpabrr.brrnom         ",
                       "  from datkmpabrr                ",
                       " where datkmpabrr.mpacidcod = ?  ",
                       "   and datkmpabrr.brrnom matches ",
                       m_logradouro clipped
        
        #-- display "l_select = [", l_select clipped, "]"
        
        prepare p_brrparc from l_select
        declare c_brrparc cursor for p_brrparc
        
        open    c_brrparc using m_mpacidcod
        foreach c_brrparc  into ma_response_id[m_contador].codigo,
                                ma_response_id[m_contador].bairro
            
            #-------------------------------
            # Se ocorreu erro de sql retorna
            #-------------------------------
            if ctx25g00_excecao_ident() then
                return
            end if
            
            let ma_response_id[m_contador].tipoend    = "BAIRRO"
            let ma_response_id[m_contador].tipo       = ""
            let ma_response_id[m_contador].logradouro = ""
            let ma_response_id[m_contador].cep        = 0
            
            let m_contador = m_contador + 1
            
        end foreach
        
    end if
    
    #---------------------------------------------------
    # Se nao encontrou bairro identifica apenas a cidade
    #---------------------------------------------------
    if m_contador = 1 then
        call ctx25g00_identificar_cidade()
    else
        let m_msgerr = ""
        call ctx25g00_monta_retorno_ident()
    end if
    
end function

#--------------------------
# Trata excessoes de acesso
#--------------------------
function ctx25g00_excecao_ident()
    
    if sqlca.sqlcode <> 0 and
       sqlca.sqlcode <> notfound then
        let m_msgerr = "ERRO - SELECT - ", sqlca.sqlcode," - ",sqlca.sqlerrd[2]
        call ctx25g00_monta_retorno_ident()
        return true
    end if
    
    return false
    
end function

#-----------------------------
# Monta retorno no formato XML
#-----------------------------
function ctx25g00_monta_retorno_ident()
    
    define l_contador   integer
    
    #-- display "Retorno Cont: ", m_contador
    
    let m_retorno =
        "<?xml version='1.0' encoding='ISO-8859-1'?>",
        "<RESPONSE>",
        "<SERVICO>IdentificarEnderecoIfx</SERVICO>",
        "<LISTA>"
        #---------------------------------------
        # Inicio do for de enderecos encontrados
        #---------------------------------------
        let m_contador = m_contador - 1
        for l_contador = 1 to m_contador
            #---------------------------------------------------------------
            ### let ma_response_id[l_contador].tipoend   = "ENDERECO"
            let ma_response_id[l_contador].uf        = mr_request_id.uf
            let ma_response_id[l_contador].cidade    = mr_request_id.cidade
            let ma_response_id[l_contador].numero    = mr_request_id.numero
            #---------------------------------------------------------------
            let m_retorno = m_retorno clipped,
                "<ENDERECO>",
                "<TIPOEND>",    ma_response_id[l_contador].tipoend clipped,             "</TIPOEND>",
                "<UF>",         ma_response_id[l_contador].uf clipped,                  "</UF>",
                "<CIDADE>",     ma_response_id[l_contador].cidade clipped,              "</CIDADE>",
                "<TIPO>",       ma_response_id[l_contador].tipo clipped,                "</TIPO>",
                "<LOGRADOURO>", ma_response_id[l_contador].logradouro clipped,          "</LOGRADOURO>",
                "<NUMERO>",     ma_response_id[l_contador].numero using "<<<<<<<<<",    "</NUMERO>",
                "<BAIRRO>",     ma_response_id[l_contador].bairro clipped,              "</BAIRRO>",
                "<CEP>",        ma_response_id[l_contador].cep using "&&&&&&&&",        "</CEP>",
                "<CODIGO>",     ma_response_id[l_contador].codigo using "<<<<<<<<<<<<", "</CODIGO>",
                "</ENDERECO>"
        end for
        #--------------------------------------
        # Final do for de enderecos encontrados
        #--------------------------------------
        let m_retorno = m_retorno clipped,
        "</LISTA>",
        "<ERRO>", m_msgerr clipped, "</ERRO>",
        "</RESPONSE>"
        
end function

#---------------------------------
# Recupera coordenadas do endereco
#---------------------------------
function ctx25g00_geocodificar_endereco_ifx()
    
    define l_select     char(1500)
    define l_selcmp     char(1500)
    
    let mr_request_geo.tipoend    = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/TIPOEND")
    let mr_request_geo.uf         = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/UF")
    let mr_request_geo.cidade     = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/CIDADE")
    let mr_request_geo.tipo       = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/TIPO")
    let mr_request_geo.logradouro = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/LOGRADOURO")
    let mr_request_geo.numero     = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/NUMERO")
    let mr_request_geo.bairro     = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/BAIRRO")
    let mr_request_geo.cep        = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/CEP")
    let mr_request_geo.codigo     = figrc011_xpath(m_docHandle,"/REQUEST/ENDERECO/CODIGO")
    
    #--------------------------------------------------------
    # Se enviou apenas a cidade retorna coordenadas da cidade
    #--------------------------------------------------------
    if (mr_request_geo.logradouro is null or
        mr_request_geo.logradouro = "*"   or
        mr_request_geo.logradouro = " ")  and
       (mr_request_geo.cep is null        or
        mr_request_geo.cep <= 0)          and
       (mr_request_geo.bairro is null     or
        mr_request_geo.bairro = "*"       or
        mr_request_geo.bairro = " " )     then
        
        #-------------------------------------------
        # Recupera coordenadas da cidade pelo codigo
        #-------------------------------------------
        select datkmpacid.lcllgt,
               datkmpacid.lclltt
          into mr_response_geo.x,
               mr_response_geo.y
          from datkmpacid
         where datkmpacid.mpacidcod = mr_request_geo.codigo
        
        #-------------------------------
        # Se ocorreu erro de sql retorna
        #-------------------------------
        if ctx25g00_excecao_geo() then
            return
        end if
        
        #------------------------------
        # Retorna coordenadas da cidade
        #------------------------------
        #-- display "-- Retorna apenas coordenadas da cidade --"
        let m_msgerr = ""
        call ctx25g00_monta_retorno_geo()
        return
        
    end if
    
    #--------------------------------------------------------------
    # Se enviou apenas a cidade e o bairro retorna codigo do bairro
    #--------------------------------------------------------------
    if (mr_request_geo.logradouro is null or
        mr_request_geo.logradouro = "*"   or
        mr_request_geo.logradouro = " ")  and
       (mr_request_geo.cep is null        or
        mr_request_geo.cep <= 0)          and
       (mr_request_geo.bairro is not null and
        mr_request_geo.bairro <> "*"      and
        mr_request_geo.bairro <> " " )    then
        
        #-------------------------------------------
        # Recupera coordenadas do bairro pelo codigo
        #-------------------------------------------
        select datkmpabrr.lcllgt,
               datkmpabrr.lclltt
          into mr_response_geo.x,
               mr_response_geo.y
          from datkmpabrr
         where datkmpabrr.mpabrrcod = mr_request_geo.codigo
        
        #-------------------------------
        # Se ocorreu erro de sql retorna
        #-------------------------------
        if ctx25g00_excecao_geo() then
            return
        end if
        
        #------------------------------
        # Retorna coordenadas do bairro
        #------------------------------
        #-- display "-- Retorna apenas coordenadas do bairro --"
        let m_msgerr = ""
        call ctx25g00_monta_retorno_geo()
        return
        
    end if
    
    #-- display "-- Pesquisa coordenadas do endereco --"
    
    #-------------------
    # Pesquisa principal
    #-------------------
    let l_select = " select datkmpalgdsgm.lcllgt,       ", #-- Longitude (eixo x)
                   "        datkmpalgdsgm.lclltt        ", #-- Latitude  (eixo y)
                   "   from datkmpalgdsgm               ",
                   "  where datkmpalgdsgm.mpalgdcod = ? "
    
    #--------------------
    # Pesquisa SEM numero
    #--------------------
    let l_selcmp = l_select clipped, " and datkmpalgdsgm.mpalgdsgmseq = 1 "
    prepare p_geo1 from l_selcmp
    declare c_geo1 cursor for p_geo1
    
    #--------------------
    # Pesquisa COM numero
    #--------------------
    let l_selcmp = l_select clipped, " and datkmpalgdsgm.mpalgdincnum <= ? ",
                                     " and datkmpalgdsgm.mpalgdfnlnum >= ? "
    prepare p_geo1n from l_selcmp
    declare c_geo1n cursor for p_geo1n
    
    #----------------------------
    # Verifica se enviou o numero
    #----------------------------
    if mr_request_geo.numero is not null and
       mr_request_geo.numero  > 0        then
        
        #--------------------
        # Pesquisa COM numero
        #--------------------
        open c_geo1n using mr_request_geo.codigo,
                           mr_request_geo.numero,
                           mr_request_geo.numero
        
        fetch c_geo1n into mr_response_geo.x,
                           mr_response_geo.y
        
        if ctx25g00_excecao_geo() then
            return
        end if
        
    else
        
        #--------------------
        # Pesquisa SEM numero
        #--------------------
        open c_geo1  using mr_request_geo.codigo
        
        fetch c_geo1  into mr_response_geo.x,
                           mr_response_geo.y
        
        if ctx25g00_excecao_geo() then
            return
        end if
        
    end if
    
    let m_msgerr = ""
    call ctx25g00_monta_retorno_geo()
    
end function

#--------------------------
# Trata excessoes de acesso
#--------------------------
function ctx25g00_excecao_geo()
    
    if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
            let m_msgerr = "ERRO - COORDENADAS NAO ENCONTRADAS"
            #call ctx25g00_monta_retorno_geo()
            #return true
        else
            let m_msgerr = "ERRO - SELECT - ", sqlca.sqlcode," - ",sqlca.sqlerrd[2]
            #call ctx25g00_monta_retorno_geo()
            #return true
        end if
        
        call ctx25g00_monta_retorno_geo()
        return true
        
    end if
    
    return false
    
end function

#-----------------------------
# Monta retorno no formato XML
#-----------------------------
function ctx25g00_monta_retorno_geo()
    
    let mr_response_geo.tipo_geo = "WGS84"
    
    let m_retorno =
        "<?xml version='1.0' encoding='ISO-8859-1'?>",
        "<RESPONSE>",
            "<SERVICO>GeocodificarEnderecoIfx</SERVICO>",
            "<POSICAO>",
                "<COORDENADAS>",
                    "<TIPO>", mr_response_geo.tipo_geo clipped, "</TIPO>",
                    "<X>",    mr_response_geo.x,                "</X>",
                    "<Y>",    mr_response_geo.y,                "</Y>",
                "</COORDENADAS>",
            "</POSICAO>",
            "<ERRO>", m_msgerr clipped, "</ERRO>",
        "</RESPONSE>"
        
end function

#--------------------
# Monta erro generico
#--------------------
function ctx25g00_erroxml(l_param)
    
    define l_param record
        codigo      smallint,
        mensagem    char(255)
    end record
    
    define l_xml    char(500)
    
    let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>",
                "<RESPONSE>",
                    "<ERRO>",
                        "<CODIGO>", l_param.codigo using "<<<<<<<<<", "</CODIGO>",
                        "<MENSAGEM>", l_param.mensagem clipped, "</MENSAGEM>",
                    "</ERRO>",
                "</RESPONSE>"
    return l_xml
    
end function

