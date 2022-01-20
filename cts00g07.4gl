#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema        : Porto Socorro                                               #
# Modulo         : cts00g07                                                    #
#                  Ponto de acesso após a gravacao dos servicos                #
# Analista Resp. : Raji Duenhas Jahchan                                        #
# PSI            : 218545 - ATENDIMENTO PORTO SEGURO SERVICOS                  #
#------------------------------------------------------------------------------#
#                         * * *  ALTERACOES  * * *                             #
# Data       Analista Resp  PSI/Alteracao                                      #
#------------------------------------------------------------------------------#
# 27/04/2010 Adriano Santos PSI242853 Servico PSS verificar se tem prestador   #
#                                     vinculado ao contrato                    #
# 24/01/2012 Sergio Burini  PSI-2013-00435/EV - ROTEIRO MANUAL DE SERVIÇOS     #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
# Ponto de entrada após a gravação do serviço
#------------------------------------------------------------
function cts00g07_apos_grvlaudo(param)
  define param record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano
  end record
  
  call cts00g07_apos_grvlaudo_sin(param.atdsrvnum,
                                  param.atdsrvano,
                                  1) # Sincoroniza AW

end function # cts00g07_apos_grvlaudo

function cts00g07_apos_grvlaudo_sin(param)
  define param record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano,
     sincroniza  smallint
  end record

  define l_obter_mult smallint,
         l_i          smallint,
         l_resultado  smallint,
         l_mensagem   char(100),
         l_servico_original   like datmservico.atdsrvnum,
         l_ano_original       like datmservico.atdsrvano,
         l_primeiravez smallint

  define am_cts29g00  array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
        atdmltsrvano like datratdmltsrv.atdmltsrvano,
        socntzdes    like datksocntz.socntzdes,
        espdes       like dbskesp.espdes,
        atddfttxt    like datmservico.atddfttxt
  end record

  define lr_pss01g00   record
           resultado     integer
          ,mensagem      char(200)
          ,pstcoddig     like datmsrvacp.pstcoddig
          ,srrcoddig     like datmsrvacp.srrcoddig
  end record

  define lr_cts00g08 record
      resultado  smallint,
      mensagem   char(100)
  end record
  define l_status smallint,
         l_aux    char(15),
         l_aux2   char(15)

  let l_obter_mult = null
  let l_resultado = null
  let l_mensagem = null
  let l_i = null
  let l_servico_original = null
  let l_ano_original = null
  let l_status = null
  let l_aux           = null
  let l_aux2          = null

  initialize am_cts29g00 to null

  # Verifica se e primeira vez que passa pela funcao
  select srvprsacnhordat
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano
     and srvprsacnhordat is null
  if sqlca.sqlcode = notfound then
     let l_primeiravez = false
  else
     let l_primeiravez = true
  end if

  # Caso servico PSS verificar se tem prestador vinculado ao contrato
  if g_documento.ciaempcod = 43 then
      call cts00g08(param.atdsrvnum,
                    param.atdsrvano)
           returning lr_cts00g08.resultado,
                     lr_cts00g08.mensagem

      if lr_cts00g08.resultado then
          error lr_cts00g08.mensagem sleep 2
      end if
      call cts40g06_desb_srv(param.atdsrvnum,
                             param.atdsrvano)
           returning l_status
  end if

  ## obter o servigo original atraves do multiplo
  call cts29g00_consistir_multiplo(param.atdsrvnum
                                  ,param.atdsrvano)
                   returning l_resultado
                            ,l_mensagem
                            ,l_servico_original
                            ,l_ano_original

  # PSI-2013-00435/EV - ROTEIRO MANUAL DE SERVIÇOS
  if  l_servico_original is not null and
      l_servico_original <> " " then

      call ctd34g00_atl_horacomb(l_servico_original,
                                 l_ano_original,
                                 'A')
           returning l_resultado,
                     l_mensagem

      if  l_resultado <> 0 then
          display "ERRO ATUALIZACAO HORA COMBINADA", l_mensagem
      end if

  end if

  #################################################

  call cts29g00_obter_multiplo
           (1, l_servico_original, l_ano_original)
            returning l_obter_mult, l_mensagem,
                      am_cts29g00[1].*,
                      am_cts29g00[2].*,
                      am_cts29g00[3].*,
                      am_cts29g00[4].*,
                      am_cts29g00[5].*,
                      am_cts29g00[6].*,
                      am_cts29g00[7].*,
                      am_cts29g00[8].*,
                      am_cts29g00[9].*,
                      am_cts29g00[10].*

  for l_i = 1 to 10
      if am_cts29g00[l_i].atdmltsrvnum is not null then

      # PSI-2013-00435/EV - ROTEIRO MANUAL DE SERVIÇOS
      let l_aux  = am_cts29g00[l_i].atdmltsrvnum
      let l_aux2 = am_cts29g00[l_i].atdmltsrvano

      call ctd34g00_atl_horacomb(am_cts29g00[l_i].atdmltsrvnum,
                                 am_cts29g00[l_i].atdmltsrvano,
                                 'A')
           returning l_resultado,
                     l_mensagem

      if  l_resultado <> 0 then
          display "ERRO ATUALIZACAO HORA COMBINADA", l_mensagem
      end if
      #################################################

         call ctd07g00_alt_hora_acn(am_cts29g00[l_i].atdmltsrvnum,
                                    am_cts29g00[l_i].atdmltsrvano)

         # Caso servico PSS verificar de tem prestador vinculado ao contrato
           if g_documento.ciaempcod = 43 then
               call cts00g08(am_cts29g00[l_i].atdmltsrvnum,
                             am_cts29g00[l_i].atdmltsrvano)
                    returning lr_cts00g08.resultado,
                              lr_cts00g08.mensagem
               if lr_cts00g08.resultado then
                   error lr_cts00g08.mensagem sleep 2
               end if
               call cts40g06_desb_srv(am_cts29g00[l_i].atdmltsrvnum,
                                      am_cts29g00[l_i].atdmltsrvano)
                    returning l_status
           end if
      end if
  end for

  # PSI-2013-00435/EV - ROTEIRO MANUAL DE SERVIÇOS
  call ctd34g00_atl_horacomb(param.atdsrvnum,
                             param.atdsrvano,
                             'A')
       returning l_resultado,
                 l_mensagem

  if  l_resultado <> 0 then
      display "ERRO ATUALIZACAO HORA COMBINADA", l_mensagem
  end if
  #################################################

  call ctd07g00_alt_hora_acn(param.atdsrvnum,
                             param.atdsrvano)

  # Envio de alerta de abertura de servico
  if l_primeiravez then

     #Apolice com muitos servicos
     call ctx01g12_enviaemail_serv_pago(param.atdsrvnum,
                                        param.atdsrvano)

     #Servico com grande distancia entre ocorrencia e destido
     call ctx01g12_enviaemail_serv_dist(param.atdsrvnum,
                                        param.atdsrvano)

     #Servico abertos para assistencias especificas
     call ctx01g12_enviaemail_serv_assistencia(param.atdsrvnum,
                                               param.atdsrvano)

     #Servico abertos para naturezas especificas
     call ctx01g12_enviaemail_serv_natureza(param.atdsrvnum,
                                            param.atdsrvano)

     #Servico abertos para problemas especificos
     call ctx01g12_enviaemail_serv_problema(param.atdsrvnum,
                                            param.atdsrvano)

     #Servico abertos para local de ocorrencia parametrizado
     call ctx01g12_enviaemail_serv_local_ocorr(param.atdsrvnum,
                                               param.atdsrvano)

  end if

  # ACIONAMENTO WEB
  if param.sincroniza = 1 then
     call ctx34g02_apos_grvservico(param.atdsrvnum,
                                   param.atdsrvano)
  end if

