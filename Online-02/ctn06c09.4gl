#############################################################################
# Nome do Modulo: CTN06C09                                        Wagner    #
# Consulta Prestador por lat/long                                 Set/2000  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 22/08/2001  PSI 136220   Ruiz         Adaptacao para servicos acionado via#
#                                       internet.                           #
#---------------------------------------------------------------------------#
# 19/03/2002  PSI 15000-2  Marcus       Consulta de prestadores Porto Socor #
#                                       ro por coordenadas (Mapa)           #
#---------------------------------------------------------------------------#
#                       * * * A L T E R A C A O * * *                       #
# ......................................................................... #
# Data       Autor Fabrica    Origem    Alteracao                           #
# ---------- -------------  ----------- ------------------------------------#
# 27/01/2004 Sonia Sasaki   PSI 177903  Inclusao F6 e execucao da funcao    #
#                           OSF 31631   cta11m00 (Motivos de recusa).       #
#                                                                           #
# 24/08/2005 James, Meta    PSI 192015  Chamar funcao para Locais Condicoes #
#                                       do veiculo (ctc61m02)               #
# 17/11/2006 Ligia Mattge   PSI 205206  ciaempcod                           #
# 09/03/2010 Adriano Santos PSI 242853  Substituir relacionamento GRP NTZ   #
#                                       com PST por NTZ                     #
# 27/10/2011 Celso Yamahaki CT201119385 Rebloqueio de laudo quando o prest. #
#                                       Recusar um servico                  #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctn06c09_prep smallint,
         m_atdsrvorg_aux  like datmservico.atdsrvorg

#-------------------------#
function ctn06c09_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select socntzdes ",
                " from datksocntz ",
               " where socntzcod = ? "

  prepare p_ctn06c09_001 from l_sql
  declare c_ctn06c09_001 cursor for p_ctn06c09_001

  let l_sql = " select  dpaksocor.pstcoddig, qldgracod ",
              " from dpaksocor, dpatserv ",
              " where mpacidcod = ? ",
              " and dpaksocor.pstcoddig > 0 ",
              " and dpaksocor.prssitcod = 'A' ",     # SOMENTE ATIVOS
              " and dpatserv.pstcoddig  = dpaksocor.pstcoddig ",
              " and dpatserv.pstsrvtip  = ? "
  prepare p_ctn06c09_002 from l_sql
  declare c_ctn06c09_002 cursor for p_ctn06c09_002

  #let l_sql = " select  dpaksocor.pstcoddig, qldgracod ",
  #            " from dpaksocor, dparpstgrpntz ",
  #            " where mpacidcod = ? ",
  #            " and dpaksocor.pstcoddig > 0 ",
  #            " and dpaksocor.prssitcod = 'A' ",     # SOMENTE ATIVOS
  #            " and dparpstgrpntz.pstcoddig = dpaksocor.pstcoddig ",
  #            " and dparpstgrpntz.socntzgrpcod = ? "
  #
  #prepare pctn06c09003 from l_sql
  #declare cctn06c09003 cursor for pctn06c09003
  let l_sql = " select  dpaksocor.pstcoddig, qldgracod ",
              " from dpaksocor, dparpstntz ",
              " where mpacidcod = ? ",
              " and dpaksocor.pstcoddig > 0 ",
              " and dpaksocor.prssitcod = 'A' ",     # SOMENTE ATIVOS
              " and dparpstntz.pstcoddig = dpaksocor.pstcoddig ",
              " and dparpstntz.socntzcod = ? "

  prepare pctn06c09003 from l_sql
  declare cctn06c09003 cursor for pctn06c09003

  let l_sql = " select  dpaksocor.pstcoddig, qldgracod ",
              " from dpaksocor, datrassprs ",
              " where mpacidcod = ? ",
              " and dpaksocor.pstcoddig  > 0 ",
              " and dpaksocor.prssitcod  = 'A' ",     # SOMENTE ATIVOS
              " and datrassprs.pstcoddig = dpaksocor.pstcoddig ",
              " and datrassprs.asitipcod = ? "

  prepare pctn06c09007 from l_sql
  declare cctn06c09007 cursor for pctn06c09007
  
  let l_sql = "update datmservico    ",
              "   set c24opemat =  ? ",
              "   ,c24opeempcod =  ? ",
              " where atdsrvnum =  ? ",
              "   and atdsrvano =  ? "
  prepare pctn06c09008 from l_sql
  
  
  

  let m_ctn06c09_prep = true

