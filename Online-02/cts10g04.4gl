###############################################################################
# Nome do Modulo: CTS10G04                                           Marcus   #
#                                                                             #
# Funcoes genericas de acesso a tabela de Etapas do Servico          Mai/2001 #
#-----------------------------------------------------------------------------#
# 28/03/2000  CHAMADO    Raji        Gravar hora e data do banco (antes maq.  #
#                                    aplicacao)                               #
# 04/02/2004  OSF31682   Mariana,Fsw Descomentar funcao de sequencia maxima   #
#                                    da etapa                                 #
###############################################################################
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
# 01/09/2004 Robson, Meta      PSI186406  Alterada cts10g04_max_seq para      #
#                                         usar condicao atdetpcod.            #
#                                         Alterada cts10g04_ultimo_pst para   #
#                                         obter inf da tabela mov de etapas.  #
#                                                                             #
# 08/04/2005 Vinicius, Meta    PSI189790  Funcao cts10g04_atualiza_dados()    #
#                                         incluida para atualizar informacoes #
#                                         na tabela de acompanhamento do      #
#                                         servico(datmsrvacp)                 #
# 03/07/2007 Burini            Isabel     Buscar o ultimo prestador da ultima #
#                                         sequencia de retorno, ao inves de   #
#                                         buscar o prestador da origem        #
#---------------------------------------------------------------------------- #
# 16/07/2008 PSI 214558                   Criacao metodo                      #
#                                         cts10g04_tempo_distancia()          #
#---------------------------------------------------------------------------- #
# 22/03/2010 Beatriz Araujo    PSI 219444 Notificar cancelamento da serviço   #
#                                         para aplólice RE                    #
#---------------------------------------------------------------------------- #
# 20/06/2013 Kelly Lima        PSI 11843  Inclusão da função de inserir etapa #
#                                         passando o motivo de cancelamento   #
############################################################################# #
# 23/07/2014 Brunno Silva     CT: 140718581 Laco de repeticao para incrementar#
#                                           sequencial da PK.                 #
###############################################################################

#globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/glseg.4gl"

  define m_cts10g04_prep smallint

