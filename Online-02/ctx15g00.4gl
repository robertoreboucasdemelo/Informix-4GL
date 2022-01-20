#############################################################################
# Nome do Modulo: CTX15G00                                         Wagner   #
#                                                                           #
# Apura valores para servicos RE                                   Mar/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/07/2002  PSI 15620-5  Wagner       Adaptacao leitura tabela precos     #
#...........................................................................#
# 22/08/2005  PSI 194573  Cristiane Silva Retirada da regra de desconto de  #
#                                         22,00 para casos de retorno       #
#...........................................................................#
# 6/10/2006   PSI 202720  Priscila      Implementar cartao SAUDE            #
#...........................................................................#
# 08/08/2007  PSI 211001  Sergio Burini Inclusão de Adicional Noturno,      #
#                                       Feriado e Domingo                   #
# 08/10/2009  PSI 247790  Burini        Adequação de tabelas                #
#...........................................................................#
# 14/02/2014              Josiane       Nova atribuição do adicional noturno#
#############################################################################

database porto

#----------------------------------------------------------------
 function ctx15g00_vlrre(param)
#----------------------------------------------------------------
 define param       record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano
 end record

 define ws          record
    atddat          like datmservico.atddat,
    atdprscod       like datmservico.atdprscod,
    vlrtabflg       like dpaksocor.vlrtabflg,
    rmesoctrfcod    like dpaksocor.rmesoctrfcod,
    atdsrvnum       like datmsrvre.atdsrvnum,
    atdsrvano       like datmsrvre.atdsrvano,
    atdetpcod       like datmsrvacp.atdetpcod,
    socntzcod       like datmsrvre.socntzcod,
    socntzgrpcod    like datksocntz.socntzgrpcod,
    vlrsugerido     like dbsksrvrmeprc.srvrmevlr,
    vlrsugeridoadc  like dbsksrvrmeprc.srvrmevlr,
    vlrmaximo       like dbsksrvrmeprc.srvrmevlr,
    vlrdiferenc     like dbsksrvrmeprc.srvrmedifvlr,
    vlrmltdesc      like dbsksrvrmeprc.srvrmedscmltvlr,
    vlrprmini       like dbsksrvrmeprc.srvrmevlr,
    vlrprmdes       like dbsksrvrmeprc.srvrmevlr,
    vlrprmadc       like dbsksrvrmeprc.srvrmevlr,
    vlrprmstt       smallint,
    nrsrvs          smallint,     # (nr. do servico correspontente)
    flgtab          smallint,      # (1-tabela) (2-tabela inexistente)
    atdorgsrvnum    like datmsrvre.atdorgsrvnum,
    srvrmedifvlr    like dbsksrvrmeprc.srvrmedifvlr,
    socvclcod       like datmservico.socvclcod,
    socvcltip       like datkveiculo.socvcltip
 end record

 display "Servico: ", param.atdsrvnum, "/", param.atdsrvano  

 #---------------------------------------------------
 # Verifica informacoes do servico
 #---------------------------------------------------
 select datmservico.atddat , datmservico.atdprscod,
        datmservico.socvclcod 
   into ws.atddat          , ws.atdprscod,
        ws.socvclcod
   from datmservico
  where datmservico.atdsrvnum = param.atdsrvnum
    and datmservico.atdsrvano = param.atdsrvano
    
    display "ws.atddat: ", ws.atddat 
    display "ws.atdprscod: ", ws.atdprscod 
    display "ws.socvclcod: ", ws.socvclcod 
    
 #---------------------------------------------------
 # Verifica informacoes do prestador RE
 #---------------------------------------------------
 select dpaksocor.vlrtabflg, dpaksocor.rmesoctrfcod
   into ws.vlrtabflg       , ws.rmesoctrfcod
   from dpaksocor
  where dpaksocor.pstcoddig = ws.atdprscod

 #---------------------------------------------------
 # Verifica informacoes da natureza do servico RE
 #---------------------------------------------------
 select datmsrvre.socntzcod
   into ws.socntzcod
   from datmsrvre
  where datmsrvre.atdsrvnum   = param.atdsrvnum
    and datmsrvre.atdsrvano   = param.atdsrvano
    
    display "ws.socntzcod: ", ws.socntzcod

 #PSI BURGMAN
 #---------------------------------------------------
 # Verifica tipo de veículo serviço RE
 #---------------------------------------------------
  select datkveiculo.socvcltip
    into ws.socvcltip
    from datkveiculo
   where datkveiculo.socvclcod = ws.socvclcod

     call ctd00g00_vlrprmpgm(param.atdsrvnum, param.atdsrvano, "INI")
     returning ws.vlrprmini,
               ws.vlrprmstt

     call ctd00g00_vlrprmpgm(param.atdsrvnum, param.atdsrvano, "MUL")
     returning ws.vlrprmdes,
               ws.vlrprmstt               
	       
     #---------------------------------------------------
     # Acessa tabela precos para servicos RE
     #---------------------------------------------------
     select dbsksrvrmeprc.srvrmevlr, dbsksrvrmeprc.srvrmedifvlr,
            dbsksrvrmeprc.srvrmedscmltvlr
       into ws.vlrsugerido, ws.vlrdiferenc,
            ws.vlrmltdesc
       from dbsksrvrmeprc
      where dbsksrvrmeprc.soctrfcod  = ws.rmesoctrfcod
        and dbsksrvrmeprc.socntzcod  = ws.socntzcod
        and dbsksrvrmeprc.viginc    <= ws.atddat
        and dbsksrvrmeprc.vigfnl    >= ws.atddat

     if sqlca.sqlcode = notfound then
        #-----------------------------------
        # SEM TABELA
        #-----------------------------------
        let ws.flgtab      = 2
        let ws.nrsrvs      = 1
        let ws.vlrsugerido = 1
        
        let ws.vlrsugerido = ctd00g00_compvlr(ws.vlrsugerido, ws.vlrprmini)
     else

        let ws.vlrsugerido = ctd00g00_compvlr(ws.vlrsugerido, ws.vlrprmini)
        let ws.vlrmltdesc  = ctd00g00_compvlr(ws.vlrmltdesc,  ws.vlrprmdes)
        
        #---------------------------------------------------
        # Acesso tabela natureza p/identificar tipo de servico
        #---------------------------------------------------
        let ws.flgtab  = 1
        select socntzgrpcod
          into ws.socntzgrpcod
          from datksocntz
         where datksocntz.socntzcod = ws.socntzcod

        if sqlca.sqlcode = notfound then
           let ws.socntzgrpcod = 2
        end if

        #if  ws.vlrprmstt <> 0 then
            # PSI 211001                                                 
            # Pagamento de Adicionais Noturno, Feriado e Domingo - Burini
            if  ctx15g01_verif_adic(param.atdsrvnum,param.atdsrvano) then
            
                 call ctx15g00_vlr_adic(param.atdsrvnum,
                                        param.atdsrvano,
                                        ws.vlrsugerido)
                      returning ws.vlrsugeridoadc
                      
                 call ctd00g00_vlrprmpgm(param.atdsrvnum,
                                         param.atdsrvano,
                                         "ADC")
                      returning ws.vlrprmadc,
                                ws.vlrprmstt  
                                
                 let ws.vlrsugerido = ctd00g00_compvlr(ws.vlrsugeridoadc, ws.vlrprmadc)                                     
                
                 display "SERVICO: ", param.atdsrvnum, " - ", param.atdsrvano,
                         "VALOR TABELA: ", ws.vlrsugeridoadc,
                         "VALOR PARAM: ",  ws.vlrprmadc,
                         "VALOR PAGO: ",   ws.vlrsugerido                  
   
            end if
        #end if

        let ws.nrsrvs = ctx15g00_srvre(param.atdsrvnum, param.atdsrvano,
                                       ws.atddat      , ws.atdprscod   ,
                                       ws.socntzgrpcod)
        if ws.nrsrvs > 1 then
	      #PSI 194573
          if ws.vlrsugerido  <>  1 then
	          select atdorgsrvnum
	          into ws.atdorgsrvnum
	          from datmsrvre
	          where atdsrvnum = param.atdsrvnum
	          and atdsrvano = param.atdsrvano

	          if  ws.atdorgsrvnum is null then
	              let ws.vlrsugerido = ws.vlrsugerido - ws.vlrmltdesc
	          else
	              let ws.vlrmltdesc = 0
	          end if
	      #Fim PSI 194573
          end if
        else
          let ws.vlrmltdesc = 0
        end if

     end if


 let ws.vlrmaximo   = 500

 return ws.socntzcod,  ws.vlrsugerido,
        ws.vlrmaximo,  ws.vlrdiferenc,
        ws.vlrmltdesc, ws.nrsrvs, ws.flgtab