end function

#--------------------------------------------#
function ctn06c09_verif_origem_re(l_socntzcod)
#--------------------------------------------#

  define l_socntzcod like datksocntz.socntzcod,
         l_socntzdes like datksocntz.socntzdes


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socntzdes  =  null

  if m_ctn06c09_prep is null or
     m_ctn06c09_prep <> true then
     call ctn06c09_prepare()
  end if

  let l_socntzdes = null

  open c_ctn06c09_001 using l_socntzcod

  whenever error continue
  fetch c_ctn06c09_001 into l_socntzdes
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then

        error "Tipo de servico nao cadastrado para origem RE !"

        call cts12g00(1,"","","","","","","")
             returning l_socntzcod, l_socntzdes

          if l_socntzcod is null or
             l_socntzcod =  " "  then
             error "Tipo de servico obrigatorio !"
             let l_socntzcod = null
             let l_socntzdes = null
          else
              open c_ctn06c09_001 using l_socntzcod

              whenever error continue
              fetch c_ctn06c09_001 into l_socntzdes
              whenever error stop

              if sqlca.sqlcode <> 0 then
                 if sqlca.sqlcode <> notfound then
                    error "Erro SELECT c_ctn06c09_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                    error "CTN06C09/ctn06c09() ", l_socntzcod sleep 3
                    let l_socntzcod = null
                    let l_socntzdes = null
                 end if
              end if

          end if

     else
        error "Erro SELECT c_ctn06c09_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "CTN06C09/ctn06c09() ", l_socntzcod sleep 3
        let l_socntzcod = null
        let l_socntzdes = null
     end if
  end if

  close c_ctn06c09_001

  return l_socntzcod, l_socntzdes

end function

#------------------------------------------------------------
 function ctn06c09(param)