#-------------------------#
function cts10g04_prepare()
#-------------------------#

  define l_sql char(600)

  #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql  =  null

  let l_sql = ' select atdetpcod '
                   ,' ,pstcoddig '
                   ,' ,srrcoddig '
                   ,' ,socvclcod '
               ,' from datmsrvacp '
              ,' where atdsrvnum = ? '
                ,' and atdsrvano = ? '
                ,' and atdsrvseq = ? '

  prepare p_cts10g04_001 from l_sql
  declare c_cts10g04_001 cursor for p_cts10g04_001

  let l_sql = ' update datmsrvacp '
              ,'   set srvrcumtvcod = ? '
              ,' where atdsrvnum    = ? '
              ,'   and atdsrvano    = ? '
              ,'   and atdsrvseq    = ? '

  prepare p_cts10g04_002 from l_sql

  let l_sql = ' update datmsrvacp '
              ,'   set envtipcod = ? '
              ,' where atdsrvnum    = ? '
              ,'   and atdsrvano    = ? '
              ,'   and atdsrvseq    = ? '

  prepare p_cts10g04_003 from l_sql

  let l_sql = " select atdetpcod ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) ",
                                    " from datmsrvacp ",
                                   " where atdsrvnum = ? ",
                                     " and atdsrvano = ?) "
  prepare p_cts10g04_004 from l_sql
  declare c_cts10g04_002 cursor for p_cts10g04_004

  let l_sql = " select max(atdsrvseq) ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts10g04_005 from l_sql
  declare c_cts10g04_003 cursor for p_cts10g04_005

  #Seleciona o ultimo registro de servico
  #relacionado ao servico original
  let l_sql = "select acp.atdsrvnum,",
                    " acp.atdsrvano,",
                    " acp.pstcoddig,",
                    " acp.srrcoddig,",
                    " acp.socvclcod",
               " from datmsrvre re, datmsrvacp acp",
              " where re.atdorgsrvnum = ?",
                " and re.atdorgsrvano = ?",
                " and acp.atdsrvnum = re.atdsrvnum",
                " and acp.atdsrvano = re.atdsrvano",
                " and acp.atdetpcod in (3,10)",
                " and atdsrvseq = (select max(atdsrvseq)",
                                   " from datmsrvacp acpmax",
                                  " where acpmax.atdsrvnum = acp.atdsrvnum",
                                    " and acpmax.atdsrvano = acp.atdsrvano)",
                " and ((re.atdsrvnum < ? and re.atdsrvano = ?) or (re.atdsrvano < ?))",
              " order by acp.atdsrvano desc, acp.atdsrvnum desc"

  prepare p_cts10g04_006 from l_sql
  declare c_cts10g04_004 cursor for p_cts10g04_006


   #No caso de nao encontrar servico anterior
   #busca o servico original
   let l_sql =
        "select acp.atdsrvnum,",
              " acp.atdsrvano,",
              " acp.pstcoddig,",
              " acp.srrcoddig,",
              " acp.socvclcod",
         " from datmsrvacp acp",
        " where acp.atdsrvnum = ?",
          " and acp.atdsrvano = ?",
          " and acp.atdetpcod in (3,10)",
          " and atdsrvseq = (select max(atdsrvseq)",
                             " from datmsrvacp acpmax",
                            " where acpmax.atdsrvnum = acp.atdsrvnum",
                              " and acpmax.atdsrvano = acp.atdsrvano)"

  prepare p_cts10g04_007 from l_sql
  declare c_cts10g04_005 cursor for p_cts10g04_007

  let l_sql = " insert into datmsrvacp (atdsrvnum, ",
                                      " atdsrvano, ",
                                      " atdsrvseq, ",
                                      " atdetpcod, ",
                                      " atdetpdat, ",
                                      " atdetphor, ",
                                      " empcod, ",
                                      " funmat, ",
                                      " pstcoddig, ",
                                      " srrcoddig, ",
                                      " socvclcod, ",
                                      " c24nomctt, ",
                                      #PSI 2013-11843 - Pomar (Cancelamento) - Inicio 
                                      " canmtvcod) ", #Código Motivo do Cancelamento
                               " values(?,?,?,?,?,?,?,?,?,?,?,?,?) "
                                      #PSI 2013-11843 - Pomar (Cancelamento) - Fim 

  prepare p_cts10g04_008 from l_sql

  let l_sql = " select atdorgsrvnum, ",
                     " atdorgsrvano, ",
                     " retprsmsmflg ",
                " from datmsrvre ",
               " where datmsrvre.atdsrvnum = ? ",
                 " and datmsrvre.atdsrvano = ? "

  prepare p_cts10g04_009 from l_sql
  declare c_cts10g04_006 cursor for p_cts10g04_009

  let l_sql = " update datmsrvacp set atdetphor = ? ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and atdsrvseq = ? "

  prepare p_cts10g04_010 from l_sql


  let l_sql = " update datmservico ",
                 " set atdetpcod = ? , ",
                     " atdsrvseq = ?  ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts10g04_011 from l_sql

  #PSI 214558
  let l_sql = " update datmsrvacp set acntmpqtd = ?, ",
              " dstqtd = ? ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? ",
               "   and atdetpcod = ? ",
               "   and atdsrvseq = ? "

  prepare p_cts10g04_012 from l_sql

  #PSI 214558
  let l_sql = "select atdetpdat, atdetphor ",
              "  from datmsrvacp a",
              " where a.atdsrvnum = ? ",
              "   and a.atdsrvano = ? ",
              "   and a.atdetpcod = ? ",
              "   and a.atdsrvseq = (select max(atdsrvseq) from datmsrvacp ",
              "                     where atdsrvnum = a.atdsrvnum ",
              "                       and atdsrvano = a.atdsrvano ",
              "                       and atdetpcod = a.atdetpcod) "

  prepare p_cts10g04_013 from l_sql
  declare c_cts10g04_007 cursor for p_cts10g04_013

  #PSI 214558
  let l_sql = " select max(atdsrvseq) from datmsrvacp ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? ",
              "    and atdetpcod = ? "

  prepare p_cts10g04_014 from l_sql
  declare c_cts10g04_008 cursor for p_cts10g04_014


  let l_sql = "update datmservico",
                " set atdfnlflg = ?, ",
               " atdprscod = ?, ",
               " socvclcod = ?, ",
               " srrcoddig = ?, ",
               " atdprvdat = ?, ",
               " srrltt    = ?, ",
               " srrlgt    = ?, ",             
               " cnldat    = ?, ",             
               " atdfnlhor = ?, ",     
               " acnsttflg = ? ",        
         " where atdsrvnum = ? ",
           " and atdsrvano = ? "
  prepare p_cts10g04_016 from l_sql
         
  let l_sql = " insert into datmsrvacp (atdsrvnum, ",
                                      " atdsrvano, ",
                                      " atdsrvseq, ",
                                      " atdetpcod, ",
                                      " atdetpdat, ",
                                      " atdetphor, ",
                                      " empcod, ",
                                      " funmat, ",
                                      " pstcoddig, ",
                                      " srrcoddig, ",
                                      " socvclcod, ",
                                      " c24nomctt, ",
                                      " envtipcod, ",
                                      " dstqtd,    ",
                                      #Kelly - Inicio
                                      " canmtvcod) ",
                               " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) " #Código Motivo de Cancelamento
                                      #Kelly - Fim
  prepare p_cts10g04_017 from l_sql
  
  let l_sql = "update datmservico",
                " set c24opemat=null,",
                    " c24opeempcod=null,",
                    " c24opeusrtip=null ",
              " where atdsrvnum = ? ",
                " and atdsrvano = ? "
  prepare p_cts10g04_018 from l_sql

  let m_cts10g04_prep = true