end function  #-- ctx15g00_vlrre

#---------------------------#
 function ctx15g00_prepare()
#---------------------------#

     define l_sql char(1000)

    #let l_sql = "select atdetpdat, ",
    #                  " atdetphor, ",
    #                  " pstcoddig ",
    #             " from datmsrvacp ",
    #            " where atdsrvnum = ? ",
    #              " and atdsrvano = ? ",
    #              " and atdsrvseq = (select max(atdsrvseq) ",
    #                                   " from datmsrvacp ",
    #                                  " where atdsrvnum = ? ",
    #                                    " and atdsrvano = ?) "
     
     let l_sql = "select srvcbnhor,       ",         
     									"	atdprscod        ",          
     							"	from datmservico     ",          
     						"	where atdsrvnum = ?    ",          
     							" and atdsrvano = ?		 "           

                   
     prepare pctx15g0001 from l_sql
     declare cctx15g0001 cursor for pctx15g0001

     let l_sql = " select 1 ",
                   " from igfkferiado ",
                  " where ferdia = ? ",
                    " and fertip = 'N' "

     prepare pctx15g0002 from l_sql
     declare cctx15g0002 cursor for pctx15g0002

     let l_sql = " select srvrmedifvlr ",
                   " from dbsksrvrmeprc ",
                  " where soctrfcod = ? ",
                    " and socntzcod = ? ",
                    " and viginc   <= ? ",
                    " and vigfnl   >= ? "

     prepare pctx15g0003 from l_sql
     declare cctx15g0003 cursor for pctx15g0003

     let l_sql = " select acp.atdetpdat, ",
                        " soc.rmesoctrfcod, ",
                        " sre.socntzcod ",
                   " from datmsrvre  sre, ",
                        " datmsrvacp acp, ",
                        " dpaksocor  soc ",
                  " where sre.atdsrvnum = ? ",
                    " and sre.atdsrvano = ? ",
                    " and acp.atdsrvnum = sre.atdsrvnum ",
                    " and acp.atdsrvano = sre.atdsrvano ",
                    " and acp.atdsrvseq = (select max(atdsrvseq) ",
                                           " from datmsrvacp ",
                                          " where atdsrvnum = ? ",
                                            " and atdsrvano = ?) ",
                    " and soc.pstcoddig = acp.pstcoddig"

     prepare pctx15g0004 from l_sql
     declare cctx15g0004 cursor for pctx15g0004

     let l_sql = " select rmesoctrfcod ",
                   " from dpaksocor ",
                  " where pstcoddig = ? "

     prepare pctx15g0005 from l_sql
     declare cctx15g0005 cursor for pctx15g0005

     let l_sql = " select qldgracod ",
                   " from dpaksocor ",
                  " where pstcoddig = ? "

     prepare pctx15g0006 from l_sql
     declare cctx15g0006 cursor for pctx15g0006      
     
     
     
     let l_sql = " select srv.srvcbnhor,                             ",      
                 "        soc.rmesoctrfcod,                          ",      
                 "        sre.socntzcod                              ",      
                 "   from datmsrvre  sre,                            ",      
                 "        datmsrvacp acp,                            ",      
                 "        dpaksocor  soc,                            ",      
                 "        datmservico srv                            ",      
                 " where sre.atdsrvnum = ?                           ",      
                 "    and sre.atdsrvano = ?                          ",      
                 "    and acp.atdsrvnum = sre.atdsrvnum              ",      
                 "    and acp.atdsrvano = sre.atdsrvano              ",      
                 "    and acp.atdsrvnum = srv.atdsrvnum              ",      
                 "    and acp.atdsrvano = srv.atdsrvano              ",      
                 "    and acp.atdsrvseq = (select max(atdsrvseq)     ",      
                 "                           from datmsrvacp         ",      
                 "                          where atdsrvnum = ?      ",      
                 "                            and atdsrvano = ?)     ",      
                 "    and soc.pstcoddig = acp.pstcoddig              "     
     

     prepare pctx15g0007 from l_sql                   
     declare cctx15g0007 cursor for pctx15g0007       

 end function