#------------------------------------------------------------

 define param         record
    tipo              dec (1,0),
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    lclltt            like datmlcl.lclltt,
    lcllgt            like datmlcl.lcllgt,
    ufdcod            like datmlcl.ufdcod,
    cidnom            like datmlcl.cidnom
 end record

 define a_ctn06c09    array[50] of record
    nomgrr            like dpaksocor.nomgrr   ,
    pstcoddig         like dpaksocor.pstcoddig,
    situacao          char (10)             ,
    endlgd            like dpaksocor.endlgd   ,
    endbrr            like dpaksocor.endbrr   ,
    endcid            like dpaksocor.endcid   ,
    endufd            like dpaksocor.endufd   ,
    endcep            like dpaksocor.endcep   ,
    endcepcmp         like dpaksocor.endcepcmp,
    dddcod            like dpaksocor.dddcod   ,
    teltxt            like dpaksocor.teltxt   ,
    dstqtd            decimal (8,4),
    horsegsexinc      like dpaksocor.horsegsexinc,
    horsegsexfnl      like dpaksocor.horsegsexfnl,
    horsabinc         like dpaksocor.horsabinc,
    horsabfnl         like dpaksocor.horsabfnl,
    hordominc         like dpaksocor.hordominc,
    hordomfnl         like dpaksocor.hordomfnl,
    pstobs            like dpaksocor.pstobs   ,
    qualidade         char (12)               ,
    tabela            char (06)
 end record

 define ws            record
    pstsrvtip         char (03),
    pstsrvdes         like dpckserv.pstsrvdes,
    ciaempcod         like gabkemp.empcod,
    empnom            like gabkemp.empnom,
    inform1           char (13),
    inform2           char (42),
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    criatmp           smallint,
    pstcoddig         like dpaksocor.pstcoddig,
    vlrtabflg         like dpaksocor.vlrtabflg,
    qldgracod         like dpaksocor.qldgracod,
    dstqtd            dec(8,4),
    intsrvrcbflg      like dpaksocor.intsrvrcbflg,
    confirma          char(1)
 end record

 define arr_aux         smallint
       ,l_srvrcumtvcod  like datmsrvacp.srvrcumtvcod
       ,l_atdsrvorg     like datmservico.atdsrvorg
       ,l_tmp_flg       smallint
       ,l_socntzgrpcod  like datksocntzgrp.socntzgrpcod
       ,l_socntzgrpdes  like datksocntzgrp.socntzgrpdes
       ,l_resultado     smallint
       ,l_mensagem      char(60)
       ,l_socntzcod     like datksocntz.socntzcod
       ,l_socntzdes     like datksocntz.socntzdes
 define lr_ret       record
        resultado    smallint,  # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
        mensagem     char(80),
        asitipdes    like datkasitip.asitipdes
 end record

 #-----------------------------------------------------------------
 # Verifica parametros informados
 #------------------------------------------------------------------

 define  w_pf1            integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     arr_aux  =  null
        let     l_srvrcumtvcod  =  null
        let     l_atdsrvorg  =  null
        let     l_tmp_flg  =  null
        let     l_socntzgrpcod  =  null
        let     l_socntzgrpdes  =  null
        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     w_pf1  =  null
        let     l_socntzcod = null
        let     l_socntzdes = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  50
                initialize  a_ctn06c09[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 if m_ctn06c09_prep is null or
    m_ctn06c09_prep <> true then
    call ctn06c09_prepare()
 end if

 initialize a_ctn06c09 to null

 initialize ws.*,
            lr_ret.* to null

 let m_atdsrvorg_aux = null

  if param.tipo = 2 then
    if param.atdsrvnum  is null   or
       param.atdsrvano  is null   then
       error " Numero do servico nao informado, AVISE INFORMATICA!"
       initialize ws.pstcoddig to null
       return ws.pstcoddig
    end if
  end if

#if param.tipo = 2 then
#    error g_documento.atdsrvorg
 #   select atdsrvorg
 #     into ws.atdsrvorg
 #     from datmservico
 #    where atdsrvnum  =  param.atdsrvnum
 #      and atdsrvano  =  param.atdsrvano

 #   if sqlca.sqlcode  =  notfound   then
 #      error " Servico nao encontrado, AVISE INFORMATICA!"
 #      initialize ws.pstcoddig to null
 #      return ws.pstcoddig
 #   end if
#end if

 #------------------------------------------------------------------
 # Verifica tipo do servico/tipo da assistencia
 #------------------------------------------------------------------
# if ws.atdsrvorg  <>  13  and   # Sinistro RE
#    ws.atdsrvorg  <>  4   and   # Remocao
#    ws.atdsrvorg  <>  6   and   # DAF
#    ws.atdsrvorg  <>  1   and   # Socorro
#    ws.atdsrvorg  <>  10  and   # Vistoria
#    ws.atdsrvorg  <>  5   and   # RPT
#    ws.atdsrvorg  <>  7   and   # Replace
#    ws.atdsrvorg  <> 17   and   # Replace s/ docto
#    ws.atdsrvorg  <>  9   and   # Socorro RE
#    ws.atdsrvorg  <>  2   then  # Transporte
#    error " Tipo de servico nao utiliza localizacao por GPS!"
#    initialize ws.pstcoddig to null
#    return ws.pstcoddig
# else
#    if ws.atdsrvorg  =  2   and
#       d_cts00m20.asitipcod  <>  5    then
#       error " Tipo de assistencia nao utiliza localizacao por GPS!"
#       initialize ws.pstcoddig to null
#       return ws.pstcoddig
#    end if
# end if

 #------------------------------------------------------------------
 # Verifica se servico possui latitude/longitude
 #------------------------------------------------------------------
# select cidnom, ufdcod, lclltt, lcllgt
#   into ws.cidnom, ws.ufdcod, ws.lclltt_srv, ws.lcllgt_srv
#   from datmlcl
#  where atdsrvnum  =  param.atdsrvnum
#    and atdsrvano  =  param.atdsrvano
#    and c24endtip  =  1

# if sqlca.sqlcode  =  notfound   then
#    error " Local da ocorrencia nao encontrado, AVISE INFORMATICA!"
#    initialize ws.pstcoddig to null
#    return ws.pstcoddig
# end if

  if param.lclltt  is null   or
     param.lcllgt  is null   then
     error " Servico nao possui localizacao por latitude/longitude!"
     initialize ws.pstcoddig to null
     return ws.pstcoddig
  end if

  open window ctn06c09 at 03,02 with form "ctn06c09"

  let ws.inform1 = g_documento.atdsrvorg    using "&&","/",
                   param.atdsrvnum using "&&&&&&&","-",
                   param.atdsrvano using "&&"
  let ws.inform2 = param.cidnom clipped , " - ", param.ufdcod

  if param.atdsrvnum is not null then
     call cts10g06_dados_servicos(10, param.atdsrvnum, param.atdsrvano)
          returning l_resultado, l_mensagem, ws.ciaempcod

     call cty14g00_empresa(1, ws.ciaempcod)
          returning l_resultado, l_mensagem,  ws.empnom

     if  g_documento.atdsrvorg = 18 then
         whenever error continue
            select asitipcod into ws.pstsrvtip
              from datmservico
             where atdsrvnum = param.atdsrvnum
               and atdsrvano = param.atdsrvano
         whenever error stop
         if  sqlca.sqlcode = 0 then
             call ctn25c00_descricao(ws.pstsrvtip)
                 returning lr_ret.*
             let ws.pstsrvdes = lr_ret.asitipdes
         else
             let ws.pstsrvtip = null
             let ws.pstsrvdes = null
         end if

         display by name ws.pstsrvtip
         display by name ws.pstsrvdes

     end if

     display by name ws.ciaempcod attribute (reverse)
     display by name ws.empnom attribute (reverse)

  end if

  if param.tipo = 2 then
     display by name ws.inform1
  end if
  display by name ws.inform2

  #call cts47g00_verif_grp_ntz(param.atdsrvnum,
  #                            param.atdsrvano)
  #     returning ws.pstsrvtip
  if  g_documento.atdsrvorg = 9 or g_documento.atdsrvorg = 13 then
      whenever error continue
        select socntzcod
          into ws.pstsrvtip
          from datmsrvre
         where atdsrvnum = param.atdsrvnum
           and atdsrvano = param.atdsrvano
      whenever error continue
      if  ws.pstsrvtip is not null and ws.pstsrvtip <> " " then
          call ctx24g01_descricao(ws.pstsrvtip)
               returning l_resultado, l_mensagem, ws.pstsrvdes
          display ws.pstsrvdes to pstsrvdes
      end if
  end if
  input by name ws.pstsrvtip, ws.ciaempcod without defaults

     before field pstsrvtip
        display by name ws.pstsrvtip attribute (reverse)

     after  field pstsrvtip
        display by name ws.pstsrvtip

        let m_atdsrvorg_aux = null
        let ws.pstsrvdes    = null

        let m_atdsrvorg_aux = g_documento.atdsrvorg

        if m_atdsrvorg_aux is null or
           m_atdsrvorg_aux = 0 then
           if cts08g01("C",
                       "S",
                       "",
                       "DESEJA CONSULTAR SOMENTE",
                       "PRESTADORES DE RE ?","") = "S" then
              let m_atdsrvorg_aux = 9
           else
              let m_atdsrvorg_aux = 0
           end if
        end if

        if m_atdsrvorg_aux = 9 then

           if ws.pstsrvtip is null then
              #call ctx24g01_popup_grupo() #psi195138
              call ctx24g01_popup_natureza() #psi242853
                   returning l_resultado, ws.pstsrvtip

              if ws.pstsrvtip is null or
                 ws.pstsrvtip = " " then
                 next field pstsrvtip
              end if
           end if

           call ctx24g01_descricao(ws.pstsrvtip)
                returning l_resultado, l_mensagem, ws.pstsrvdes

           if l_resultado <> 1 then
              error l_mensagem
              next field pstsrvtip
           end if

        else

           #Se origem 18 entao busca dados como tipo de assistencia
           if  m_atdsrvorg_aux = 18 then
               call ctn25c00_descricao(ws.pstsrvtip)
                   returning lr_ret.*
               if  lr_ret.resultado = 2 then
                   error "Tipo de assistencia nao cadastrada!"

                   call ctn25c00(18) returning ws.pstsrvtip
                   if  ws.pstsrvtip is null or
                       ws.pstsrvtip = " " then
                       error "Tipo de assistencia e obrigatorio!"
                       next field pstsrvtip
                   end if

                   call ctn25c00_descricao(ws.pstsrvtip)
                       returning lr_ret.*
               end if
               let ws.pstsrvdes = lr_ret.asitipdes
           else
               select pstsrvdes into ws.pstsrvdes
                 from dpckserv
                where pstsrvtip  =  ws.pstsrvtip
               if sqlca.sqlcode = notfound then
                  error "Tipo de servico nao cadastrado!"

                  call ctn06c03() returning ws.pstsrvtip,
                                            ws.pstsrvdes

                  if ws.pstsrvtip is null or
                     ws.pstsrvtip =  " "  then
                     error "Tipo de servico e' obrigatorio!"
                     next field pstsrvtip
                  end if
               end if
           end if

        end if

        display ws.pstsrvtip to pstsrvtip
        display ws.pstsrvdes to pstsrvdes

     before field ciaempcod
                display by name ws.ciaempcod attribute (reverse)

     after  field ciaempcod
            display by name ws.ciaempcod attribute (reverse)

            if ws.ciaempcod is null then
               call cty14g00_popup_empresa()
                    returning l_resultado, ws.ciaempcod,
                              ws.empnom
            else

               #if ws.ciaempcod <> 1 and
               #   ws.ciaempcod <> 35 and
               #   ws.ciaempcod <> 27 and
               #   ws.ciaempcod <> 40 then
               #   error "Informe a empresa: 1-Porto, 35-Azul ou 40-PortoSeg"
               #   next field ciaempcod
               #end if

               call cty14g00_empresa(1, ws.ciaempcod)
                    returning l_resultado, l_mensagem,  ws.empnom

               if l_resultado <> 1 then
                  error l_mensagem
                  next field ciaempcod
               end if
            end if

            display by name ws.ciaempcod attribute (reverse)
            display by name ws.empnom attribute (reverse)

  end input

  if int_flag then
     let int_flag = false
     close window ctn06c09
     return ws.pstcoddig
  end if

  message " Aguarde, pesquisando Prestadores ... " attribute(reverse)

  if ws.criatmp is null or
     ws.criatmp  = 0    then
     call ctn06c09_criatmp(param.lclltt,
                           param.lcllgt,
                           ws.pstsrvtip)
     let ws.criatmp = 1
  end if

  declare cctn06c09004 cursor with hold for
   select dstqtd, qldgracod, pstcoddig
     from tmp_prest
    where dstqtd    is not null
      and qldgracod <> 8
    order by dstqtd, qldgracod

  let arr_aux = 1

  foreach cctn06c09004 into a_ctn06c09[arr_aux].dstqtd,
                          ws.qldgracod,
                          a_ctn06c09[arr_aux].pstcoddig

     if ws.ciaempcod is not null then
        call ctd03g00_valida_emppst(ws.ciaempcod,
                                    a_ctn06c09[arr_aux].pstcoddig)
             returning l_resultado, l_mensagem

        if l_resultado <> 1 then
           continue foreach
        end if
     end if

     select dpaksocor.nomgrr      , dpaksocor.endlgd      ,
            dpaksocor.endbrr      , dpaksocor.endcid      ,
            dpaksocor.endufd      , dpaksocor.endcep      ,
            dpaksocor.endcepcmp   , dpaksocor.dddcod      ,
            dpaksocor.teltxt      , dpaksocor.horsegsexinc,
            dpaksocor.horsegsexfnl, dpaksocor.horsabinc   ,
            dpaksocor.horsabfnl   , dpaksocor.hordominc   ,
            dpaksocor.hordomfnl   , dpaksocor.pstobs      ,
            dpaksocor.vlrtabflg   , dpaksocor.intsrvrcbflg
       into a_ctn06c09[arr_aux].nomgrr      ,
            a_ctn06c09[arr_aux].endlgd      ,
            a_ctn06c09[arr_aux].endbrr      ,
            a_ctn06c09[arr_aux].endcid      ,
            a_ctn06c09[arr_aux].endufd      ,
            a_ctn06c09[arr_aux].endcep      ,
            a_ctn06c09[arr_aux].endcepcmp   ,
            a_ctn06c09[arr_aux].dddcod      ,
            a_ctn06c09[arr_aux].teltxt      ,
            a_ctn06c09[arr_aux].horsegsexinc,
            a_ctn06c09[arr_aux].horsegsexfnl,
            a_ctn06c09[arr_aux].horsabinc   ,
            a_ctn06c09[arr_aux].horsabfnl   ,
            a_ctn06c09[arr_aux].hordominc   ,
            a_ctn06c09[arr_aux].hordomfnl   ,
            a_ctn06c09[arr_aux].pstobs      ,
            ws.vlrtabflg                    ,
            ws.intsrvrcbflg
       from dpaksocor
      where dpaksocor.pstcoddig = a_ctn06c09[arr_aux].pstcoddig


      if ws.vlrtabflg = "S"   then
         let a_ctn06c09[arr_aux].tabela = "TABELA"
      end if
      if ws.intsrvrcbflg = "1" then
         let a_ctn06c09[arr_aux].situacao = "INTERNET"
      end if

      select cpodes
        into a_ctn06c09[arr_aux].qualidade
        from iddkdominio
       where iddkdominio.cponom = "qldgracod"
         and iddkdominio.cpocod = ws.qldgracod

      let arr_aux = arr_aux + 1

      if arr_aux > 50  then
         exit foreach
      end if

  end foreach

  message "(F17)Abandona (F5)Cond.Veiculo (F6)Recusa (F8)Seleciona (F9)Servicos prestador"

  if arr_aux  >  1  then
     call set_count(arr_aux - 1)
     display array a_ctn06c09 to s_ctn06c09.*
       on key (interrupt,control-m)
          exit display

       ## Implementar Consulta de Locais e Condicoes do Veiculo
       on key (f5)
          let arr_aux = arr_curr()
          call ctc61m02(param.atdsrvnum,param.atdsrvano,"A")
          let l_tmp_flg = ctc61m02_criatmp(2,
                                           param.atdsrvnum,
                                           param.atdsrvano)
          if l_tmp_flg = 1 then
             error "Problemas com temporaria ! <Avise a Informatica>."
          end if

       on key (F6)
          let  arr_aux = arr_curr()

          whenever error continue
             select atdsrvorg into l_atdsrvorg
               from datmservico
              where atdsrvnum = param.atdsrvnum
                and atdsrvano = param.atdsrvano
          whenever error stop

          if sqlca.sqlcode = 0 then
             call cta11m00 ( l_atdsrvorg
                            ,param.atdsrvnum
                            ,param.atdsrvano
                            ,a_ctn06c09[arr_aux].pstcoddig
                            ,"S" )
                  returning l_srvrcumtvcod
             #bloqueia o serviço novamente pois o cta11m00 desbloqueia
             if m_ctn06c09_prep is null or
                m_ctn06c09_prep <> true then
                   call ctn06c09_prepare()
             end if
             
             execute pctn06c09008 using g_issk.funmat,
                                        g_issk.empcod,
                                        param.atdsrvnum,
                                        param.atdsrvano
             if sqlca.sqlcode = 0 then
                 call cts00g07_apos_servbloqueia(param.atdsrvnum,param.atdsrvano)
             end if
             
             
          else
             if sqlca.sqlcode < 0 then
                error "Erro ", sqlca.sqlcode using "<<<<<&",
                      " na selecao da tabela datmservico."
             end if
          end if

       on key (F8)
          let  arr_aux = arr_curr()
          let ws.pstcoddig = a_ctn06c09[arr_aux].pstcoddig

          call cts08g01("A","S","PRESTADOR SELECIONADO",
                        a_ctn06c09[arr_aux].nomgrr,"ESTA CORRETO ?","")
          returning ws.confirma

          if ws.confirma = "S" then
             let int_flag =  true
#            error "Prestador selecionado !!"
             exit display
          end if

       on key (F9)
          let  arr_aux = arr_curr()
          if m_atdsrvorg_aux = 9 then
             #call ctn06c10(a_ctn06c09[arr_aux].pstcoddig)
             #     returning l_socntzgrpcod, l_socntzgrpdes
             call ctn06c11(a_ctn06c09[arr_aux].pstcoddig)
                  returning l_socntzcod, l_socntzdes
          else
             call ctn06c08(a_ctn06c09[arr_aux].pstcoddig)
          end if
    end display
  else
    error "Prestador(es) nao localizado(s) para esta regiao!"
    initialize ws.pstcoddig to null
  end if

  let int_flag = false
  if ws.criatmp = 1 then
     drop table tmp_mpacid
    #drop table tmp_socor
     drop table tmp_prest
  end if
  close window ctn06c09
  return ws.pstcoddig

end function  #  ctn06c09


#------------------------------------------------------------------
 function ctn06c09_criatmp(par)
#------------------------------------------------------------------

 define par           record
    lclltt_srv        like datmlcl.lclltt,
    lcllgt_srv        like datmlcl.lcllgt,
    pstsrvtip         char (03)
 end record

 define ws            record
    qldgracod         like dpaksocor.qldgracod,
    pstcoddig         like dpaksocor.pstcoddig,
    mpacidcod         like datkmpacid.mpacidcod,
    count             smallint,
    dstqtd            decimal(8,4),
    lclltt_prs        like datmlcl.lclltt,
    lcllgt_prs        like datmlcl.lcllgt
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

        initialize  ws.*  to  null

 create temp table tmp_mpacid
    (dstqtd       dec(8,4),
     mpacidcod    dec(6,0)) with no log

 declare c_ctn06c09_003 cursor with hold for
  select mpacidcod, lclltt, lcllgt
    from datkmpacid
   where mpacidcod > 0

  foreach c_ctn06c09_003 into ws.mpacidcod, ws.lclltt_prs, ws.lcllgt_prs

    if  par.lclltt_srv -2 <= ws.lclltt_prs and
        par.lclltt_srv +2 >= ws.lclltt_prs and
        par.lcllgt_srv -2 <= ws.lcllgt_prs and
        par.lcllgt_srv +2 >= ws.lcllgt_prs then

        #------------------------------------------------------------
        # Calcula distancia entre local do servico e cidade prestador
        #------------------------------------------------------------
        initialize ws.dstqtd  to null
        call cts18g00(par.lclltt_srv, par.lcllgt_srv,
                       ws.lclltt_prs,  ws.lcllgt_prs)
             returning ws.dstqtd

        insert into tmp_mpacid values (ws.dstqtd, ws.mpacidcod)

     end if

  end foreach

 create index  idx_tmpmpacod on tmp_mpacid (dstqtd)

------------------------------------------------

 create temp table tmp_prest
    (dstqtd       dec(8,4),
     qldgracod    smallint,
     pstcoddig    dec(6,0)) with no log

 declare c_ctn06c09_004 cursor for
  select dstqtd, mpacidcod
   from tmp_mpacid
 order by 1

 let ws.count = 0

 foreach c_ctn06c09_004 into ws.dstqtd, ws.mpacidcod

   if m_atdsrvorg_aux = 9 then
      open cctn06c09003 using ws.mpacidcod, par.pstsrvtip
      foreach cctn06c09003 into ws.pstcoddig , ws.qldgracod
         insert into tmp_prest
                     values (ws.dstqtd, ws.qldgracod, ws.pstcoddig)
         let ws.count = ws.count + 1
      end foreach
   else
      if m_atdsrvorg_aux = 18 then
         open cctn06c09007 using ws.mpacidcod , par.pstsrvtip
         foreach cctn06c09007 into ws.pstcoddig , ws.qldgracod
            insert into tmp_prest
                        values (ws.dstqtd, ws.qldgracod, ws.pstcoddig)
            let ws.count = ws.count + 1
         end foreach
      else
         open c_ctn06c09_002 using ws.mpacidcod , par.pstsrvtip
         foreach c_ctn06c09_002 into ws.pstcoddig , ws.qldgracod
            insert into tmp_prest
                        values (ws.dstqtd, ws.qldgracod, ws.pstcoddig)
            let ws.count = ws.count + 1
         end foreach
      end if
   end if

   if ws.count > 50 then
      exit foreach
   end if

 end foreach

 create index  idx_tmpprest on tmp_prest (dstqtd, qldgracod)

end function