end function

#--------------------------------------#
function cts10g04_ultima_etapa(l_param)
#--------------------------------------#

define l_param        record
 atdsrvnum          like datmsrvacp.atdsrvnum,
 atdsrvano          like datmsrvacp.atdsrvano
end record

define tmp_atdetpcod    like datmsrvacp.atdetpcod

 if m_cts10g04_prep is null or
    m_cts10g04_prep <> true then
    call cts10g04_prepare()
 end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     tmp_atdetpcod  =  null

        let     tmp_atdetpcod  =  null

let    tmp_atdetpcod = 0

 open c_cts10g04_002 using l_param.atdsrvnum,
                         l_param.atdsrvano,
                         l_param.atdsrvnum,
                         l_param.atdsrvano
 fetch c_cts10g04_002 into tmp_atdetpcod
 close c_cts10g04_002

return tmp_atdetpcod

end function

#------------------------------------#
function cts10g04_ultimo_pst(lr_param)
#------------------------------------#

 define lr_param record
    atdsrvnum          like datmsrvacp.atdsrvnum
   ,atdsrvano          like datmsrvacp.atdsrvano
   ,atdsrvseq          like datmsrvacp.atdsrvseq
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,atdetpcod like datmsrvacp.atdetpcod
   ,pstcoddig like datmsrvacp.pstcoddig
   ,srrcoddig like datmsrvacp.srrcoddig
   ,socvclcod like datmsrvacp.socvclcod
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

 initialize lr_retorno to null

 if m_cts10g04_prep is null or
    m_cts10g04_prep <> true then
    call cts10g04_prepare()
 end if

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null and
    lr_param.atdsrvseq is not null then
    open c_cts10g04_001 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
                           ,lr_param.atdsrvseq
    whenever error continue
       fetch c_cts10g04_001 into lr_retorno.atdetpcod
                              ,lr_retorno.pstcoddig
                              ,lr_retorno.srrcoddig
                              ,lr_retorno.socvclcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Dados do servico nao encontrado'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmsrvacp'
          error ' Erro no SELECT c_cts10g04_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao cts10g04_ultimo_pst() ', lr_param.atdsrvnum, '/'
                                                , lr_param.atdsrvano, '/'
                                                , lr_param.atdsrvseq sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if

 return lr_retorno.*

end function

#PSI 2013-11843 - Pomar (Cancelamento) - Inicio 
#-----------------------------------#
function cts10g04_insere_etapa(param)
#-----------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig
  end record  
  
  define l_retorno    integer

  call cts10g04_insere_etapa_completo(param.atdsrvnum,
                                      param.atdsrvano,
                                      param.atdetpcod,
                                      param.pstcoddig,
                                      param.c24nomctt,
                                      param.socvclcod,
                                      param.srrcoddig,
                                      1, # Sincronismo
                                      0) # Motivo Cancelamento                                  
       returning l_retorno
       
  return l_retorno 
  
end function


