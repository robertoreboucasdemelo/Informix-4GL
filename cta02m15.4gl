#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cta02m15.                                                  #
# Analista Resp.: Ligia Mattge.                                              #
# PSI           : 190080                                                     #
#                 Obter a quantidade de atendimentos conforme assunto.       #
#............................................................................#
# Desenvolvimento: Robson Inocencio, META                                    #
# Liberacao      : 26/01/2005                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 21/09/06   Ligia Mattge      PSI 202720  Implementacao do cartao Saude     #
#                                          para contar os servicos(bnfnum)   #
#----------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo    PSI 000762  Trata contagem do assunto S66     #
#                                          utilizado para Help Desk Casa     #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#--------------------------#
function cta02m15_prepare()
#--------------------------#
 define l_sql char(600)

 let l_sql = ' select atdsrvnum '
                  ,' ,atdsrvano '
              ,' from datrservapol '
             ,' where ramcod    = ? '
               ,' and succod    = ? '
               ,' and aplnumdig = ? '
               ,' and itmnumdig = ? '
 prepare p_cta02m15_001 from l_sql
 declare c_cta02m15_001 cursor for p_cta02m15_001

 let l_sql = ' select atdsrvnum '
                  ,' ,atdsrvano '
              ,' from datmligacao '
                  ,' ,datrligprp '
             ,' where datmligacao.lignum   = datrligprp.lignum '
               ,' and datrligprp.prporg    = ? '
               ,' and datrligprp.prpnumdig = ? '
               ,' and c24astcod            = ? '
 prepare p_cta02m15_002 from l_sql
 declare c_cta02m15_002 cursor for p_cta02m15_002

 let l_sql = ' select 1 '
            ,'  from datmservico a, datmligacao b '
           ,'  where a.atdsrvnum = ? '
             ,' and a.atdsrvano = ? '
             ,' and b.c24astcod = ? '
             ,' and a.atddat   >= ? '
             ,' and a.atdsrvnum = b.atdsrvnum '
             ,' and a.atdsrvano = b.atdsrvano '
 prepare p_cta02m15_003 from l_sql
 declare c_cta02m15_003 cursor for p_cta02m15_003

 let l_sql = ' select atdsrvnum '
                  ,' ,atdsrvano '
              ,' from datrsrvsau '
             ,' where bnfnum    = ? '

 prepare p_cta02m15_004 from l_sql
 declare c_cta02m15_004 cursor for p_cta02m15_004
 
 # -- contagem de servico por apolice
 # -- desconsidera item - Sistema PET
 
 let l_sql = ' select atdsrvnum '
                  ,' ,atdsrvano '
              ,' from datrservapol '
             ,' where ramcod    = ? '
               ,' and succod    = ? '
               ,' and aplnumdig = ? '
 prepare pcta02m15005 from l_sql
 declare ccta02m15005 cursor for pcta02m15005
 

 let m_prep_sql = true

end function

#-----------------------------------------------#
function cta02m15_qtd_envio_socorro(lr_entrada)
#-----------------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
 end record

 define l_qtd integer

 let l_qtd = null

 ##--Obter a quantidade de atendimentos de Envio de Socorro(S10) para apolice ou proposta --##
 let l_qtd = cta02m15_qtd_servico(lr_entrada.ramcod
                                 ,lr_entrada.succod
                                 ,lr_entrada.aplnumdig
                                 ,lr_entrada.itmnumdig
                                 ,lr_entrada.prporgpcp
                                 ,lr_entrada.prpnumpcp
                                 ,lr_entrada.clcdat
                                 ,'S10',"")
 return l_qtd

end function

#------------------------------------------------#
function cta02m15_qtd_serv_residencia(lr_entrada)
#------------------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,bnfnum    like datrligsau.bnfnum
 end record

 define l_qtd integer

 let l_qtd = null

 ##-- Obter a quantidade de atendimentos de Servico Emergencial a Residencia (S60,S63). --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##

 ##--Obter a quantidade de atendimentos para o assunto S60 e S63. --##
 let l_qtd = cta02m15_qtd_servico(lr_entrada.ramcod
                                 ,lr_entrada.succod
                                 ,lr_entrada.aplnumdig
                                 ,lr_entrada.itmnumdig
                                 ,lr_entrada.prporgpcp
                                 ,lr_entrada.prpnumpcp
                                 ,lr_entrada.clcdat
                                 ,lr_entrada.c24astcod
                                 ,lr_entrada.bnfnum)
 return l_qtd

end function

