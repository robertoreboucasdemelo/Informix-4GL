#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: cts54g00                                                        #
# Objetivo.: Identificar informacoes para tributacao na interface de emissao #
#            OP People (tipo fornecedor, cod. brasileiro ocupacao, cod. de   #
#            retencao, OP tributavel)                                        #
# Analista.: Fabio Costa                                                     #
# PSI      : 198404                                                          #
# Liberacao: 30/06/2009                                                      #
#............................................................................#
# Alteracoes                                                                 #
# 06/09/2009 Fabio Costa PSI 198404 Permitir retencao "reembolso" para carro #
# 02/03/2010 Fabio Costa PSI 198404 Permitir empresa variavel na chamada a   #
#                                   funcao de tributos                       #
#----------------------------------------------------------------------------#
database porto

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

#----------------------------------------------------------------
function cts54g00_inftrb(l_param)
#----------------------------------------------------------------

  define l_param record
         empcod        like dbsmopg.empcod    ,
         pstcoddig     like dbsmopg.pstcoddig ,
         soctip        like dbsmopg.soctip    ,
         segnumdig     like dbsmopg.segnumdig ,
         corsus        like dbsmopg.corsus    ,
         pestip        like dbsmopg.pestip    ,
         prscootipcod  like dpaksocor.prscootipcod,
         pcpatvcod     like dpaksocor.pcpatvcod
  end record
  
  define l_retorno record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)
  end record
  
  define l_retendes  char(50)
  
  initialize l_retorno.*, l_retendes to null
  
  let l_retorno.errcod = 0
  
  # valida parametros de entrada
  let l_param.pestip = upshift(l_param.pestip)
  
  if l_param.pestip is null or
     l_param.soctip is null or
     l_param.empcod is null
     then
     let l_retorno.errcod = 999
     let l_retorno.errdes = 'Parametro de entrada incorreto: ',
                            'pes = ', l_param.pestip ,
                            '|soc = ', l_param.soctip,
                            '|emp = ', l_param.empcod
     return l_retorno.*, l_retendes
  end if
  
  # excecao onde nao e possivel ID
  if l_param.pstcoddig is null and 
     l_param.corsus    is null and
     l_param.segnumdig is null and
     l_param.soctip != 2
     then
     let l_retorno.errcod = 999
     let l_retorno.errdes = 'OP nao carro extra sem PST/SEG/SUS nao e possivel ID cod retencao'
     return l_retorno.*, l_retendes
  end if
  
  # cooperativa
  if l_param.prscootipcod is not null and
     l_param.prscootipcod = 1
     then
     let l_retorno.tpfornec = '004'
  end if
  
  # carro extra, pcpatvcod nao cadastrado
  if l_param.soctip = 2
     then
     let l_retendes = 'ALUGUEL P', l_param.pestip clipped
  end if
  
  # reembolso ao segurado, pcpatvcod nao cadastrado
  if l_param.segnumdig is not null and
     l_param.segnumdig > 0
     then
     let l_retorno.tpfornec = '019'
     let l_retendes = 'REEMBOLSO P', l_param.pestip clipped
  end if
  
  if l_retendes is null
     then
     initialize m_dominio.* to null
     
     call cty11g00_iddkdominio('pcpatvcod', l_param.pcpatvcod)
          returning m_dominio.*
          
     if m_dominio.erro = 1
        then
        let l_retendes = m_dominio.cpodes clipped, ' P', l_param.pestip clipped
     else
        let l_retorno.errcod = 999
        let l_retorno.errdes = 'Atividade principal nao localizada'
        return l_retorno.*, l_retendes
     end if
  end if
  
  # define tipo fornecedor People
  if upshift(l_retendes[1,3]) = 'GUI'
     then
     let l_retorno.tpfornec = '010'
  else
     if upshift(l_retendes[1,3]) = 'TAX'
        then
        let l_retorno.tpfornec = '020'
     else
        if upshift(l_retendes[1,3]) = 'REEMB'
           then
           let l_retorno.tpfornec = '019'
        end if
     end if
  end if
  
  # codigos genericos para prestadores
  if l_retorno.tpfornec is null
     then
     let l_retorno.tpfornec = '017'
  end if
  
  call cts54g00_retencao(l_param.empcod, l_param.pestip, l_retendes)
       returning l_retorno.errcod   ,
                 l_retorno.errdes   ,
                 l_retorno.retencod ,
                 l_retorno.socitmtrbflg
  
  return l_retorno.*, l_retendes
  