#--------------------------------------------#
function cts10g04_insere_etapa_completo(param)
#--------------------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig,
         sincronizaAW smallint,
         canmtvcod    like datmsrvacp.canmtvcod 
  end record

  define ws           record
         atdsrvseq    like datmsrvacp.atdsrvseq,
         retorno      integer,
         dataatu      date,
         horaatu      datetime hour to minute
  end record
  
  define ws_cont     smallint

  if m_cts10g04_prep is null or
     m_cts10g04_prep <> true then
     call cts10g04_prepare()
  end if

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*  to  null

 # -> BUSCA A DATA E HORA DO BANCO
 call cts40g03_data_hora_banco(2)
      returning ws.dataatu,
                ws.horaatu

  open c_cts10g04_003 using param.atdsrvnum, param.atdsrvano
  fetch c_cts10g04_003 into ws.atdsrvseq
  close c_cts10g04_003

  if ws.atdsrvseq is null then
     let ws.atdsrvseq = 0
  end if

  let ws.atdsrvseq = ws.atdsrvseq + 1

  if g_issk.empcod is null or g_issk.empcod = 0 or
     g_issk.funmat is null or g_issk.funmat = 0 then
     let g_issk.empcod = 1
     let g_issk.funmat = 999999
  end if

  whenever error continue
  let ws_cont   = 0
  while true
    let ws_cont = ws_cont + 1
  execute p_cts10g04_008 using param.atdsrvnum, 
                             param.atdsrvano,
                             ws.atdsrvseq,
                             param.atdetpcod,
                             ws.dataatu,
                             ws.horaatu,
                             g_issk.empcod,
                             g_issk.funmat,
                             param.pstcoddig,
                             param.srrcoddig,
                             param.socvclcod,
                             param.c24nomctt,
                             param.canmtvcod #PSI 2013-11843 - Pomar (Cancelamento)

    if  sqlca.sqlcode <> 0  then
        if  sqlca.sqlcode = -243 or
            sqlca.sqlcode = -244 or
            sqlca.sqlcode = -245 or
            sqlca.sqlcode = -246 or
            sqlca.sqlcode = 1    then
            if  ws_cont < 11  then
                sleep 1
                continue while
            end if
        end if
    end if
    exit while
  end while
  whenever error stop
  let ws.retorno = sqlca.sqlcode

  if  ws.retorno = 0 then
  	   if param.sincronizaAW = 1 then
          call cts00g07_apos_grvetapa(param.atdsrvnum,
                                      param.atdsrvano,
                                      ws.atdsrvseq,1)
       end if

      call cts10g04_alt_etapa(param.atdsrvnum,
                              param.atdsrvano,
                              param.atdetpcod)
           returning ws.retorno
  end if
########## 22/03/2010 Beatriz Araujo PSI 219444
############### Notificar cancelamento da serviço para aplólice RE

  if cta00m06_re_contacorrente() then
     if param.atdetpcod = 5 then
        call cts17m11_cancelasrvre(param.atdsrvnum,
                                   param.atdsrvano,
                                   ws.dataatu,
                                   ws.horaatu,
                                   'N')
     end if
  end if
###############  FIM
  return ws.retorno

end function



#-----------------------------------------------#
function cts10g04_insere_etapa_sincronismo(param)
#-----------------------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig,
         sincronizaAW smallint
  end record

  define l_retorno    integer

  call cts10g04_insere_etapa_completo(param.atdsrvnum,
                                      param.atdsrvano,
                                      param.atdetpcod,
                                      param.pstcoddig,
                                      param.c24nomctt,
                                      param.socvclcod,
                                      param.srrcoddig,
                                      param.sincronizaAW,    # Sincronismo
                                      0)               # Motivo Cancelamento                                  
       returning l_retorno

   return l_retorno #Email de CORE DUMPED do Amarildo, nao tinha o comando RETURN!!!
       
end function

#------------------------------------------#
function cts10g04_insere_etapa_motivo(param)
#------------------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig,
         canmtvcod    like datmsrvacp.canmtvcod 
  end record

  define l_retorno    integer

  call cts10g04_insere_etapa_completo(param.atdsrvnum,
                                      param.atdsrvano,
                                      param.atdetpcod,
                                      param.pstcoddig,
                                      param.c24nomctt,
                                      param.socvclcod,
                                      param.srrcoddig,
                                      1,               # Sincronismo
                                      param.canmtvcod)       # Motivo Cancelamento                                  
       returning l_retorno
    
  return l_retorno #Chamado 205600 - Problema ao cancelar laudos Liberados
       
end function
#PSI 2013-11843 - Pomar (Cancelamento) - Fim 


#--------------------------------------#
function cts10g04_insere_etapa_mq(param)
#--------------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdsrvseq    like datmsrvacp.atdsrvseq,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig,
         dataatu      like datmsrvacp.atdetpdat,
         horaatu      like datmsrvacp.atdetphor,
         funmat	      like datmsrvacp.funmat,
         empcod       like datmsrvacp.empcod,
         envtipcod    like datmsrvacp.envtipcod,
         dstqtd       like datmsrvacp.dstqtd,
         atdprvdat    like datmservico.atdprvdat,
         srrltt       like datmservico.srrltt,
         srrlgt       like datmservico.srrlgt,
         canmtvcod    like datmsrvacp.canmtvcod #Kelly
  end record

  define ws           record
         retorno      integer,
         atdfnlflg    like datmservico.atdfnlflg,
         acnsttflg    like datmservico.acnsttflg
  end record
  
  define l_resultado smallint

  if m_cts10g04_prep is null or
     m_cts10g04_prep <> true then
     call cts10g04_prepare()
  end if

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*  to  null
 
  #CT: 140718581
  #Descricao: Estava inserindo o seq duplicado
  #Autor: Brunno Silva
  #Equipe: Sistemas Niagara
  whenever error continue

       execute p_cts10g04_017 using param.atdsrvnum,
                                    param.atdsrvano,
                                    param.atdsrvseq,
                                    param.atdetpcod,
                                    param.dataatu,
                                    param.horaatu,
                                    param.empcod,
                                    param.funmat,
                                    param.pstcoddig,
                                    param.srrcoddig,
                                    param.socvclcod,
                                    param.c24nomctt,
                                    param.envtipcod,
                                    param.dstqtd,
                                    param.canmtvcod #Kelly

                                    
  whenever error stop                              
  #Fim CT: 140718581 
  
  let ws.retorno = sqlca.sqlcode

  if  ws.retorno = 0 then
      call cts10g04_alt_etapa(param.atdsrvnum,
                              param.atdsrvano,
                              param.atdetpcod)
           returning ws.retorno
  else
      display "Erro ao Inserir datmsrvacp - p_cts10g04_017, ", ws.retorno
      if ws.retorno = -268 then
         ##Se for duplicado retorna OK
         return 0
      else
         return ws.retorno
      end if
  end if