#-----------------------------------------------------------------------------
 function ctx15g00_srvre(param2)
#-----------------------------------------------------------------------------

 define param2       record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atddat           like datmservico.atddat,
    atdprscod        like datmservico.atdprscod,
    socntzgrpcod     like datksocntz.socntzgrpcod
 end record

 define ws2          record
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atddat           like datmservico.atddat,
    atdprscod        like datmservico.atdprscod,
    succod           like datrservapol.succod,
    ramcod           like datrservapol.ramcod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    crtnum           like datrsrvsau.crtnum,         #PSI 202720
    inidat           date,
    fimdat           date,
    atdetpcod        like datmsrvacp.atdetpcod,
    socntzcod        like datmsrvre.socntzcod,
    socntzgrpcod     like datksocntz.socntzgrpcod,
    sql              char (700),
    nrsrvs           smallint
 end record

 define l_retorno      smallint,               #PSI 202720
        l_mensagem     char(80),               #PSI 202720
        l_tpdocto      char(15),               #PSI 202720
        l_txt_cartao   char(28)                #PSI 202720


 initialize ws2.*  to null
 let l_retorno = null                          #PSI 202720
 let l_mensagem = null                         #PSI 202720
 let l_txt_cartao = null                       #PSI 202720
 let l_tpdocto = null                          #PSI 202720


 let ws2.nrsrvs = 1   # PRIMEIRO SERVICO
 let ws2.inidat = param2.atddat  # Mudanca de regra para desconto de srv so no
 let ws2.fimdat = param2.atddat  # mesmo dia - Orlando 08/07/2008

 #PSI 202720 - inicio
 #identifica tipo documento
 call cts20g11_identifica_tpdocto(param2.atdsrvnum,
                                  param2.atdsrvano)
      returning l_tpdocto

 #se documento APOLICE busca dados da apolice e prepre sql de acordo com
 # numero da apolice
 if l_tpdocto = "APOLICE" then
    #select succod   , ramcod   , aplnumdig   , itmnumdig
    #  into ws2.succod, ws2.ramcod, ws2.aplnumdig, ws2.itmnumdig
    #  from datrservapol
    # where datrservapol.atdsrvnum = param2.atdsrvnum
    #   and datrservapol.atdsrvano = param2.atdsrvano
    call cts20g13_obter_apolice(param2.atdsrvnum,
                                param2.atdsrvano)
         returning l_retorno,
                   l_mensagem,
                   ws2.aplnumdig,
                   ws2.succod,
                   ws2.ramcod,
                   ws2.itmnumdig

    #if ws2.succod    is not null   and
    #   ws2.ramcod    is not null   and
    #   ws2.aplnumdig is not null   and
    #   ws2.itmnumdig is not null   then
    if l_retorno = 1 then
       let ws2.sql = "select datmservico.atddat    , ",
                     "       datmservico.atdsrvnum , ",
                     "       datmservico.atdsrvano , ",
                     "       datmservico.atdprscod   ",
                     "  from datrservapol,datmservico",
                     " where datrservapol.succod     =  ? ",
                     "   and datrservapol.ramcod     =  ? ",
                     "   and datrservapol.aplnumdig  =  ? ",
                     "   and datrservapol.itmnumdig  =  ? ",
                     "   and datrservapol.edsnumref >=  0 ",
                     "   and datmservico.atdsrvnum   =  datrservapol.atdsrvnum ",
                     "   and datmservico.atdsrvano   =  datrservapol.atdsrvano ",
                     "   and datmservico.atdsrvorg   =  9 ",
                     " order by datmservico.atdsrvnum, datmservico.atdsrvano "
    else
       return ws2.nrsrvs
    end if
 else
    if l_tpdocto = "SAUDE" then
       #se documento é SAUDE - busca cartao saude e prepara sql para buscar serviços
       # de RE do cartão saude identificado
       call cts20g10_cartao(1,
                            param2.atdsrvnum,
                            param2.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      ws2.crtnum
       if l_retorno = 1 then
          let ws2.sql = " select datmservico.atddat,    ",
                        "        datmservico.atdsrvnum, ",
                        "        datmservico.atdsrvano, ",
                        "        datmservico.atdprscod  ",
                        " from datrsrvsau, datmservico  ",
                        " where datrsrvsau.crtnum = ?          ",
                        "  and datmservico.atdsrvnum = datrsrvsau.atdsrvnum ",
                        "  and datmservico.atdsrvano = datrsrvsau.atdsrvano ",
                        "  and datmservico.atdsrvorg = 9 ",
                        " order by datmservico.atdsrvnum, datmservico.atdsrvano "
       else
          return ws2.nrsrvs
       end if
    else
       #nao tem documento apolice nem saude
       return ws2.nrsrvs
    end if
 end if
 prepare sel_datmservico  from ws2.sql
 declare c_cts24g00 cursor for sel_datmservico

 #PSI 202720 - fim

 #------------------------------------------------------------------------
 # Ler servicos conforme parametros
 #------------------------------------------------------------------------
 if l_tpdocto = "APOLICE" then
    open c_cts24g00 using ws2.succod   , ws2.ramcod,
                          ws2.aplnumdig, ws2.itmnumdig
 else
    #SAUDE
    open c_cts24g00 using ws2.crtnum
 end if

 foreach c_cts24g00 into  ws2.atddat,
                          ws2.atdsrvnum,
                          ws2.atdsrvano,
                          ws2.atdprscod

    #-------------------------------------
    # Verifica servico
    #-------------------------------------
    if ws2.atdsrvnum = param2.atdsrvnum and
       ws2.atdsrvano = param2.atdsrvano then
       exit foreach
    end if

    #-------------------------------------
    # Verifica intervalo de datas
    #-------------------------------------
    if ws2.atddat >= ws2.inidat and
       ws2.atddat <= ws2.fimdat then
       # OK registro valido
    else
       continue foreach
    end if

    #-------------------------------------
    # Verifica prestador
    #-------------------------------------
    if param2.atdprscod <> ws2.atdprscod then
       continue foreach
    end if

    #-------------------------------------
    # Verifica etapa
    #-------------------------------------
    select atdetpcod
      into ws2.atdetpcod
      from datmsrvacp
     where atdsrvnum = ws2.atdsrvnum
       and atdsrvano = ws2.atdsrvano
       and atdsrvseq = (select max(atdsrvseq)
                          from datmsrvacp
                         where atdsrvnum = ws2.atdsrvnum
                           and atdsrvano = ws2.atdsrvano)

    if ws2.atdetpcod = 5  or       # Etapa Cancelada
       ws2.atdetpcod = 6  then     # Etapa Excluido
       continue foreach
    end if

    #-------------------------------------
    # Verifica natureza servico
    #-------------------------------------
    select datmsrvre.socntzcod
      into ws2.socntzcod
      from datmsrvre
     where datmsrvre.atdsrvnum = ws2.atdsrvnum
       and datmsrvre.atdsrvano = ws2.atdsrvano

    #-------------------------------------
    # Verifica grupo natureza servico
    #-------------------------------------
    select socntzgrpcod
      into ws2.socntzgrpcod
      from datksocntz
     where datksocntz.socntzcod = ws2.socntzcod

    if param2.socntzgrpcod = 1 then  # LINHA BRANCA
       # SERVICOS LINHA BRANCA
       if ws2.socntzgrpcod = 1 then
          # OK registro valido
       else
          continue foreach    # NAO FAZ PARTE L.BRANCA
       end if
    else
       if param2.socntzgrpcod >= 2 and   # BASICO + CHAVEIRO
          param2.socntzgrpcod <= 3 then
          # SERVICOS GERAIS (BASICO + CHAVEIRO)
          if ws2.socntzgrpcod >= 2 and
             ws2.socntzgrpcod <= 3 then
             # OK registro valido
          else
             continue foreach    # NAO FAZ PARTE SRVS.GERAIS
          end if
       else
          continue foreach    # NAO DEFINIDO
       end if
    end if

    let ws2.nrsrvs = ws2.nrsrvs + 1

 end foreach

 return ws2.nrsrvs

end function  #--  ctx15g00_srvre

#--------------------------------------#
 function ctx15g00_verif_adic(l_srvnum,
                              l_srvano)
#--------------------------------------#

     define l_srvnum       like datmservico.atdsrvnum,
            l_srvano       like datmservico.atdsrvano,
            l_atdetpdat    like datmsrvacp.atdetpdat,
            l_atdetphor    like datmsrvacp.atdetphor,
            l_pstcoddig    like datmsrvacp.pstcoddig,
            l_qldgracod    like dpaksocor.qldgracod,
            l_status       integer,
            l_day          integer,
            l_auxdate      like datmservico.srvcbnhor   

     initialize l_atdetpdat,
                l_atdetphor,
                l_status,
                l_day,
                l_pstcoddig to null

     call ctx15g00_prepare()

     # BUSCA HORA E DATA DO ACIONAMENTO.
     #open cctx15g0001 using l_srvnum,
     #                       l_srvano,
     #                       l_srvnum,
     #                       l_srvano
     #
     #fetch cctx15g0001 into l_atdetpdat,
     #                       l_atdetphor,
     #                       l_pstcoddig
                           
                            
     # BUSCA DATA E HORA COMBINADA COM O CLIENTE                       
     display "l_srvnum: ", l_srvnum                                    
     display "l_srvano: ", l_srvano                                    
                                                                       
     open cctx15g0001 using l_srvnum,                                  
                       			l_srvano                                  
                                                                       
     fetch cctx15g0001 into l_auxdate,			                            
                           l_pstcoddig                                 
                                                                        
                                                                        
     let l_atdetpdat = extend(l_auxdate, year to day)                   
     let l_atdetphor = extend(l_auxdate, hour to second)                
                                                                        
     display "l_auxdate: ", l_auxdate                                  
     display "l_atdetpdat: ", l_atdetpdat                              
     display "l_atdetphor: ", l_atdetphor                              
    
                            
                          

     open cctx15g0006 using l_pstcoddig
     fetch cctx15g0006 into l_qldgracod

     # VERIFICA SE O DIA DO SERVICO É UM FERIADO
     open cctx15g0002 using l_atdetpdat
     fetch cctx15g0002 into l_status

     # BUSCA O DIA DA SEMANA. 0 - DOMINGO ... 6 - SABADO
     let l_day = weekday(l_atdetpdat)

     # SE O PRESTADOR FOR PADRAO (QLDGRACOD = 1) E HORARIO DO ACIONAMENTO
     # É SUPERIOR AS 19 HORAS E INFERIOR AS 06:00 OU O DIA DO ACIONAMENTO
     # É UM FERIADO OU DOMINGO.
     if   ((l_atdetphor >= '19:00' or l_atdetphor <= '06:00') or
          l_status = 1 or l_day = 0) and l_qldgracod = 1  then
          return true
     end if

     return false

 end function

#------------------------------------#
 function ctx15g00_vlr_adic(l_srvnum,
                            l_srvano,
                            l_srvrmevlr)
#------------------------------------#

    define l_srvrmevlr    like dbsksrvrmeprc.srvrmevlr,
           l_rmesoctrfcod like dpaksocor.rmesoctrfcod,
           l_socntzcod    like datmsrvre.socntzcod,
           l_atdetpdat    like datmsrvacp.atdetpdat,
           l_srvnum       like datmservico.atdsrvnum,
           l_srvano       like datmservico.atdsrvano,
           l_srvrmedifvlr like dbsksrvrmeprc.srvrmedifvlr,
           l_vlrprm       like dbsksrvrmeprc.srvrmevlr,
           l_errcod       smallint,
           l_auxdate      like datmservico.srvcbnhor                
	   
    call ctx15g00_prepare()

    # BUSCA NATUREZA ORIGEM E DATA DO ACIONAMENTO
    #open cctx15g0004 using l_srvnum,
    #                       l_srvano,
    #                       l_srvnum,
    #                       l_srvano
    #
    #fetch cctx15g0004 into l_atdetpdat,
    #                       l_rmesoctrfcod,
    #                       l_socntzcod       
    
    
    #BUSCA NATUREZA ORIGEM E DATA COMBINADA COM O CLIENTE
    open cctx15g0007 using l_srvnum,         
                           l_srvano,         
                           l_srvnum,         
                           l_srvano          
                                             
    fetch cctx15g0007 into l_auxdate,      
                           l_rmesoctrfcod,   
                           l_socntzcod    
                           
   let l_atdetpdat = extend(l_auxdate, year to day)      
    

    # BUSCA O VALOR DA ADICIONAL
    open cctx15g0003 using l_rmesoctrfcod,
                           l_socntzcod,
                           l_atdetpdat,
                           l_atdetpdat
    fetch cctx15g0003 into l_srvrmedifvlr

    # SE NAO ACHAR ADICIONAL CADASTRADA RETORNA O VALOR PADRAO.
    if  sqlca.sqlcode = notfound or
        l_srvrmedifvlr = 0.00 then
        display 'Adicional Origem: ', l_rmesoctrfcod clipped, " Natureza: ", l_socntzcod clipped, " nao cadastrada."
        let l_srvrmedifvlr = l_srvrmevlr
    else
        if  sqlca.sqlcode <> 0 then
            display 'ERRO ctx15g00_vlr_adic() : ', sqlca.sqlcode
            let l_srvrmedifvlr = l_srvrmevlr
        else
            #let l_srvrmedifvlr = l_srvrmedifvlr + l_srvrmevlr

            #CT: 570036
            let l_srvrmedifvlr = l_srvrmedifvlr
        end if
    end if

    call ctd00g00_vlrprmpgm(l_srvnum, l_srvano, "ADC")
         returning l_vlrprm,
                   l_errcod

     let l_srvrmedifvlr = ctd00g00_compvlr(l_srvrmedifvlr, l_vlrprm)

     return l_srvrmedifvlr

 end function