end function # cts00g07_apos_grvlaudo_sin

#------------------------------------------------------------
# Ponto de entrada após a gravação do serviço
#------------------------------------------------------------
function cts00g07_apos_grvetapa(param)

define param record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     atdsrvseq like datmservico.atdsrvseq,
     tipoEnvio smallint # 1- insert da ultima sequencia  2- update da sequencia
  end record
 
 define l_atdetpcod like datmsrvacp.atdetpcod

  call ctx34g00_apos_grvetapa(param.atdsrvnum,
                             param.atdsrvano,0,1)
                             
   #se atdsrvseq diferente de zero significa que nova etapa foi inserida no servico
   if param.atdsrvseq <> 0 and param.tipoEnvio = 1 then                         
      ##verifica se servico esta acionado
      call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
            returning l_atdetpcod
            
      #se etapa 3 ou 4 - Acionado avisa central 24h 
      if  l_atdetpcod = 3 or l_atdetpcod = 4 then
          #display "<249> cts00g07-> l_atdetpcod >> ", l_atdetpcod 
          call cts00m42_email(param.atdsrvnum, param.atdsrvano)   
      end if
      
      #se etapa 5 e foi cancelado pela central (g_documento.acao ="CAN")
      #display "g_documento.acao", g_documento.acao
      if g_documento.acao = "CAN" and l_atdetpcod = 5 then 
         call cts00m42_email_cancelamento(param.atdsrvnum, param.atdsrvano)
      end if
          
   end if                           

end function


#------------------------------------------------------------
# Ponto de entrada após a gravação do serviço
#------------------------------------------------------------
function cts00g07_apos_grvhist(param)

define param record
    atdsrvnum like datmservhist.atdsrvnum,
    atdsrvano like datmservhist.atdsrvano,
    c24txtseq like datmservhist.c24txtseq,
    tipoEnvio smallint # 1- insert da ultima sequencia  2- update da sequencia
  end record

  call ctx34g01_apos_grvhistorico(param.atdsrvnum,
                             param.atdsrvano,0,1)
end function

#------------------------------------------------------------
# Ponto de entrada após o bloqueio do serviço
#------------------------------------------------------------
function cts00g07_apos_servbloqueia(param)
define param record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano
  end record

  whenever error continue
  update datmservico
   set srvacsblqhordat = current
   where atdsrvnum = param.atdsrvnum
    and  atdsrvano = param.atdsrvano
  whenever error stop

  call ctx34g02_bloq_desbloq(param.atdsrvnum,
                             param.atdsrvano)

end function

#------------------------------------------------------------
# Ponto de entrada após o desbloqueio do serviço
#------------------------------------------------------------
function cts00g07_apos_servdesbloqueia(param)
define param record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano
  end record

  whenever error continue
  update datmservico
   set srvacsblqhordat = null
   where atdsrvnum = param.atdsrvnum
    and  atdsrvano = param.atdsrvano
  whenever error stop

  call ctx34g02_bloq_desbloq(param.atdsrvnum,
                             param.atdsrvano)

end function