########## 22/03/2010 Beatriz Araujo PSI 219444
############### Notificar cancelamento da serviço para aplólice RE
  if param.atdetpcod = 5 then
     call cts17m11_cancelasrvre(param.atdsrvnum,
                                param.atdsrvano,
                                param.dataatu,
                                param.horaatu,
                                'N')
  end if
###############  FIM

######### Alterar as informacoes de conclusao quando o serviço mudar status de concluisao
  if param.atdetpcod = 1 or
     param.atdetpcod = 3 or
     param.atdetpcod = 4 or
     param.atdetpcod = 5 or
     param.atdetpcod = 10 or
     param.atdetpcod = 38 or
     param.atdetpcod = 39 then
     
     let ws.acnsttflg = 'N'
     if param.atdetpcod = 1 or param.atdetpcod = 38 or param.atdetpcod = 39 then
        let ws.atdfnlflg = "N"
     else
        let ws.atdfnlflg = "S"
        if param.funmat = 999999 then
           let ws.acnsttflg = 'S'
        end if
     end if
     
     execute p_cts10g04_016 using ws.atdfnlflg,
                                  param.pstcoddig,
                                  param.socvclcod,
                                  param.srrcoddig,
                                  param.atdprvdat,
                                  param.srrltt,
                                  param.srrlgt,
                                  param.dataatu,
                                  param.horaatu,
                                  ws.acnsttflg,
                                  param.atdsrvnum,
                                  param.atdsrvano
                                  
     # Desbloqueia servico recusados ou com tempo excedido quando eles voltam para o acinamento
     if param.atdetpcod = 38 or param.atdetpcod = 39 then
        execute p_cts10g04_018 using param.atdsrvnum,
                                     param.atdsrvano
     end if

  end if     
  
  # Envio de alerta de distancia de acionamento
  if param.atdetpcod = 3 or
     param.atdetpcod = 4 then
     call ctx01g12_enviaemail_acn_dist(param.atdsrvnum, param.atdsrvano)
     
     #envia aviso de acionamento para corretor
     call cts00g10(param.atdsrvnum, param.atdsrvano)     
      returning l_resultado 
              
     #envia email para CAPS
     call cts00m42_email(param.atdsrvnum, param.atdsrvano)              

  end if
  
  return ws.retorno

end function

