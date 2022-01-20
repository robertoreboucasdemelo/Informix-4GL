#############################################################################
# Nome do Modulo: CTS59M00                                         Sergio   #
#                                                                  Burini   #
# BUSCA DE SERVIÇOS POR PROXIMIDADE                                Fev/2013 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
 
 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_pesquisa record
    datcmbini    date,
    horcmbini    datetime hour to minute,
    datcmbfim    date,
    horcmbfim    datetime hour to minute,
    dstsrv       integer,
    pstcoddig    like dpaksocor.pstcoddig,
    atdvclsgl    like datmservico.atdvclsgl,
    empcod       char(03),
    socntzgrpcod like datrgrpntz.socntzgrpcod,
    asitipcod    like datmservico.asitipcod,
    atdsrvorg    like datmservico.atdsrvorg,
    ufdcod       char(02),
    cidnom       char(50),
    lgdnom       char(100)
 end record

 define d_ctx25g05   record
        cidnom       like datmlcl.cidnom,
        ufdcod       like datmlcl.ufdcod,
        brrnom       like datmlcl.brrnom,
        lclbrrnom    like datmlcl.lclbrrnom,
        lgdtip       like datmlcl.lgdtip,
        lgdnom       like datmlcl.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        lclltt       like datmlcl.lclltt,
        lcllgt       like datmlcl.lcllgt,
        c24lclpdrcod like datmlcl.c24lclpdrcod
 end record

 define mr_aux record
     dathraini datetime year to minute,
     dathrafim datetime year to minute,
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     srvcbnhor like datmservico.srvcbnhor,
     atdlibflg like datmservico.atdlibflg,
     atdetpcod like datmservico.atdetpcod,
     asitipcod like datmservico.asitipcod,
     atdsrvorg like datmservico.atdsrvorg,
     ciaempcod like datmservico.ciaempcod,
     dstqru    decimal(8,2),
     ufdcod    char(02), 
     cidnom    char(50), 
     lgdnom    char(100),
     lclltt    like datmlcl.lclltt,
     lcllgt    like datmlcl.lcllgt
 end record
 
 define mr_ponto record
     lcllttini like datmlcl.lclltt,
     lcllgtini like datmlcl.lcllgt
 end record
 
 define ma_servico  array[5000] of record
     aux            char(01),
     servico        char(10),
     datacomb       char(05),
     horacomb       datetime hour to minute,
     atdlibflg      like datmservico.atdlibflg,
     espera         char(06),
     asitipdes      char(15),
     empsgl         char(05),
     atdetpdes      char(10),
     srvtipabvdes   char(10),
     endereco       char(100),
     dstqru         char(11)
 end record

 define a_cts00m1x      array[1500] of record
     atdsrvnum       like datmservico.atdsrvnum,
     atdsrvano       like datmservico.atdsrvano 
 end record

 define m_tipbsc char(001),
        arr_aux  smallint,
        scr_aux  smallint
        
 define ws        record
        succod    like datrservapol.succod, 
        ramcod    like datrservapol.ramcod, 
        aplnumdig like datrservapol.aplnumdig, 
        itmnumdig like datrservapol.itmnumdig,    
        crtnum    like datrsrvsau.crtnum,
        retflg    dec (1,0)
 end record         
 
# FUNÇÃO PRINCIPAL
#-------------------#
 function cts59m00()