end function

#----------------------------------------------------------------
function cts54g00_retencao(l_param)
#----------------------------------------------------------------

  define l_param record
         empcod    like dbsmopg.empcod,
         pestip    like dbsmopg.pestip,
         retendes  char(50)
  end record
  
  define l_ffpgc343_ret record
         ppsretcod  like fpgkplprtcinf.ppsretcod,
         errcod     smallint,
         errdes     char(060)
  end record
  
  define l_retorno record
         errcod        smallint ,
         errdes        char(80) ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)
  end record
  
  initialize l_ffpgc343_ret.* to null
  initialize l_retorno.* to null
  let l_retorno.errcod = 0
  
  # busca codigo de retencao e flag tributa S/N no financeiro
  if l_param.retendes is not null
     then
     call ffpgc343(l_param.empcod, 11, l_param.pestip, l_param.retendes)
          returning l_ffpgc343_ret.*
     
     if l_ffpgc343_ret.errcod = 0  # se cadastrado e' tributavel
        then
        let l_retorno.socitmtrbflg = 'S'
        let l_retorno.retencod = l_ffpgc343_ret.ppsretcod
     else
        if l_ffpgc343_ret.errcod = 100  # se nao cadastrado nao tributavel
           then
           let l_retorno.socitmtrbflg = 'N'
           let l_retorno.retencod = 0
        else
           let l_retorno.errcod = 999
           let l_retorno.errdes = l_param.retendes clipped, 
                                  '| Erro selecao COD RETENCAO: ',
                                  l_ffpgc343_ret.errcod using "<<<<<", " ",
                                  l_ffpgc343_ret.errdes[1,35]
           return l_retorno.*
        end if
     end if
  end if
  
  # null no cadastro do cod retencao, considera sem retencao
  if l_retorno.socitmtrbflg is null
     then
     let l_retorno.retencod = 0
     let l_retorno.socitmtrbflg = 'N'
  end if
  
  return l_retorno.*
  
end function

