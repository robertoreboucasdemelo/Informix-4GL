###############################################################################
# Nome do Modulo: CTS08G06                                           Adriano  #
#                                                                    PSI241407#
# Janela para exibicao do Posicionamento da viatura no Sevico        Mai/2009 #
#-----------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function cts08g06(param)
#-----------------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum, 
    atdsrvano        like datmservico.atdsrvano,
    lclltt_srv       like datmlcl.lclltt,
    lcllgt_srv       like datmlcl.lcllgt,
    ufdcod           like datmlcl.ufdcod,
    socvclcod        like datkveiculo.socvclcod,
    lclltt_msg       like datmmdtmvt.lclltt,
    lcllgt_msg       like datmmdtmvt.lcllgt,
    tmp_msg          interval hour(06) to minute,      
    tipo_msg         smallint
 end record
 
 define d_cts08g06   record
    cabtxt           char (40),
    confirma         char (01),
    linha1           char (40), 
    linha2           char (40), 
    linha3           char (40), 
    linha4           char (40),  
    linha5           char (40),
    linha6           char (40),
    linha7           char (40),
    linha8           char (40),
    linha9           char (40), 
    linha10          char (40) 
 end record    
 
 define d_cts08g06b  record
    cabtxt           char (51),
    confirma         char (01),
    linha1           char (51)
 end record     
 
 define ws           record
    srrcoddig        like dattfrotalocal.srrcoddig,
    srrabvnom        like datksrr.srrabvnom,
    celdddcod_srr    like datksrr.celdddcod, 
    celtelnum_srr    like datksrr.celtelnum,
    celdddcod_vei    like datksrr.celdddcod, 
    celtelnum_vei    like datksrr.celtelnum,
    nxtnum           like datkveiculo.nxtnum, 
    nxtide           like datkveiculo.nxtide,
    mdtmsgtxt        like datmmdtmsgtxt.mdtmsgtxt
 end record
 
 define l_res              smallint,
        l_msg              char(40),
        l_mdtcod           like datkveiculo.mdtcod,
        l_contador         smallint,
        l_roter_ativa      smallint,
        l_distancia        decimal(8,2),
        l_tempo_total      decimal(6,1),
        l_roter_xml_veic   char(32000),
        l_servico          char(20),  
        l_mensagem         char(150),
        l_erroflg          smallint,
        l_temp             char(10)        
        
 let l_res = null
 let l_msg = null
 let l_roter_xml_veic   = null 
 let l_distancia     = null 
 let l_tempo_total   = null
 
 initialize  ws.*  to  null
 
 # BUSCA DADOS DO SOCORRISTA DO VEICULO
 call ctd10g00_dados_frotalocal(2, param.socvclcod)
      returning l_res, l_msg,                  
                ws.srrcoddig
 
 # BUSCA NOME ABREVIADO DO SOCORRISTA               
 select srrabvnom 
 into ws.srrabvnom
 from datksrr
 where srrcoddig = ws.srrcoddig
 
 # BUSCA O CELULAR DO SOCORRISTA
 call cts00m03_cel_socorr(ws.srrcoddig)
            returning ws.celdddcod_srr, ws.celtelnum_srr
 
 # BUSCA O CELULAR DO VEICULO
 call cts00m03_cel_veiculo(param.socvclcod)
         returning ws.celdddcod_vei,
                   ws.celtelnum_vei,
                   l_mdtcod
 
 #BUSCA O ID NEXTEL DO VEÍCULO, DEPOIS DO SOCORRISTA
    call cts00m03_id_nextel(param.socvclcod, ws.srrcoddig)
            returning ws.nxtnum, ws.nxtide
 
 let d_cts08g06.confirma = ""
 if param.tipo_msg <> 1 then
    let l_temp = param.tmp_msg
    let d_cts08g06.cabtxt = 'POSICAO DO PRESTADOR RECEBIDA HA ', l_temp[9,10], 'MIN'
    
    error " Aguarde..."   
                              
    if ctx25g05_rota_ativa() then      # Verifica ambiente de ROTERIZACAO    
       call ctx25g01( param.lclltt_msg      , param.lcllgt_msg, "O")       
            returning d_cts08g06.linha1,         
                      d_cts08g06.linha2,
                      d_cts08g06.linha3,
                      d_cts08g06.linha4
    else                                                                 
       call ctn44c02( param.lclltt_msg      , param.lcllgt_msg)            
            returning d_cts08g06.linha1,
                      d_cts08g06.linha2,
                      d_cts08g06.linha3,
                      d_cts08g06.linha4 
    end if                                                           
    error " "
        
    let d_cts08g06.linha5  = "----------------------------------------"
    let d_cts08g06.linha6  = "  SE NECESSARIO, CONTATE O SOCORRISTA"
    let d_cts08g06.linha7  = "  ", ws.srrabvnom clipped
    let d_cts08g06.linha8 = " "
    let d_cts08g06.linha9  = " TELEFONE(S): (", ws.celdddcod_vei  clipped, ") " 
                                              , ws.celtelnum_vei using '<<<<<<<<<', " / "
                                              , ws.celtelnum_srr using '<<<<<<<<<'      
    let d_cts08g06.linha10 = "      NEXTEL: ", ws.nxtnum using '<<<<<<<<<' , " ID: " , ws.nxtide clipped
                                                  
    let d_cts08g06.linha1 = cts08g06_center(d_cts08g06.linha1, 40)
    let d_cts08g06.linha2 = cts08g06_center(d_cts08g06.linha2, 40)
    let d_cts08g06.linha3 = cts08g06_center(d_cts08g06.linha3, 40)
    let d_cts08g06.linha4 = cts08g06_center(d_cts08g06.linha4, 40)
    
    open window w_cts08g06 at 8,19 with form "cts08g06"               
           attribute(border, form line first, message line last - 1)
    
    display by name d_cts08g06.cabtxt  attribute (reverse)
    display by name d_cts08g06.linha1 thru d_cts08g06.linha10
    
    message " (F17)Abandona   (F8)Dist Prest <-> Srv"
    input by name d_cts08g06.confirma without defaults
       after field confirma
          next field confirma
        on key (F8)
          if (param.lclltt_srv is null or param.lclltt_srv = '') or  # Servico nao indexado
             (param.lcllgt_srv is null or param.lcllgt_srv = '') then
              let d_cts08g06b.cabtxt = 'ATENCAO'
              let d_cts08g06b.linha1 = 'DISTANCIA NAO DISPONIVEL. SERVICO NAO INDEXADO'
              let d_cts08g06b.cabtxt = cts08g06_center(d_cts08g06b.cabtxt, 51)  
              let d_cts08g06b.linha1 = cts08g06_center(d_cts08g06b.linha1, 51)  
          else
              #-------------------------------------
              # VERIFICA SE A ROTERIZACAO ESTA ATIVA
              #-------------------------------------

              error " Aguarde... Roterizando distancia"
              let l_roter_ativa = ctx25g05_rota_ativa()                            
              if param.ufdcod <> "RJ" and
                 param.ufdcod <> "SP" and
                 param.ufdcod <> "PR" then
                 let l_roter_ativa = false
              end if
              if l_roter_ativa then
                 let l_contador = 1
                 # -> MONTA O XML DE REQUEST
                 let l_roter_xml_veic =  '<VEICULOS>',
                                         '<VEICULO>',
                                         '<ID>', l_contador using "<<<<&", '</ID>',
                                            '<COORDENADAS>',
                                               '<TIPO>WGS84</TIPO>',
                                               '<X>',
                                               param.lcllgt_msg,
                                               '</X>',
                                               '<Y>',
                                               param.lclltt_msg,
                                               '</Y>',
                                            '</COORDENADAS>',
                                         '</VEICULO> </VEICULOS>'
                                                                                   
                 call ctx25g06(param.lclltt_srv, param.lcllgt_srv, l_roter_xml_veic)       
                     returning l_contador,                                         
                               l_distancia,                                        
                               l_tempo_total                                       
              else                                                                 
                 call cts18g00(param.lclltt_srv, param.lcllgt_srv,                         
                               param.lclltt_msg, param.lcllgt_msg)               
                      returning l_distancia                                        
              end if  
              let d_cts08g06b.cabtxt = 'CALCULO DE DISTANCIA ENTRE PONTOS'
              
              let d_cts08g06b.linha1 = 'DISTANCIA ENTRE PRESTADOR E O SERVICO: ', l_distancia using '<<<<<<&.&&', ' KM'
              
              let d_cts08g06b.cabtxt = cts08g06_center(d_cts08g06b.cabtxt, 51)             
              let d_cts08g06b.linha1 = cts08g06_center(d_cts08g06b.linha1, 51) 
              error " "        
          end if
          
          open window w_cts08g06b at 11,12 with form "cts08g06b"    
               attribute(border, form line first, message line last - 1)

          display by name d_cts08g06b.cabtxt  attribute (reverse)
          display by name d_cts08g06b.linha1
          message " (F17)Abandona"
          input by name d_cts08g06b.confirma without defaults
             after field confirma                           
                next field confirma                         
          
             on key (interrupt, control-c)
                exit input   
          end input             
          close window w_cts08g06b
          let int_flag = false 
          next field confirma
       on key (interrupt, control-c)
          exit input
    end input
    if param.tipo_msg = 3 or param.tipo_msg = 4 then
       if param.tipo_msg = 3 then
           let ws.mdtmsgtxt = 'SERVICO NO PRAZO -> ', ws.srrabvnom clipped
           ,', o cliente entrou em contato solicitando a sua localizacao. Favor cumprir a previsao.'
           ,' Se nao for possivel, entre em contato com a Central de Operacoes para novo posicionamento.'
       else
           let ws.mdtmsgtxt = 'SERVICO ATRASADO -> ', ws.srrabvnom clipped
           ,', este servico esta atrasado. Entre em contato com a Central de Operacoes para novo posicionamento.'
       end if
       call cts00g02_env_msg_mdt(1, "", "",
                                   ws.mdtmsgtxt,
                                   param.socvclcod)
           returning l_erroflg
       if l_erroflg  =  "S"   then
          let l_servico = param.atdsrvnum, "/", param.atdsrvano
          let l_mensagem = "Erro ao chamar a funcao ",                   
                           " cts00g02_env_msg_mdt() ",                   
                           " Srv: ", l_servico                           
          call errorlog(l_mensagem)                                      
                                                                         
          error "Erro ao chamar a funcao cts00g02_env_msg_mdt() " sleep 4
          error "AVISE A INFORMATICA !!!" sleep 4      
       end if
    end if
 else
    
    let d_cts08g06.cabtxt = "ATENCAO"   
    let d_cts08g06.linha1 = " "
    let d_cts08g06.linha2 = "  POSICAO DO PRESTADOR NAO DISPONIVEL"
    let d_cts08g06.linha3 = " "
    let d_cts08g06.linha4 = "  SE NECESSARIO, CONTATE O SOCORRISTA"
    let d_cts08g06.linha5 = " "
    let d_cts08g06.linha6  = "  ", ws.srrabvnom clipped
    let d_cts08g06.linha7 = " "
    let d_cts08g06.linha8 = " "                           
    let d_cts08g06.linha9  = " TELEFONE(S): (", ws.celdddcod_vei clipped, ") " 
                                              , ws.celtelnum_vei using '<<<<<<<<<', " / "
                                              , ws.celtelnum_srr using '<<<<<<<<<'       
    let d_cts08g06.linha10 = "      NEXTEL: ", ws.nxtnum using '<<<<<<<<<', " ID: " , ws.nxtide clipped            
    
    let d_cts08g06.cabtxt = cts08g06_center(d_cts08g06.cabtxt, 40)
    
    open window w_cts08g06 at 8,19 with form "cts08g06"               
           attribute(border, form line first, message line last - 1)
                                               
    display by name d_cts08g06.cabtxt  attribute (reverse)
    display by name d_cts08g06.linha1 thru d_cts08g06.linha10
    
    message " (F17)Abandona"
    input by name d_cts08g06.confirma without defaults
       after field confirma
          next field confirma
       on key (interrupt, control-c)
          exit input
    end input
 end if
 let int_flag = false
 close window w_cts08g06