#-------------------#

     define lr_retorno    record
         erro           smallint,
         msg            char(100),
         empsgl         char(020)
     end record
     
     define lr_retemp     record
         erro           smallint,
         ciaempcod      char(02),
         empnom         like gabkemp.empnom
     end record
     
     define l_ret   smallint,
            l_aux   char(50)

     initialize l_ret, l_aux to null
     
     open window w_cts59m00 at 4,2 with form "cts59m00"
          attribute(prompt line last, border, form line 1)
 
     while true
     
         initialize mr_aux.*, 
                    ma_servico,
                    mr_pesquisa.*, 
                    d_ctx25g05.*, 
                    lr_retorno.*, 
                    lr_retemp.*, 
                    ma_servico to null

         clear form
         
         input by name mr_pesquisa.* without defaults
         
             before input
                 let m_tipbsc = null
                 let int_flag = false
                 let mr_pesquisa.empcod = ''
         
             #--- CAMPO DATA INICIAL ---#
             before field datcmbini
                 if  mr_pesquisa.datcmbini is null or mr_pesquisa.datcmbini = ' ' then
                     let mr_pesquisa.datcmbini = today
                 end if
                 
                 display by name mr_pesquisa.datcmbini attribute(reverse)
         
             after field datcmbini
                 display by name mr_pesquisa.datcmbini
         
                 if  mr_pesquisa.datcmbini is null or mr_pesquisa.datcmbini = " " then
                     error "Campo Data inicial é obrigatorio."
                     next field datcmbini
                 end if
         
             #--- CAMPO HORA INICIAL ---#
             before field horcmbini
                 if  mr_pesquisa.horcmbini is null or mr_pesquisa.horcmbini = ' ' then
                     let mr_pesquisa.horcmbini = current
                 end if
                 
                 display by name mr_pesquisa.horcmbini attribute(reverse)
         
             after field horcmbini
                 display by name mr_pesquisa.horcmbini
         
                 if  mr_pesquisa.horcmbini is null or mr_pesquisa.horcmbini = " " then
                     error "Campo Hora inicial é obrigatorio."
                     next field horcmbini
                 end if
         
                 let mr_aux.dathraini = cts59m00_monta_data(mr_pesquisa.datcmbini, mr_pesquisa.horcmbini)
         
             #--- CAMPO DATA FINAL ---#
             before field datcmbfim
                 if  mr_pesquisa.datcmbfim is null or mr_pesquisa.datcmbfim = ' ' then
                     let mr_pesquisa.datcmbfim = mr_pesquisa.datcmbini
                 end if
                 
                 display by name mr_pesquisa.datcmbfim attribute(reverse)
         
             after field datcmbfim
                 display by name mr_pesquisa.datcmbfim
         
                 if  mr_pesquisa.datcmbfim is null or mr_pesquisa.datcmbfim = " " then
                     error "Campo Hora final é obrigatorio."
                     next field datcmbfim
                 end if
         
                 if  mr_pesquisa.datcmbfim < mr_pesquisa.datcmbini then
                     error "Data final nao deve ser menor que a data inicial."
                     let mr_pesquisa.datcmbfim = mr_pesquisa.datcmbini
                     next field datcmbfim
                 end if
         
             #--- CAMPO HORA FINAL ---#
             before field horcmbfim
                 if  mr_pesquisa.horcmbfim is null or mr_pesquisa.horcmbfim = ' ' then
                     let mr_pesquisa.horcmbfim = mr_pesquisa.horcmbini + 1 units hour
                 end if
         
                 display by name mr_pesquisa.horcmbfim attribute(reverse)
         
             after field horcmbfim
                 display by name mr_pesquisa.horcmbfim
         
                 if  mr_pesquisa.horcmbfim is null or mr_pesquisa.horcmbfim = " " then
                     error "Campo Hora final é obrigatorio."
                     next field horcmbfim
                 end if
         
                 let mr_aux.dathrafim = cts59m00_monta_data(mr_pesquisa.datcmbfim, mr_pesquisa.horcmbfim)

                 if  mr_aux.dathrafim < mr_aux.dathraini then
                     error 'Data / hora final não deve ser menor que a data / hora inicial'
                     next field datcmbini
                 end if
         
             #--- CAMPO DISTANCIA ---#
             before field dstsrv
                 display by name mr_pesquisa.dstsrv attribute(reverse)
         
             after field dstsrv
                 display by name mr_pesquisa.dstsrv
         
                 if  mr_pesquisa.dstsrv is null or mr_pesquisa.dstsrv = ' ' then
                     if fgl_lastkey() = fgl_keyval("up")     or                   
                        fgl_lastkey() = fgl_keyval("left")   then                 
                        next field horcmbfim                                      
                     end if

                     error 'Distancia nao deve ser nula'
                     next field dstsrv
                 else
                     if  mr_pesquisa.dstsrv <= 0 then
                         error 'Distancia invalida.'
                         let mr_pesquisa.dstsrv = 0
                         next field dstsrv
                     end if
                 end if
         
             #--- CAMPO PRESTADOR ---#
             before field pstcoddig
                 display by name mr_pesquisa.pstcoddig attribute(reverse)
         
             after field pstcoddig
                 display by name mr_pesquisa.pstcoddig
         
                 if  mr_pesquisa.pstcoddig is not null and mr_pesquisa.pstcoddig <> ' '  then
         
                    whenever error continue
                      select 1
                        from dpaksocor
                       where pstcoddig = mr_pesquisa.pstcoddig
                    whenever error stop
         
                    if  sqlca.sqlcode = 0 then
                        # BUSCA SERÁ REALIZADA POR PRESTADOR
                        let m_tipbsc = 'P'
                        next field empcod
                    else
                        error 'Prestador nao encontrado na base Porto Socorro'
                        let mr_pesquisa.pstcoddig = null
                        next field pstcoddig
                    end if
                 end if
         
             #--- CAMPO VIATURA ---#
             before field atdvclsgl
                 display by name mr_pesquisa.atdvclsgl attribute(reverse)
         
             after field atdvclsgl
                 display by name mr_pesquisa.atdvclsgl
         
                 if  mr_pesquisa.atdvclsgl is not null and mr_pesquisa.atdvclsgl <> ' '  then
         
                    whenever error continue
                      select 1
                        from datkveiculo
                       where atdvclsgl = mr_pesquisa.atdvclsgl
                    whenever error stop
         
                    if  sqlca.sqlcode = 0 then
                        # BUSCA SERÁ REALIZADA POR VEICULO
                        let m_tipbsc = 'V'
                        next field empcod
                    else
                        error 'Viatura nao encontrada na base Porto Socorro'
                        let mr_pesquisa.atdvclsgl = null
                        next field atdvclsgl
                    end if
                 end if
         
             #--- CAMPO EMPRESA ---#
             before field empcod
                 display by name mr_pesquisa.empcod attribute(reverse)
         
                 # CASO A PESQUISA NAO SEJA NEM POR PRESTADOR NEM POR SOCORRISTA
                 # ABRE A TELA DO ENDEREÇO PARA QUE O USUARIO INFORME O ENDEREÇO FIXO
                 if  m_tipbsc is null or m_tipbsc = ' ' then
         
                     # ABRE TELA APENAS SE A TOTEIRIZAÇÃO ESTIVER ATIVA
                     if  ctx25g05_rota_ativa() then
         
                         # PESQUISA DE ENDEREÇO COMPLETA
                         call ctx25g05("C","                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                                       "","","","","","","","","","","","")
                              returning d_ctx25g05.lgdtip,
                                        mr_pesquisa.lgdnom,
                                        d_ctx25g05.lgdnum,
                                        d_ctx25g05.brrnom,
                                        d_ctx25g05.lclbrrnom,
                                        d_ctx25g05.lgdcep,
                                        d_ctx25g05.lgdcepcmp,
                                        d_ctx25g05.lclltt,
                                        d_ctx25g05.lcllgt,
                                        d_ctx25g05.c24lclpdrcod,
                                        mr_pesquisa.ufdcod,
                                        mr_pesquisa.cidnom

                         if  d_ctx25g05.lclltt is not null and d_ctx25g05.lclltt <> ' ' and
                             d_ctx25g05.lcllgt is not null and d_ctx25g05.lcllgt <> ' ' then
                             display by name mr_pesquisa.ufdcod attribute(reverse) 
                             display by name mr_pesquisa.cidnom attribute(reverse) 
                             display by name mr_pesquisa.lgdnom attribute(reverse) 
                             let m_tipbsc = 'E'
                             next field empcod
                         else
                             error "Nenhuma busca foi selecionada."
                             next field pstcoddig
                         end if
                     else
                         error 'Roteirizacao desativada.'
                         next field pstcoddig
                     end if
                 end if
         
             after field empcod
                 display by name mr_pesquisa.empcod

                 if mr_pesquisa.empcod is null  or
                    mr_pesquisa.empcod =  " "   then
                    let mr_pesquisa.empcod = "TD"
                    display by name mr_pesquisa.empcod
                 else
                    if  mr_pesquisa.empcod <> "TD" then
                        call cty14g00_empresa_abv(mr_pesquisa.empcod) returning lr_retorno.*

                        if  lr_retorno.empsgl = 'N/D' then
         
                            error " Empresa invalida."
                            let mr_pesquisa.empcod = ""
         
                            # ABRE POPUP DE EMPRESAS
                            call cty14g00_popup_empresa() returning lr_retemp.*
                            let mr_pesquisa.empcod = lr_retemp.ciaempcod
                            next field empcod
         
                            display by name mr_pesquisa.empcod
                            next field empcod
         
                        end if
                    end if
                 end if
                 
                 if  m_tipbsc <> 'E' then
                     exit input
                 end if

         
             #--- CAMPO GRUPO DE NATUREZA ---#
             before field socntzgrpcod
                 display by name mr_pesquisa.empcod attribute (reverse)
                 
             after field socntzgrpcod                 
                 
                 if  mr_pesquisa.socntzgrpcod is not null and 
                     mr_pesquisa.socntzgrpcod <> " " then
                     
                     # VERIFICA SE O GRUPO DE NATUREZA EXISTE
                     call cts59m00_retorno_grupontz(mr_pesquisa.socntzgrpcod,"V")  
                          returning lr_retorno.erro,
                                    lr_retorno.msg
                     
                     if  lr_retorno.erro <> 0 then 
                         
                         error "Grupo não encontrado."
                         
                         call ctx24g00_popup_grupo()
                              returning lr_retorno.erro, mr_pesquisa.socntzgrpcod

                         next field socntzgrpcod
                     end if
                     
                     let mr_pesquisa.asitipcod = 6
                     let mr_pesquisa.atdsrvorg = 9
                     
                     display by name mr_pesquisa.asitipcod
                     display by name mr_pesquisa.atdsrvorg
                     
                     exit input
                     
                 end if
                 
                 if fgl_lastkey() = fgl_keyval("up")     or                   
                    fgl_lastkey() = fgl_keyval("left")   then                 
                    next field empcod                                      
                 end if
                                                               
             #--- CAMPO ORIGEM ---#
             before field asitipcod
                     display by name mr_pesquisa.asitipcod attribute(reverse)             
             
             after field asitipcod                
             
                 display by name mr_pesquisa.asitipcod
                 
                 if  mr_pesquisa.asitipcod is not null and 
                     mr_pesquisa.asitipcod <> " " then
                     
                     # VERIFICA SE A ASSISTENCIA EXISTE
                     call cts59m00_retorno_assistencia(mr_pesquisa.asitipcod)  
                          returning lr_retorno.erro,
                                    lr_retorno.msg
                     
                     if  lr_retorno.erro <> 0 then 
                         error 'Assitencia não encontrada.'
                         
                         let mr_pesquisa.asitipcod = ctn25c00(0)
                         next field asitipcod
                     end if
                 else
                     if fgl_lastkey() = fgl_keyval("up")     or
                        fgl_lastkey() = fgl_keyval("left")   then
                        next field socntzgrpcod
                     else
                        error "Assistencia não pode ser nula."
                        next field asitipcod
                     end if                   
                 end if 

             #--- CAMPO ORIGEM ---#
             before field atdsrvorg
                 display by name mr_pesquisa.atdsrvorg attribute(reverse)
                 
             after field atdsrvorg    
                                      
                 display by name mr_pesquisa.atdsrvorg
                 
                 if  mr_pesquisa.atdsrvorg is not null and 
                     mr_pesquisa.atdsrvorg <> " " then
                    
                     # VERIFICA SE A NATUREZA EXISTE 
                     call cts59m00_retorno_tiposervico(mr_pesquisa.atdsrvorg)
                              returning l_ret,
                                        l_aux  
                                     
                     if  l_ret <> 0 then
                         error "Origem não cadastrada."
                         let mr_pesquisa.atdsrvorg = cts00m09()
                         next field atdsrvorg
                     end if
                 else
                     if  fgl_lastkey() = fgl_keyval("up")     or
                         fgl_lastkey() = fgl_keyval("left")   then
                         next field asitipcod
                     else
                         error "Origem não pode ser nula"
                         next field atdsrvorg
                     end if                 
                 end if
                 
                 exit input
         
             after input
         
                 if  not int_flag then
                     if  m_tipbsc is null then
                         error 'Nenhuma busca selecionada'
                         next field pstcoddig
                     end if
                 end if
         
         end input
         
         if  not int_flag then
             call cts59m00_seleciona()
         else
             exit while
         end if
     
     end while
     
     let int_flag = false

     close window w_cts59m00

 end function

# FUNÇÃO PARA FORMATAR A DATA/HORA
#-----------------------------------#
 function cts59m00_monta_data(param)
#-----------------------------------#

     define param record
         data date,
         hora datetime hour to minute
     end record

     define l_retorno char(20)

     initialize l_retorno to null

     let l_retorno = extend(param.data, year to year),"-",
                     extend(param.data, month to month),"-",
                     extend(param.data, day to day)," ",
                     param.hora
                     
     return l_retorno

 end function

# FUNÇÃO PARA MONTAR A BUSCA DIMANICA
#------------------------------------#
 function cts59m00_seleciona()
#------------------------------------#

     define l_sql          char(3000),
            l_qtdsrv       smallint,
            l_etapas       char(0100),
            l_ret          smallint,
            l_aux          char(0010),
            l_chrlcllttini char(0020),
            l_chrlcllgtini char(0020),
            l_length       smallint,
            l_ind          smallint,
            l_socntzcod    char(500)
     
     initialize l_sql, 
                l_etapas, 
                l_chrlcllttini, 
                l_chrlcllgtini, 
                l_ret, 
                l_aux, 
                l_length, 
                l_ind, 
                l_socntzcod to null
                                                                              
     let l_qtdsrv = 0  
     
     let l_etapas = cts59m00_busca_etapa()
     
     call cts59m00_drop_temp_table()
     
     case m_tipbsc
          # QUANDO A BUSCA É POR PRESTADOR
          when 'P'
              let l_sql = " select srv.atdsrvnum, ",
                                 " srv.atdsrvano, ",
                                 " srv.srvcbnhor, ",
                                 " srv.atdlibflg, ",
                                 " srv.atdetpcod, ",
                                 " srv.asitipcod, ",
                                 " srv.atdsrvorg, ",
                                 " srv.ciaempcod ",
                            " from datmsrvre   re, ",
                                 " datmservico srv, ",
                                 " dparpstntz  ntz ",
                           " where srv.srvcbnhor between ? and ? ",
                             " and srv.atdetpcod in (" clipped ,l_etapas clipped ,")",
                             " and srv.atdsrvorg = 9 ",
                             " and srv.atdfnlflg in ('N','A') "
                             
              if  mr_pesquisa.empcod <> "TD" then              
                  let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_pesquisa.empcod
              end if               
                                        
              let l_sql = l_sql clipped, " and re.atdsrvnum  = srv.atdsrvnum ",
                                         " and re.atdsrvano  = srv.atdsrvano ",
                                         " and ntz.pstcoddig = ? ",
                                         " and ntz.socntzcod = re.socntzcod ",
                                       " union ",
                                      " select srv.atdsrvnum, ",
                                             " srv.atdsrvano, ",
                                             " srv.srvcbnhor, ",
                                             " srv.atdlibflg, ",
                                             " srv.atdetpcod, ",
                                             " srv.asitipcod, ",
                                             " srv.atdsrvorg, ",
                                             " srv.ciaempcod ",
                                        " from datmservico srv, datrassprs ass ",
                                       " where srv.srvcbnhor between ? and ? ",
                                         " and srv.atdetpcod in (" clipped ,l_etapas clipped ,")",
                                         " and srv.atdsrvorg in ( 1, 2, 3, 4, 5, 6, 7, 17 ) ",
                                         " and srv.atdfnlflg in ('N','A') "
                             
              if  mr_pesquisa.empcod <> "TD" then              
                  let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_pesquisa.empcod
              end if                              
       
              let l_sql = l_sql clipped, " and ass.pstcoddig = ? ",
                                         " and ass.asitipcod = srv.asitipcod "
                                         
              whenever error continue
              select endufd, 
                     endcid, 
                     endlgd,
                     lclltt, 
                     lcllgt 
                into mr_pesquisa.ufdcod,
                     mr_pesquisa.cidnom,
                     mr_pesquisa.lgdnom,
                     mr_ponto.lcllttini,     
                     mr_ponto.lcllgtini
                from dpaksocor 
               where pstcoddig = mr_pesquisa.pstcoddig
              whenever error stop
              
              if  (mr_ponto.lcllttini is null or mr_ponto.lcllttini = " ") or
                  (mr_ponto.lcllgtini is null or mr_ponto.lcllgtini = " ") then 
                  error "Prestador sem coordenada valida."
                  return
              end if                                         
         # QUANDO A BUSCA É POR VEICULO
         when "V"         
              let l_sql = "select srv.atdsrvnum, ",
                                " srv.atdsrvano, ",
                                " srv.srvcbnhor, ",
                                " srv.atdlibflg, ",
                                " srv.atdetpcod, ",
                                " srv.asitipcod, ",
                                " srv.atdsrvorg, ",
                                " srv.ciaempcod  ",
                           " from datkveiculo    vcl, ",
                                " dattfrotalocal frt, ",
                                " datmservico    srv, ",
                                " dbsrntzpstesp  esp, ",
                                " datmsrvre      re ",
                          " where srv.srvcbnhor between ? and ? ",
                            " and vcl.atdvclsgl = ? ",
                            " and vcl.socvclcod = frt.socvclcod ",
                            " and re.atdsrvnum  = srv.atdsrvnum ",
                            " and re.atdsrvano  = srv.atdsrvano ",
                            " and frt.srrcoddig = esp.srrcoddig ",
                            " and re.socntzcod  = esp.socntzcod ",
                            " and srv.asitipcod = 6 ",
                            " and srv.atdsrvorg = 9 ",
                            " and srv.atdfnlflg in ('N','A') ",
                            " and srv.atdetpcod in (" clipped ,l_etapas clipped ,")"   

              if  mr_pesquisa.empcod <> "TD" then              
                  let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_pesquisa.empcod
              end if

              let l_sql = l_sql clipped, " union ",
                                         " select srv.atdsrvnum, ",
                                                " srv.atdsrvano, ",
                                                " srv.srvcbnhor, ",
                                                " srv.atdlibflg, ",
                                                " srv.atdetpcod, ",
                                                " srv.asitipcod, ",
                                                " srv.atdsrvorg, ",
                                                " srv.ciaempcod  ",
                                           " from datkveiculo    vcl, ",
                                                " dattfrotalocal frt, ",
                                                " datmservico    srv, ",
                                                " datrsrrasi     asi ",
                                          " where srv.srvcbnhor between ? and ? ",
                                            " and vcl.atdvclsgl = ? ",
                                            " and vcl.socvclcod = frt.socvclcod ",
                                            " and frt.srrcoddig = asi.srrcoddig ",
                                            " and srv.asitipcod = asi.asitipcod ",
                                            " and srv.asitipcod <> 6 ",
                                            " and srv.atdsrvorg in ( 1, 2, 3, 4, 5, 6, 7, 17 ) ",
                                            " and srv.atdfnlflg in ('N','A') ",
                                            " and srv.atdetpcod in (" clipped ,l_etapas clipped ,")"                 

              if  mr_pesquisa.empcod <> "TD" then              
                  let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_pesquisa.empcod
              end if

              whenever error continue
                select pos.lclltt,
                       pos.lcllgt
                  into mr_ponto.lcllttini,     
                       mr_ponto.lcllgtini
                  from datmfrtpos pos, datkveiculo vcl
                 where pos.socvclcod = vcl.socvclcod
                   and vcl.atdvclsgl = mr_pesquisa.atdvclsgl
                   and pos.socvcllcltip = 1
              whenever error stop
              
              if  (mr_ponto.lcllttini is null or mr_ponto.lcllttini = " ") or
                  (mr_ponto.lcllgtini is null or mr_ponto.lcllgtini = " ") then 
                  error "Veiculo sem coordenada valida."
                  return        
              end if     

              if  ctx25g05_rota_ativa() then
                  call ctx25g01_endereco(mr_ponto.lcllgtini,
                                         mr_ponto.lcllttini,
                                         "O")
                       returning l_ret,   
                                 mr_pesquisa.ufdcod,       
                                 mr_pesquisa.cidnom,       
                                 l_aux,       
                                 mr_pesquisa.lgdnom,       
                                 l_aux,       
                                 l_aux 
                                 
              else
                  let mr_pesquisa.ufdcod = 'NL'
                  let mr_pesquisa.cidnom = 'CID NAO LOCALIZADO'
                  let mr_pesquisa.lgdnom = 'LOG NAO LOCALIZADO'
              end if
         # QUANDO A BUSCA É POR ENDEREÇO
         when "E"
              let mr_ponto.lcllttini = d_ctx25g05.lclltt
              let mr_ponto.lcllgtini = d_ctx25g05.lcllgt  
              
              let l_sql = "select srv.atdsrvnum, ",
                                " srv.atdsrvano, ",
                                " srv.srvcbnhor, ",
                                " srv.atdlibflg, ",
                                " srv.atdetpcod, ",
                                " srv.asitipcod, ",
                                " srv.atdsrvorg, ",
                                " srv.ciaempcod  "
             
              if  mr_pesquisa.socntzgrpcod is not null and 
                  mr_pesquisa.socntzgrpcod <> " " then
                  
                  call cts59m00_retorno_grupontz(mr_pesquisa.socntzgrpcod,"B")
                       returning l_ret,
                                 l_socntzcod 

                  let l_sql = l_sql clipped, " from datmservico srv, ",
                                                  " datmsrvre   re ",
                                            " where srv.srvcbnhor between ? and ? ",
                                              " and srv.atdsrvnum = re.atdsrvnum ",
                                              " and srv.atdsrvano = re.atdsrvano ",
                                              " and re.socntzcod  in (", l_socntzcod clipped ,")"             
              else
                  let l_sql = l_sql clipped,  " from datmservico srv ",
                                             " where srv.srvcbnhor between ? and ? " 
              end if              

              let l_sql = l_sql clipped, " and srv.asitipcod = ", mr_pesquisa.asitipcod,
                                         " and srv.atdsrvorg = ", mr_pesquisa.atdsrvorg,
                                         " and srv.atdfnlflg in ('N','A') ",
                                         " and srv.atdetpcod in (" clipped ,l_etapas clipped ,")"                                  
   
              if  mr_pesquisa.empcod <> "TD" then              
                  let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_pesquisa.empcod
              end if                                           

     end case

     display by name mr_pesquisa.ufdcod attribute(reverse) 
     display by name mr_pesquisa.cidnom attribute(reverse) 
     display by name mr_pesquisa.lgdnom attribute(reverse) 

     prepare pcts59m00_00001 from l_sql
     declare ccts59m00_00001 cursor for pcts59m00_00001 

     case m_tipbsc
          when 'P'     
              open ccts59m00_00001 using mr_aux.dathraini,
                                         mr_aux.dathrafim,
                                         mr_pesquisa.pstcoddig,
                                         mr_aux.dathraini,
                                         mr_aux.dathrafim,
                                         mr_pesquisa.pstcoddig
          when 'V'
              open ccts59m00_00001 using mr_aux.dathraini,
                                         mr_aux.dathrafim,
                                         mr_pesquisa.atdvclsgl,
                                         mr_aux.dathraini,
                                         mr_aux.dathrafim,
                                         mr_pesquisa.atdvclsgl                         
          when "E"
              open ccts59m00_00001 using mr_aux.dathraini,
                                         mr_aux.dathrafim
     end case

     call cts59m00_cria_temp_table()
     
     foreach ccts59m00_00001 into mr_aux.atdsrvnum,
                                  mr_aux.atdsrvano,
                                  mr_aux.srvcbnhor,
                                  mr_aux.atdlibflg,
                                  mr_aux.atdetpcod,
                                  mr_aux.asitipcod,
                                  mr_aux.atdsrvorg,
                                  mr_aux.ciaempcod
         
         # BUSCA A COORDENADA DO SERVIÇO
         call cts59m00_endereco_servico(mr_aux.atdsrvnum,
                                        mr_aux.atdsrvano)
              returning mr_aux.ufdcod,
                        mr_aux.cidnom,
                        mr_aux.lgdnom,
                        mr_aux.lclltt,
                        mr_aux.lcllgt

         # CASO O ENDEREÇO DO SERVIÇO NAO SEJA VALIDO, DESCARTA O MESMO
         if  (mr_aux.lclltt is null or mr_aux.lclltt = ' ') or 
             (mr_aux.lcllgt is null or mr_aux.lcllgt = ' ') then
             continue foreach
         end if
         
         # CALCULA A DISTANCIA DO PONTO E DO SERVIÇO
         let mr_aux.dstqru = cts18g00(mr_ponto.lcllttini,
                                      mr_ponto.lcllgtini,
                                      mr_aux.lclltt,
                                      mr_aux.lcllgt)

         # INCLUI NA TABELA APENAS DISTANCIAS VALIDAS.
         if  mr_aux.dstqru >= 0 then
             insert into temp_srvacpcom values (mr_aux.atdsrvnum,
                                                mr_aux.atdsrvano,
                                                mr_aux.srvcbnhor,
                                                mr_aux.atdlibflg,
                                                mr_aux.atdetpcod,
                                                mr_aux.asitipcod,
                                                mr_aux.atdsrvorg,
                                                mr_aux.ciaempcod,
                                                mr_aux.ufdcod,
                                                mr_aux.cidnom,
                                                mr_aux.lgdnom,
                                                mr_aux.dstqru) 
         
             let l_qtdsrv = l_qtdsrv + 1
         end if
                 
     end foreach   

     # CASO ALGUM SERVIÇO SEJA ENCONTRADO CONFORME OS PARAMETROS
     # ELES SERÃO APRESENTADOS NA TELA DE EXIBIÇÃO DE SERVIÇOS
     if  l_qtdsrv > 0 then
         call cts59m00_exibe_servicos()
     else
         error 'Nenhum serviço localizado'
         sleep 2
     end if
     
end function

# FUNÇÃO PARA CRIAR A TABELA TEMPORARIA
#-----------------------------------#
 function cts59m00_cria_temp_table()
#-----------------------------------#
     
     create temp table temp_srvacpcom (atdsrvnum           decimal(10,0) ,
                                       atdsrvano           decimal(2,0) ,
                                       srvcbnhor           datetime year to second,
                                       atdlibflg           char(01),
                                       atdetpcod           smallint,
                                       asitipcod           smallint,
                                       atdsrvorg           smallint,
                                       empcod              smallint,
                                       ufdcod              char(02),
                                       cidnom              char(50),
                                       lgdnom              char(100),
                                       dstqru              decimal(10,4)) with no log
     
 end function   

# DROP DA TABELA TEMPORARIA - EXECUTADA EM TODA EXECUÇÃO
#-----------------------------------#
 function cts59m00_drop_temp_table()
#-----------------------------------#
     
     whenever error continue
         drop table temp_srvacpcom
     whenever error stop
     
 end function     

# FUNÇÃO PARA BUSCA DOS DADOS DO ENDEREÇO DO SERVIÇO
#-----------------------------------------#
 function cts59m00_endereco_servico(param)
#-----------------------------------------#

     define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record
     
     define lr_retorno record
         ufdcod like datmlcl.ufdcod,
         cidnom like datmlcl.cidnom,
         lgdnom like datmlcl.lgdnom,
         lclltt like datmlcl.lclltt,
         lcllgt like datmlcl.lcllgt
     end record
     
     initialize lr_retorno.* to null
     
     whenever error continue
     select ufdcod, 
            cidnom, 
            lgdnom,
            lclltt, 
            lcllgt 
       into lr_retorno.ufdcod,
            lr_retorno.cidnom,
            lr_retorno.lgdnom,
            lr_retorno.lclltt,
            lr_retorno.lcllgt    
       from datmlcl            
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano
        and c24endtip = 1      
     whenever error stop
     
     return lr_retorno.ufdcod,
            lr_retorno.cidnom,
            lr_retorno.lgdnom, 
            lr_retorno.lclltt,   
            lr_retorno.lcllgt    
 
 end function

# FUNÇÃO PARA EXIBIÇÃO DOS SERVIÇOS NA TELA DE ROTEIRO
#----------------------------------# 
 function cts59m00_exibe_servicos()
#----------------------------------#
 
     define lr_aux record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         srvcbnhor like datmservico.srvcbnhor,
         data      date,
         hora      datetime hour to minute,
         horaaux   datetime year to minute,
         empcod    smallint,
         atdetpcod smallint,
         atdetpdes char(10),
         atdsrvorg like datmservico.atdsrvorg,
         asitipcod like datmservico.asitipcod,
         dstqru    decimal(8,2)
     end record
     
     define l_ind       smallint,
            l_dst       decimal(8,2),
            l_ret       smallint,
            l_mensagem  char(60)

     initialize lr_aux.*, 
                l_dst,
                l_ret,      
                l_mensagem to null
     
     # TRANFORMA A BUSCA EM METROS
     let l_dst = mr_pesquisa.dstsrv / 1000
     
     declare cq_cursor_servicos cursor for
      select atdsrvnum,                                 
             atdsrvano,                                 
             atdlibflg,                                 
             atdetpcod,                                 
             asitipcod,                                 
             srvcbnhor,                                 
             atdsrvorg,                                 
             empcod,                                    
             ufdcod,                                    
             cidnom,                                    
             lgdnom,                                    
             dstqru                                     
        from temp_srvacpcom                             
       where dstqru <= l_dst
       order by srvcbnhor, dstqru
     
     let l_ind = 1
     
     foreach cq_cursor_servicos into lr_aux.atdsrvnum,                       
                                     lr_aux.atdsrvano,                       
                                     ma_servico[l_ind].atdlibflg,            
                                     lr_aux.atdetpcod, 
                                     lr_aux.asitipcod,                      
                                     lr_aux.srvcbnhor,                       
                                     lr_aux.atdsrvorg,                       
                                     lr_aux.empcod,                          
                                     mr_aux.ufdcod,                          
                                     mr_aux.cidnom,                          
                                     mr_aux.lgdnom,                          
                                     lr_aux.dstqru                                            
         
         # FORMATA A DISTANCIA
         let ma_servico[l_ind].dstqru = lr_aux.dstqru using "&&&&.&&&"

         let lr_aux.data = extend(lr_aux.srvcbnhor, year to day)
         let lr_aux.hora = extend(lr_aux.srvcbnhor, hour to minute)
         
         # CALCULA DO TEMPO DE ESPERA
         call cts00m00_espera(lr_aux.data, lr_aux.hora)
              returning ma_servico[l_ind].espera
         
         # BUSCA SIGLA DA EMPRESA
         call cty14g00_empresa(1, lr_aux.empcod)
              returning l_ret,
                        l_mensagem,
                        ma_servico[l_ind].empsgl 

         let lr_aux.horaaux = ma_servico[l_ind].espera
         
         # CONCATENA NUMERO DO SERVIÇO
         let ma_servico[l_ind].servico  = lr_aux.atdsrvorg using "&&","/", lr_aux.atdsrvnum
         
         # MONTA HORA COMBINADA
         let ma_servico[l_ind].datacomb  = extend(lr_aux.srvcbnhor, day to day), "/",
                                           extend(lr_aux.srvcbnhor, month to month)
         let ma_servico[l_ind].horacomb  = extend(lr_aux.srvcbnhor, hour to minute)
         
         # OBTER A DESCRICAO DA ETAPA
         call cts10g05_desc_etapa(3, lr_aux.atdetpcod)
              returning l_ret,
                        ma_servico[l_ind].atdetpdes
         
         # DESCRIÇÃO DA ORIGEM       
         call cts59m00_retorno_tiposervico(lr_aux.atdsrvorg)
              returning l_ret,
                        ma_servico[l_ind].srvtipabvdes         
         
         # CASO SEJA AUTO - BUSCA DESCRIÇÃO DE ASSISTENCIA
         if  lr_aux.atdsrvorg <> 9 then
         
             call cts59m00_retorno_assistencia(lr_aux.asitipcod)               
                  returning l_ret,                                                  
                            ma_servico[l_ind].asitipdes 
                            
         else                   
             # CASO SEJA RE - BUSCA DESCRIÇÃO DE NATUREZA
             
             call cts59m00_retorno_natureza(lr_aux.atdsrvnum,lr_aux.atdsrvano)               
                  returning l_ret,                                                  
                            ma_servico[l_ind].asitipdes              
             
         end if                                            

         # MONTA ENDEREÇO         
         let ma_servico[l_ind].endereco = mr_aux.ufdcod clipped,"/",
                                          mr_aux.cidnom clipped,"/",
                                          mr_aux.lgdnom
         
         # ARRAY AUXILIAR DE SERVIÇO
         let a_cts00m1x[l_ind].atdsrvnum = lr_aux.atdsrvnum
         let a_cts00m1x[l_ind].atdsrvano = lr_aux.atdsrvano

         let l_ind = l_ind + 1  
         
         error "SERVIÇOS SENDO ANALISADOS: ", l_ind                               
                                          
     end foreach 
     
     # CASO HAJA ALGO PARA SER EXIBIDO
     if  l_ind > 1 then
         
         error ''
         let l_ind = l_ind - 1

         display l_ind to total attribute (reverse)
         
         call set_count(l_ind)
         display array ma_servico to s_servicos.*
         
             # MENU LIGAÇÕES
             on key (F7)
             
                   let arr_aux = arr_curr()
                   let scr_aux = scr_line()                  
             
                   initialize g_documento.succod    to null
                   initialize g_documento.ramcod    to null
                   initialize g_documento.aplnumdig to null
                   initialize g_documento.itmnumdig to null
                   
                   let ws.succod    = null
                   let ws.ramcod    = null
                   let ws.aplnumdig = null
                   let ws.itmnumdig = null
                   let ws.crtnum    = null
             
                   select succod   ,
                          ramcod   ,
                          aplnumdig,
                          itmnumdig
                     into ws.succod   ,
                          ws.ramcod   ,
                          ws.aplnumdig,
                          ws.itmnumdig
                     from datrservapol
                    where atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                      and atdsrvano = a_cts00m1x[arr_aux].atdsrvano
             
                   if sqlca.sqlcode <> 0  then
                      select succod  ,
                             ramcod  ,
                             aplnumdig ,
                             crtnum
                        into ws.succod,
                             ws.ramcod,
                             ws.aplnumdig,
                             ws.crtnum
                       from datrsrvsau
                      where atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                        and atdsrvano = a_cts00m1x[arr_aux].atdsrvano
                      if sqlca.sqlcode <> 0  then
                         error " Nao e' possivel consultar ligacoes para servico sem documento informado!"
                      end if
                   else
                      call cta02m02_consultar_ligacoes(ws.succod   , ws.ramcod,
                                                       ws.aplnumdig, ws.itmnumdig,
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       '', '',
                                                       ws.crtnum,"","")
                   end if
                   
             # MENU LAUDO
             on key (F8)
             
                let arr_aux = arr_curr()
                let scr_aux = scr_line()
             
                if a_cts00m1x[arr_aux].atdsrvnum  is not null   then
                   let g_documento.atdsrvnum = a_cts00m1x[arr_aux].atdsrvnum
                   let g_documento.atdsrvano = a_cts00m1x[arr_aux].atdsrvano
             
                   call cts04g00('cts00m10') returning ws.retflg

                else
                   error " Servico nao selecionado!"
                end if                   
             
             # MENU NOVA CONSULTA
             on key (F6)
                call cts59m00_seleciona()
             
         end display 
   
     else
         error 'Nenhum servico encontrado'
     end if
     
     call cts59m00_drop_temp_table()    
 
 end function

# BUSCA ETAPAS ANALISADAS
#-------------------------------# 
 function cts59m00_busca_etapa()
#-------------------------------#
     
     define l_etapa   like datmservico.atdetpcod,
            l_retorno char(100)
     
     initialize l_etapa,
                l_retorno to null
     
     declare cq_cursor_dominio cursor for
     select cpocod 
       from iddkdominio
      where cponom = 'etplstsrvrtr'
     
     foreach cq_cursor_dominio into l_etapa
         if  l_retorno is null then
             let l_retorno = l_etapa
         else
             let l_retorno = l_retorno clipped, ",", l_etapa
         end if
     
     end foreach
     
     if  l_retorno is null then
         return 1
     else
         return l_retorno
     end if 
 
 end function 

# RETORNA DESCRIÇÃO DO SERVIÇO
#--------------------------------------------# 
 function cts59m00_retorno_tiposervico(param)
#--------------------------------------------#
 
     define param record
         atdsrvorg   like datmservico.atdsrvorg
     end record
     
     define lr_retorno record
         erro         smallint,
         srvtipabvdes like datksrvtip.srvtipabvdes
     end record
    
     if  param.atdsrvorg is null or param.atdsrvorg = ' ' then
         return 1, "Origem nula"
     end if
     
     whenever error continue
      select srvtipabvdes 
        into lr_retorno.srvtipabvdes
        from datksrvtip 
       where atdsrvorg = param.atdsrvorg
     whenever error stop
     
     let lr_retorno.erro = sqlca.sqlcode
     
     if  sqlca.sqlcode <> 0 then
         let lr_retorno.srvtipabvdes = 'ERRO ', sqlca.sqlcode, " cts59m00_retorno_tiposervico"
     end if
     
     return lr_retorno.*
 
 end function
 
# RETORNA DESCRIÇÃO DA ASSISTENCIA 
#--------------------------------------------# 
 function cts59m00_retorno_assistencia(param)
#--------------------------------------------#
 
     define param record
         asitipcod   like datkasitip.asitipcod
     end record
     
     define lr_retorno record
         erro         smallint,
         asitipdes    like datkasitip.asitipdes
     end record
    
     if  param.asitipcod is null or param.asitipcod = ' ' then
         return 1, "Assistencia nula"
     end if
     
     whenever error continue
       select asitipdes 
         into lr_retorno.asitipdes
         from datkasitip 
        where asitipcod = param.asitipcod
     whenever error stop
     
     let lr_retorno.erro = sqlca.sqlcode
     
     if  sqlca.sqlcode <> 0 then
         let lr_retorno.asitipdes = 'Assistencia não encontrada.'
     end if
     
     return lr_retorno.*
 
 end function
 
# RETORNA NATUREZAS DO GRUPO 
#-----------------------------------------# 
 function cts59m00_retorno_grupontz(param)
#-----------------------------------------#
 
     define param record
         socntzgrpcod   like datrgrpntz.socntzgrpcod,
         opcao          char(01)
     end record
     
     define lr_retorno record
         erro           smallint,
         socntzgrpdes   like datksocntzgrp.socntzgrpdes,
         socntz         char(500)     
     end record
     
     define l_socntzcod like datrgrpntz.socntzcod,
            l_ind       smallint
     
     initialize lr_retorno.*, l_socntzcod to null
     
     let l_ind = 0
     
     if  param.socntzgrpcod is null or param.socntzgrpcod = ' ' then
         return 1, "Grupo de natureza nula"
     end if
     
     whenever error continue
       select socntzgrpdes 
         into lr_retorno.socntzgrpdes
         from datksocntzgrp 
        where socntzgrpcod = param.socntzgrpcod
     whenever error stop
     
     if  sqlca.sqlcode = 0 then
         
       declare cq_cursor_ntzcod cursor for
        select socntzcod 
          from datrgrpntz 
         where socntzgrpcod = param.socntzgrpcod
         
       foreach cq_cursor_ntzcod into l_socntzcod
           
           if  lr_retorno.socntz is null then
               let lr_retorno.socntz = l_socntzcod
           else
               let lr_retorno.socntz = lr_retorno.socntz clipped, ",", l_socntzcod
           end if
          
       end foreach
       
       if  sqlca.sqlcode <> 0 then
           let lr_retorno.socntzgrpdes = 'Nenhuma natureza cadastrada para esse grupo. ERRO ', sqlca.sqlcode
       else
           if  param.opcao = "B" then
               return sqlca.sqlcode, 
                      lr_retorno.socntz
           end if
       end if
       
     else
         let lr_retorno.socntzgrpdes = 'Grupo de natureza não encontrada. ERRO ', sqlca.sqlcode   
     end if
     
     let lr_retorno.erro = sqlca.sqlcode
     
     return lr_retorno.erro,        
            lr_retorno.socntzgrpdes
          
 end function

# RETORNA DESCRIÇÃO DA NATUREZA
#--------------------------------------------# 
 function cts59m00_retorno_natureza(param)
#--------------------------------------------#
 
     define param record
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano   
     end record
     
     define lr_retorno record
         erro         smallint,
         socntzdes    like datksocntz.socntzdes
     end record
    
    initialize lr_retorno.* to null
    
    if  param.atdsrvnum is null or param.atdsrvnum = ' ' or 
        param.atdsrvano is null or param.atdsrvano = ' ' then
        return 1, "Servico nulo"
    end if
    
    whenever error continue
      select ntz.socntzdes 
        into lr_retorno.socntzdes
        from datmsrvre  srv,
             datksocntz ntz
       where atdsrvnum     = param.atdsrvnum 
         and atdsrvano     = param.atdsrvano
         and ntz.socntzcod = srv.socntzcod
    whenever error stop
    
    let lr_retorno.erro = sqlca.sqlcode
    
    if  sqlca.sqlcode <> 0 then
        let lr_retorno.socntzdes = 'Natureza não encontrada.'
    end if
    
    
    
    return lr_retorno.*
 
 end function 