# Insere tempo de atendimento e distancia de atendimento na tabela datmsrvacp
#-----------------------------------#
function cts10g04_tempo_distancia(param)
#-----------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         dstqtd       like datmsrvacp.dstqtd
  end record

  define ws           record
         retorno      integer,
         acntmpqtd    like datmsrvacp.acntmpqtd,
         srvprsacnhordat   like datmservico.srvprsacnhordat,
         atdlibdat    like datmservico.atdlibdat,
         atdlibhor    like datmservico.atdlibhor,
         tmpatd       like datmservico.srvprsacnhordat,
         atdetpdat    like datmsrvacp.atdetpdat,
         atdetphor    like datmsrvacp.atdetphor,
         atdsrvseq    like datmsrvacp.atdsrvseq,
         data_hora     datetime year to minute,
         data_hora2    datetime year to minute,
         data_hor_aux  datetime year to second,
         data_hor_aux2 datetime year to second,
         data_aux     char(19),
         data_aux_c   char(19),
         data_aux2    char(19),
         data_aux_c2  char(19)
  end record
  
  define l_resultado smallint

  if m_cts10g04_prep is null or
     m_cts10g04_prep <> true then
     call cts10g04_prepare()
  end if

 initialize  ws.*  to  null

  #Busca dados do serviço
  call cts10g06_dados_servicos(18, param.atdsrvnum, param.atdsrvano)
    returning ws.srvprsacnhordat, ws.atdlibhor, ws.atdlibdat

  open  c_cts10g04_007 using param.atdsrvnum, param.atdsrvano, param.atdetpcod
    fetch c_cts10g04_007 into ws.atdetpdat, ws.atdetphor
  close c_cts10g04_007

  #Transforma atdetpdat e atdetphor da datmsrvacp em datetime year to minute
  let ws.data_aux   = null
  let ws.data_aux   = ws.atdetpdat, " ", ws.atdetphor
  let ws.data_aux   = ws.data_aux[7,10], "-",  # ANO
                      ws.data_aux[4,5],  "-",  # MES
                      ws.data_aux[1,2],  " ",  # DIA
                      ws.data_aux[12,16]
  let ws.data_hora2 = ws.data_aux
  #display "ws.atdetpdat, ws.atdetphor ", ws.data_hora2

  #Transformacao de srvprsacnhordat da datmservico para comparacao
  let ws.data_aux  = null
  let ws.data_aux  = extend(ws.srvprsacnhordat, year to minute) clipped
  let ws.data_hora = ws.data_aux
  #display "ws.srvprsacnhordat ", ws.data_hora

  if ws.data_hora > ws.data_hora2 then

      #Se o servico for acionado antes da hora prevista nao considerar o tempo do acionamento
      let ws.data_aux = null

  else
      #Transforma hora do registro da datmservico
      {let ws.data_aux_c =  ws.data_aux[1,4], "-",  # ANO
                           ws.data_aux[6,7], "-",   # MES
                           ws.data_aux[9,10]," " ,  # DIA
                           ws.data_aux[12,16]
      let ws.data_hor_aux = ws.data_aux_c
      display "ws.data_hor_aux else ", ws.data_hor_aux}

      let ws.data_hor_aux = extend(ws.srvprsacnhordat, year to second) clipped
      #display "srvprsacnhordat ws.data_hor_aux >>>>> ", ws.data_hor_aux

  end if

  {open  c_cts10g04_007 using param.atdsrvnum, param.atdsrvano, param.atdetpcod
  fetch c_cts10g04_007 into ws.atdetpdat, ws.atdetphor
  close c_cts10g04_007

  let ws.data_aux2 = ws.atdetpdat, " ", ws.atdetphor
  let ws.data_aux_c2 = ws.data_aux2[7,10], "-", # ANO
                       ws.data_aux2[4,5], "-",  # MES
                       ws.data_aux2[1,2]," " ,  # DIA
                       ws.data_aux2[12,16]}

  #Insere em uma variável datetime year to second a hora atual(acionamento)
  let ws.data_hor_aux2 = current

  let ws.acntmpqtd = ws.data_hor_aux2 - ws.data_hor_aux

  {display " Executando query "
  display "ws.acntmpqtd ", ws.acntmpqtd
  display "param.dstqtd ", param.dstqtd
  display "param.atdsrvnum ", param.atdsrvnum
  display "param.atdsrvano ", param.atdsrvano}

  open  c_cts10g04_008 using param.atdsrvnum,
                           param.atdsrvano,
                           param.atdetpcod
  fetch c_cts10g04_008 into ws.atdsrvseq
  close c_cts10g04_008

  execute p_cts10g04_012 using ws.acntmpqtd,
                             param.dstqtd,
                             param.atdsrvnum,
                             param.atdsrvano,
                             param.atdetpcod,
                             ws.atdsrvseq

  let ws.retorno = sqlca.sqlcode
  
  #call cts00g07_apos_grvetapa(param.atdsrvnum,
  #                            param.atdsrvano,
  #                            ws.atdsrvseq,2)
                              
  # Envio de alerta de distancia de acionamento
  if param.atdetpcod = 3 or
     param.atdetpcod = 4 then
     call ctx01g12_enviaemail_acn_dist(param.atdsrvnum, param.atdsrvano)
     
     #envia aviso de acionamento para corretor
     call cts00g10(param.atdsrvnum, param.atdsrvano)     
      returning l_resultado      
                           
     #envia email para CAPS
     #display "<745> cts10g04-> cts10g04_tempo_distancia >> "
     call cts00m42_email(param.atdsrvnum, param.atdsrvano)              
  end if                              

  return ws.retorno

end function

#----------------------------------#
 function cts10g04_alt_etapa(param)