end function  ###  cts08g06


#-----------------------------------------------------------------------------
 function cts08g06_acnweb(param)
#-----------------------------------------------------------------------------

 define param        record
     srvidxflg char(1),
     recatddes char(50),
     srrnom    char(40),
     gpsatldat date,
     gpsatlhor datetime hour to second,
     recatdsgl char(3),
     lgdnom    char(50),
     lgdnum    integer,
     brrnom    char(30),
     cidnom    char(40),
     ufdsgl    char(2),
     lttnum    decimal(8,6),
     lgtnum    decimal(9,6),
     dstrot    integer,
     dstret    integer,
     tmprot    integer,
     telnumtxt char(20),
     nxtidt    char(20),
     nxtnumtxt char(20)
 end record
 
 define d_cts08g06   record
    cabtxt           char (40),
    confirma         char (01),
    linha1           char (40), 
    linha2           char (40), 
    linha3           char (40), 
    linha4           char (40),  
    linha5           char (40),
    linha6           char (40),
    linha7           char (40),
    linha8           char (40),
    linha9           char (40), 
    linha10          char (40) 
 end record  
 
 define l_dstkm decimal(12,2),
        l_tmpmin interval minute(3) to minute
 
 error " "
 
 if param.dstrot > 0 then
    let l_dstkm = param.dstrot / 1000 # converte metros para KM
 else
    let l_dstkm = param.dstret / 1000 # converte metros para KM
 end if
 
 call cts00m02_min(param.gpsatldat, param.gpsatlhor)
      returning l_tmpmin
 
 let d_cts08g06.cabtxt = 'POSICAO DO PRESTADOR RECEBIDA HA ', l_tmpmin, ' MIN'
 let d_cts08g06.linha1 = 'DISTANCIA ATE O SERVICO: ', l_dstkm using '<<<<<<&.&&', 'KM'
 let d_cts08g06.linha2 = '     *** LOCAL DA TRANSMISSAO ***'
 let d_cts08g06.linha3 = 'CIDADE: ', param.cidnom clipped, '/', param.ufdsgl
 let d_cts08g06.linha4 = 'BAIRRO: ', param.brrnom
 let d_cts08g06.linha5 = 'LOGRADOURO: ', param.lgdnom, ' ', param.lgdnum
 let d_cts08g06.linha6  = "----------------------------------------"
 let d_cts08g06.linha7  = "SE NECESSARIO, CONTATE O SOCORRISTA"
 let d_cts08g06.linha8  = param.srrnom
 let d_cts08g06.linha9  = "TELEFONE(S): ", param.telnumtxt
 let d_cts08g06.linha10 = "     NEXTEL: ", param.nxtnumtxt clipped , " ID: " , param.nxtidt clipped
                                                  
 open window w_cts08g06 at 8,19 with form "cts08g06"               
      attribute(border, form line first, message line last - 1)
                                               
 display by name d_cts08g06.cabtxt  attribute (reverse)
 display by name d_cts08g06.linha1 thru d_cts08g06.linha10
    
 message " (F17)Abandona"
 input by name d_cts08g06.confirma without defaults
       after field confirma
          next field confirma
       on key (interrupt, control-c)
          exit input
 end input
 
 let int_flag = false
 close window w_cts08g06

end function  ###  cts08g06_acnweb


#-----------------------------------------------------------------------------
 function cts08g06_center(param)
#-----------------------------------------------------------------------------

 define param        record
    lintxt           char (51),
    tam              smallint
 end record

 define i            smallint
 define tamanho      dec (2,0)


        let     i  =  null
        let     tamanho  =  null

 let tamanho = (param.tam - length(param.lintxt clipped))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function  ###  cts08g01_center