#----------------------------------------#
function cta02m15_qtd_servico(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,bnfnum    like datrligsau.bnfnum
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cta02m15_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a quantidade de servicos  realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##


 ##-- Obter os servicos dos atendimentos realizados pelo cartao Saude --##

 if lr_entrada.bnfnum is not null then ##PSI 202720
    open c_cta02m15_004 using lr_entrada.bnfnum

    foreach c_cta02m15_004 into lr_servico.*
       ##-- Consiste o servico para considera-lo na contagem --##
       call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                     ,lr_servico.atdsrvano
                                     ,lr_entrada.c24astcod
                                     ,lr_entrada.clcdat)
       returning l_resultado, l_mensagem

       if l_resultado = 1 then
          let l_qtd  = l_qtd + 1
       else
          if l_resultado = 3 then
             error l_mensagem
             exit foreach
          end if
       end if
    end foreach
    close c_cta02m15_004

 else

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.aplnumdig is not null then
       open c_cta02m15_001 using lr_entrada.ramcod
                              ,lr_entrada.succod
                              ,lr_entrada.aplnumdig
                              ,lr_entrada.itmnumdig

       foreach c_cta02m15_001 into lr_servico.*
          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd  = l_qtd + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cta02m15_001
    end if

    ##-- Obter os servicos dos atendimentos realizados pela proposta --##
    if lr_entrada.prpnumpcp is not null then
       open c_cta02m15_002 using lr_entrada.prporgpcp
                              ,lr_entrada.prpnumpcp
                              ,lr_entrada.c24astcod

       foreach c_cta02m15_002 into lr_servico.atdsrvnum
                                ,lr_servico.atdsrvano

          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd  = l_qtd + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cta02m15_002
    end if

 end if

 return l_qtd

end function


#---------------------------------------------#
function cta02m15_consiste_servico(lr_entrada)
#---------------------------------------------#
 define lr_entrada record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,c24astcod like datmligacao.c24astcod
   ,clcdat    like datmservico.atddat
 end record

 define l_resultado smallint
       ,l_mensagem  char(60)
       ,l_atdetpcod like datmsrvacp.atdetpcod

 initialize l_resultado to  null
 initialize l_mensagem  to  null
 initialize l_atdetpcod to  null

 if not m_prep_sql then
    call cta02m15_prepare()
 end if

 ## Consistir regras para considerar o servico na contagem de atendimento. --##
 ## = 1 - Consistiu servico de acordo com a etapa testada, ok. 
 ## = 2 - Não achou servico ou etapa não está de acordo com etapa testada, ok. 
 ## = 3 - Erro de banco. 

 ## Verifica se o  atendimento foi realizado apos a data de calculo --##


  open c_cta02m15_003 using lr_entrada.atdsrvnum
                        ,lr_entrada.atdsrvano
                        ,lr_entrada.c24astcod
                        ,lr_entrada.clcdat
 whenever error continue
 fetch c_cta02m15_003
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let l_resultado = 2
    else
       let l_resultado = 3
       let l_mensagem = 'Erro', sqlca.sqlcode, ' em datmservico '
    end if
 else
    ##-- Obtem a ultima etapa do servico --##
    let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                           ,lr_entrada.atdsrvano)

    ##-- Para servico a residencia, conta servicos Liberados(1) e Acionados(3) 
    if lr_entrada.c24astcod = 'S60' or
       lr_entrada.c24astcod = 'S63' or
       lr_entrada.c24astcod = 'S66' or
       lr_entrada.c24astcod = 'S67' or
       lr_entrada.c24astcod = 'S41' or   #ligia - jan/2012
       lr_entrada.c24astcod = 'S42' then #ligia - jan/2012

       if (lr_entrada.c24astcod = 'S66'  or
           lr_entrada.c24astcod = 'S67') then

           if (lr_entrada.c24astcod = 'S66'  ) and
              (l_atdetpcod          = 1   or
               l_atdetpcod          = 2   or
               l_atdetpcod          = 3   or
               l_atdetpcod          = 4      ) then

              let l_resultado = 1
           else
              if l_atdetpcod = 1 or
                 l_atdetpcod = 3 then
                 let l_resultado = 1
              else
                 let l_resultado = 2
              end if
           end if
       else
           if l_atdetpcod = 1 or
              l_atdetpcod = 3 then
              let l_resultado = 1
           else
              let l_resultado = 2
           end if
       end if
    else
       # Valida Benefício PET, considera os servicos Nao Liberado (2)  e servicos Acionados (3).--##
       if lr_entrada.c24astcod = 'PE1' then
          if l_atdetpcod  = 2 or
             l_atdetpcod  = 3 then
             let l_resultado = 1
          else
             let l_resultado = 2
          end if
       else
           ##-- Para envio de socorro, considera os servicos Acionados (4). --##
           if l_atdetpcod = 4 then
              let l_resultado = 1
           else
              let l_resultado = 2
           end if
       end if    
    end if
 end if
 close c_cta02m15_003

 return l_resultado, l_mensagem

end function


## -- Conta qtd de servico utilizado para o beneficio PET -- ##


#----------------------------------------#
function cta02m15_qtd_servico_pet(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,bnfnum    like datrligsau.bnfnum
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cta02m15_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a quantidade de servicos  realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig).      --##


 
    
        if lr_entrada.aplnumdig is not null then
            open ccta02m15005 using lr_entrada.ramcod
                                   ,lr_entrada.succod
                                   ,lr_entrada.aplnumdig
                                
        
            foreach ccta02m15005 into lr_servico.*
                 ##-- Consiste o servico para considera-lo na contagem --##
                 call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                              ,lr_servico.atdsrvano
                                              ,lr_entrada.c24astcod
                                              ,lr_entrada.clcdat)
                 returning l_resultado, l_mensagem
        
                 if l_resultado = 1 then
                    let l_qtd  = l_qtd + 1
                 else
                    if l_resultado = 3 then
                       let l_mensagem = "Sistema indisponivel no momento por favor tente mais tarde"
                       exit foreach
                    end if
                 end if
            end foreach
            close ccta02m15005
        end if
    

 return l_qtd, l_mensagem, l_resultado

end function