#----------------------------------#

  define param        record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod
  end record

  define l_atdsrvseq smallint
  define ws_cont     smallint

  if m_cts10g04_prep is null or
     m_cts10g04_prep <> true then
     call cts10g04_prepare()
  end if

  open c_cts10g04_003 using param.atdsrvnum, param.atdsrvano
  fetch c_cts10g04_003 into l_atdsrvseq
  close c_cts10g04_003

  whenever error continue
  let ws_cont   = 0
  while true
    let ws_cont = ws_cont + 1
    execute p_cts10g04_011 using param.atdetpcod,
                                 l_atdsrvseq,
                                 param.atdsrvnum,
                                 param.atdsrvano
    if  sqlca.sqlcode <> 0  then
        if  sqlca.sqlcode = -243 or
            sqlca.sqlcode = -244 or
            sqlca.sqlcode = -245 or
            sqlca.sqlcode = -246 then
            if  ws_cont < 11  then
                sleep 1
                continue while
            end if
        end if
    end if
    exit while
  end while
  whenever error stop

  call cta00m09_registro_acionamento(param.atdetpcod,1)

  return sqlca.sqlcode

 end function

#---------------------------------#
function cts10g04_max_seq(lr_param)
#---------------------------------#

 define lr_param   record
    atdsrvnum      like datmsrvacp.atdsrvnum
   ,atdsrvano      like datmsrvacp.atdsrvano
   ,atdetpcod      like datmsrvacp.atdetpcod
 end record

 define lr_retorno record
    resultado      smallint
   ,mensagem       char(60)
   ,atdsrvseq      like datmsrvacp.atdsrvseq
 end record

 define l_sql char(300)

  if m_cts10g04_prep is null or
     m_cts10g04_prep <> true then
     call cts10g04_prepare()
  end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

 initialize lr_retorno to null

 if lr_param.atdsrvnum is not null and
    lr_param.atdsrvano is not null then
    let l_sql = ' select max(atdsrvseq) '
                 ,' from datmsrvacp '
                ,' where atdsrvnum = ? '
                  ,' and atdsrvano = ? '

    if lr_param.atdetpcod is not null then
       let l_sql = l_sql clipped, ' and atdetpcod = ', lr_param.atdetpcod
    end if

    prepare p_cts10g04_015 from l_sql
    declare c_cts10g04_009 cursor for p_cts10g04_015

    open c_cts10g04_009 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
    whenever error continue
       fetch c_cts10g04_009 into lr_retorno.atdsrvseq
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Etapa nao encontrada'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datmsrvacp'
          error ' Erro no SELECT c_cts10g04_009 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
          error ' Funcao cts10g04_max_seq() ', lr_param.atdsrvnum, '/'
                                             , lr_param.atdsrvano sleep 2
       end if
    else
       let lr_retorno.resultado = 1
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros nulos'
 end if

 return lr_retorno.*

end function

# PSI186406 - Robson - Fim

#----------------------------------------#
function cts10g04_atualiza_dados(lr_param)
#----------------------------------------#
 define lr_param      record
        atdsrvnum     like datmsrvacp.atdsrvnum
       ,atdsrvano     like datmsrvacp.atdsrvano
       ,srvrcumtvcod  like datmsrvacp.srvrcumtvcod
       ,envtipcod     like datmsrvacp.envtipcod
 end record
 define l_resultado   smallint
       ,l_mensagem    char(60)
       ,l_seq         like datmsrvacp.atdsrvseq
       ,l_null        smallint
       ,l_erro        char(80)
       ,l_retorno     smallint

 if m_cts10g04_prep is null or
    m_cts10g04_prep <> true then
    call cts10g04_prepare()
 end if

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_resultado  =  null
        let     l_mensagem  =  null
        let     l_seq  =  null
        let     l_null  =  null
        let     l_erro  =  null
        let     l_retorno  =  null

 let l_null = null
 let l_mensagem = ' '
 let l_retorno = 1

 call cts10g04_max_seq(lr_param.atdsrvnum, lr_param.atdsrvano, l_null)
      returning l_resultado, l_mensagem, l_seq

 if l_resultado <> 1 then
    let l_retorno = 2
    return l_mensagem, l_retorno
 end if

 if lr_param.srvrcumtvcod is not null then
    whenever error continue
    execute p_cts10g04_002 using lr_param.srvrcumtvcod,
                               lr_param.atdsrvnum,
                               lr_param.atdsrvano,
                               l_seq
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_erro = 'Erro UPDATE ccts10g04003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = 'CTS10G04 / cts10g04_atualiza_dados() '
       call errorlog(l_erro)
       let l_retorno = 2
       let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datmsrvacp '
    else
       call cts00g07_apos_grvetapa(lr_param.atdsrvnum,
                                   lr_param.atdsrvano,
                                   l_seq,2)
    end if
 end if

 if lr_param.envtipcod is not null and l_retorno <> 2 then
    whenever error continue
    execute p_cts10g04_003 using lr_param.envtipcod,
                               lr_param.atdsrvnum,
                               lr_param.atdsrvano,
                               l_seq
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_erro = 'Erro UPDATE ccts10g04004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
       call errorlog(l_erro)
       let l_erro = 'CTS10G04 / cts10g04_atualiza_dados() '
       call errorlog(l_erro)
       let l_retorno = 2
       let l_mensagem = 'Erro ', sqlca.sqlcode, ' em datmsrvacp '
    else
       #call cts00g07_apos_grvetapa(lr_param.atdsrvnum,
       #                            lr_param.atdsrvano,
       #                            l_seq,2)
    end if
 end if

 return l_mensagem,
        l_retorno