{ Definir por regra, nao sera mais utilizado
#----------------------------------------------------------------
function cts54g00_define_por_regra()
#----------------------------------------------------------------

  define l_assist record
         pstcoddig  like dbsmopg.pstcoddig    ,
         asitipcod  like datrassprs.asitipcod ,
         pstsrvtip  like dpatserv.pstsrvtip
  end record
  
  define l_aux record
         retendes  char(50) ,
         tippst    smallint
  end record
  
  define l_retorno record
         errcod        smallint ,
         errdes        char(80) ,
         tpfornec      char(3)  ,
         retencod      like fpgkplprtcinf.ppsretcod ,
         socitmtrbflg  char(1)
  end record
  
  define l_sql char(400)
  
  whenever error continue
  
  let l_sql = " select pstcoddig ",
              " from datrassprs ",
              " where pstcoddig = ? ",
              "   and asitipcod in ( 01, 02, 03, 08, 14, 15, 16, 25, ",
              "                      37, 38, 39, 42, 43, 54, 58, ",
              "                      60, 61, 63, 64, 65 ) "
  prepare p_ass_guincho_sel from l_sql
  declare c_ass_guincho_sel cursor for p_ass_guincho_sel
  
  let l_sql = " select pstcoddig "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in ( 04, 09, 22, 40, 41, 50, 53 ) "
  prepare p_ass_chaveiro_sel from l_sql
  declare c_ass_chaveiro_sel cursor for p_ass_chaveiro_sel
  
  let l_sql = " select pstcoddig "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in (05, 49) "
  prepare p_ass_taxi_sel from l_sql
  declare c_ass_taxi_sel cursor for p_ass_taxi_sel
  
  let l_sql = " select pstcoddig "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in ( 06, 17, 18, 20, 23, 24, 27, "
            , "                      31, 32, 33, 34, 35, 36, "
            , "                      44, 46, 47, 48, 52, 55 )"
  prepare p_ass_re_sel from l_sql
  declare c_ass_re_sel cursor for p_ass_re_sel
  
  let l_sql = " select pstcoddig "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in (56, 62) "
  prepare p_ass_hd_sel from l_sql
  declare c_ass_hd_sel cursor for p_ass_hd_sel
  
  let l_sql = " select pstcoddig "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in (19, 29, 45, 21, 51) "
  prepare p_ass_limp_sel from l_sql
  declare c_ass_limp_sel cursor for p_ass_limp_sel
  
  let l_sql = " select asitipcod "
            , " from datrassprs "
            , " where pstcoddig = ? "
            , "   and asitipcod in (10, 11, 12, 13, 28, 29, 57, 59) "
  prepare p_assist_sel from l_sql
  declare c_assist_sel cursor for p_assist_sel
  
  let l_sql = " select pstcoddig "
            , " from dpatserv "
            , " where pstcoddig = ? "
            , "   and pstsrvtip in (29, 77) "
  prepare p_srv_hd_sel from l_sql
  declare c_srv_hd_sel cursor for p_srv_hd_sel
  
  let l_sql = " select pstcoddig, pstsrvtip "
            , " from dpatserv "
            , " where pstcoddig = ? "
  prepare p_dpatserv_sel from l_sql
  declare c_dpatserv_sel cursor for p_dpatserv_sel
  
  whenever error stop
  
  initialize l_assist.*, l_retorno.* to null
  
  #----------------------------------------------------------------
  # OP origens AUTO: id tipo fornecedor pela assistencia ou pelo tipo de servico
  if l_aux.tippst = 0 and l_param.soctip = 1
     then
     
     whenever error continue
     open c_ass_guincho_sel using l_param.pstcoddig
     fetch c_ass_guincho_sel into l_assist.pstcoddig
     whenever error stop
     
     if sqlca.sqlcode = 0  # Guincho
        then
        let l_aux.tippst = 1
     else
        whenever error continue
        open c_ass_chaveiro_sel using l_param.pstcoddig
        fetch c_ass_chaveiro_sel into l_assist.pstcoddig
        whenever error stop
        
        if sqlca.sqlcode = 0  # Chaveiro
           then
           let l_aux.tippst = 2
        else
           whenever error continue
           open c_ass_taxi_sel using l_param.pstcoddig
           fetch c_ass_taxi_sel into l_assist.pstcoddig
           whenever error stop
           
           if sqlca.sqlcode = 0  # Taxi
              then
              let l_aux.tippst = 3
           end if
        end if
     end if
     
     if l_aux.tippst = 0
        then
        whenever error continue
        open c_assist_sel using l_param.pstcoddig
        fetch c_assist_sel into l_assist.asitipcod
        whenever error stop
        
        -- display "Entrou ver assist"
        if sqlca.sqlcode = 0
           then
           if l_assist.asitipcod = 57     # Assist funeral
              then
              let l_aux.tippst = 4
           end if
           
           if l_assist.asitipcod = 59     # Despachante
              then
              let l_aux.tippst = 12
           end if
           
           if l_assist.asitipcod = 11 or  # Remocao
              l_assist.asitipcod = 12
              then
              let l_aux.tippst = 6
           end if
           
           if l_assist.asitipcod = 10 or  # Hospedagem
              l_assist.asitipcod = 13
              then
              let l_aux.tippst = 13
           end if
           
           if l_assist.asitipcod = 28 or  # Vigilancia
              l_assist.asitipcod = 29
              then
              let l_aux.tippst = 14
           end if
        end if
     end if
     
     if l_aux.tippst = 0
        then
        -- display "Entrou ver por servico AUTO"
        whenever error continue
        open c_dpatserv_sel using l_param.pstcoddig
        fetch c_dpatserv_sel into l_assist.pstcoddig, l_assist.pstsrvtip
        whenever error stop
        
        if sqlca.sqlcode = 0
           then
           if l_assist.pstsrvtip != 05 or  # Guincho
              l_assist.pstsrvtip != 16 or
              l_assist.pstsrvtip != 33
              then
              let l_aux.tippst = 1
           end if
           
           if l_assist.pstsrvtip = 16 or  # Taxi
              l_assist.pstsrvtip = 33
              then
              let l_aux.tippst = 3
           end if
           
           if l_assist.pstsrvtip = 05  # Chaveiro
              then
              let l_aux.tippst = 2
           end if
           
        end if
     end if
  end if
  
  #----------------------------------------------------------------
  # OP RE: id tipo fornecedor pela assistencia ou pelo tipo de servico
  if l_aux.tippst = 0 and l_param.soctip = 3
     then
     
     # RE linha branca/basica
     whenever error continue
     open c_ass_re_sel using l_param.pstcoddig
     fetch c_ass_re_sel into l_assist.pstcoddig
     whenever error stop
     
     if sqlca.sqlcode = 0  # RE
        then
        let l_aux.tippst = 8
     end if
     
     # Limp/Manut imoveis
     if l_aux.tippst = 0
        then
        whenever error continue
        open c_ass_limp_sel using l_param.pstcoddig
        fetch c_ass_limp_sel into l_assist.pstcoddig
        whenever error stop
        if sqlca.sqlcode = 0
           then
           let l_aux.tippst = 11
        end if
     end if
     
     # Help desk
     if l_aux.tippst = 0
        then
        whenever error continue
        open c_ass_hd_sel using l_param.pstcoddig
        fetch c_ass_hd_sel into l_assist.pstcoddig
        whenever error stop
        
        if sqlca.sqlcode = 0
           then
           let l_aux.tippst = 7
        else
           whenever error continue
           open c_srv_hd_sel using l_param.pstcoddig
           fetch c_srv_hd_sel into l_assist.pstcoddig
           whenever error stop
           
           if sqlca.sqlcode = 0
              then
              let l_aux.tippst = 7
           end if
        end if
     end if
     
  end if
  
  # se ainda nao achou tenta pelo tipo da OP
  if l_aux.tippst = 0
     then
     if l_param.soctip = 1  # AUTO 
        then
        let l_aux.tippst = 1  # Guincho
        display "Entrou guincho por exclusao"
     else
        if l_param.soctip = 3  # RE
           then
           let l_aux.tippst = 8  # RE
        end if
     end if
  end if
  
  if l_aux.tippst = 0
     then
     let l_retorno.errcod = 999
     let l_retorno.errdes = 'Erro na selecao da atividade: ', 
                            sqlca.sqlcode using "<<<<<<"
     return l_retorno.*, l_aux.retendes
  end if
  
  #----------------------------------------------------------------
  # define parametros conforme tipo da atividade
  case l_aux.tippst
  
     when 1  # Guincho
        let l_aux.retendes = 'GUINCHEIRO P', l_param.pestip clipped
        
     when 2  # Chaveiro
        let l_aux.retendes = 'CHAVEIRO P', l_param.pestip clipped
        
     when 3  # Taxi
        let l_aux.retendes = 'TAXISTA P', l_param.pestip clipped
        
     when 4  # Assist funeral
        let l_aux.retendes = 'ASSISTENCIA FUNERAL P', l_param.pestip clipped
        
     when 6  # Remocao
        let l_aux.retendes = 'REMOCAO PACIENTE CORPOS P', l_param.pestip clipped
        
     when 5  # Carro Extra
        let l_aux.retendes = 'ALUGUEL P', l_param.pestip clipped
        
     when 7  # Help desk
        let l_aux.retendes = 'HELP DESK P', l_param.pestip clipped
        
     when 8  # R.E.
        let l_aux.retendes = 'MANUTENCAO MAQ APAR EQUIP P', l_param.pestip clipped   
        
     when 9  # Cooperativa
        let l_aux.retendes = 'COOPERATIVA TRANSPORTE'
     
     when 10 # Reembolso ao segurado
        let l_aux.retendes = 'REEMBOLSO P', l_param.pestip clipped
     
     when 11 # Limpeza manutencao imoveis
        let l_aux.retendes = 'LIMPEZA MANUTENCAO IMOVEIS P', l_param.pestip clipped
        
     when 12 # Despachante
        let l_aux.retendes = 'DESPACHANTE P', l_param.pestip clipped
        
     when 13 # Hospedagem
        let l_aux.retendes = 'HOSPEDAGEM P', l_param.pestip clipped
        
     when 14 # Vigilancia
        let l_aux.retendes = 'VIGILANCIA SEGURANCA P', l_param.pestip clipped
        
     when 15 # Pet shop
        let l_aux.retendes = 'MEDICINA VETERINARIA P', l_param.pestip clipped
        
  end case
  
  call cts54g00_retencao(l_param.pestip, l_aux.retendes) returning 
  
  return l_retorno.*, l_aux.retendes
  
end function
}