end function

#-------------------------------------------#
 function cts10g04_busca_prest_ant(lr_param)
#-------------------------------------------#
   define lr_param record
                       atdsrvnum like datmsrvre.atdsrvnum,
                       atdsrvano like datmsrvre.atdsrvano
                   end record

   define l_retorno      smallint,
          l_retprsmsmflg like datmsrvre.retprsmsmflg

   define ws record
       atdorgsrvnum like dbsmopgitm.atdsrvnum, #numero servico anterior
       atdorgsrvano like dbsmopgitm.atdsrvano, #ano servico anterior
       atdsrvnum    like dbsmopgitm.atdsrvnum,
       atdsrvano    like dbsmopgitm.atdsrvano,
       pstcoddig    like datmsrvacp.pstcoddig,
       srrcoddig    like datmsrvacp.srrcoddig,
       socvclcod    like datmsrvacp.socvclcod,
       nometxt      char(300),
       socopgnum    like dbsmopgitm.socopgnum
   end record

   initialize ws.* to null

   if m_cts10g04_prep is null or
      m_cts10g04_prep <> true then
      call cts10g04_prepare()
   end if

   open c_cts10g04_006 using lr_param.atdsrvnum,
                           lr_param.atdsrvano
   fetch c_cts10g04_006 into ws.atdorgsrvnum,
                           ws.atdorgsrvano,
                           l_retprsmsmflg

   #Busca dados do servico anterior
   open c_cts10g04_004 using ws.atdorgsrvnum,
                           ws.atdorgsrvano,
                           lr_param.atdsrvnum,
                           lr_param.atdsrvano,
                           lr_param.atdsrvano
   whenever error continue
   fetch c_cts10g04_004 into ws.atdorgsrvnum,
                           ws.atdorgsrvano,
                           ws.pstcoddig,
                           ws.srrcoddig,
                           ws.socvclcod

   if  sqlca.sqlcode <> 0 then
       if  sqlca.sqlcode = notfound then

           #Caso nao exista servico anterior busca o servico original
           open c_cts10g04_005 using ws.atdorgsrvnum,
                                   ws.atdorgsrvano
           whenever error continue
           fetch c_cts10g04_005 into ws.atdorgsrvnum,
                                   ws.atdorgsrvano,
                                   ws.pstcoddig,
                                   ws.srrcoddig,
                                   ws.socvclcod

           if  sqlca.sqlcode <> 0 then
               if  sqlca.sqlcode <> notfound then
                   error "Erro SELECT c_cts10g04_005 ", sqlca.sqlcode, " | ", sqlca.sqlerrd[2] sleep 2
                   error "ctb00g10_busca_prest_ant() | ", ws.atdorgsrvnum, " | ", ws.atdorgsrvano sleep 2
               end if
           end if

       end if
   end if

   return ws.pstcoddig,
          ws.srrcoddig,
          ws.socvclcod

 end function


function cts10g04_atu_hor(lr_param)
 define lr_param      record
        atdsrvnum     like datmsrvacp.atdsrvnum
       ,atdsrvano     like datmsrvacp.atdsrvano
       ,atdsrvseq     like datmsrvacp.atdsrvseq
       ,atdetphor     like datmsrvacp.atdetphor
 end record

 define l_resultado   smallint
       ,l_mensagem    char(60)

 if m_cts10g04_prep is null or
    m_cts10g04_prep <> true then
    call cts10g04_prepare()
 end if

 let l_resultado = 1
 let l_mensagem  = null

 whenever error continue
 execute p_cts10g04_010 using lr_param.atdetphor,
                            lr_param.atdsrvnum,
                            lr_param.atdsrvano,
                            lr_param.atdsrvseq
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let l_resultado = 2
    let l_mensagem = 'Erro ', sqlca.sqlcode, ' atualiza hora em datmsrvacp '
 else
    call cts00g07_apos_grvetapa(lr_param.atdsrvnum,
                                lr_param.atdsrvano,
                                lr_param.atdsrvseq,2)
 end if

 return l_resultado, l_mensagem

end function

