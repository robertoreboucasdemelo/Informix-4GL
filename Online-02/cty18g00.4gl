#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty18g00.4gl                                               #
# Analista Resp : Jorge Modena                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter dados da apolice                                     #
#                 Consistir o item da apolice                                #
#............................................................................#
# Desenvolvimento: Jorge Modena                                              #
# Liberacao      : 26/10/2009                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob2.4gl"

define m_prep_sql   smallint
      ,m_msg        char(200)
      ,m_msg_erro2  char(200)
      ,m_msg_erro3  char(200)


#----------------------------------------------------------------------------#
function cty18g00_prepare()
#----------------------------------------------------------------------------#

# -> Query para contar qtd de itens da apólice

  define l_sql        char(200)

  let l_sql = " select count(*)       "
             ,"  from abbmitem        "
             ,"  where succod    = ?  "
             ,"  and aplnumdig = ?    "

  prepare pcty18g00001  from l_sql
  declare ccty18g00001  cursor for pcty18g00001

  let m_prep_sql = true

end function

# Resultado
# 1 ---> Validacao OK
# 2 ---> Validacao nao atendeu a alguma regra de negocio
# 3 ---> Problemas durante a validacao (Problemas Informix) ou parametros nulos



#----------------------------------------------------------------------------#
# recebe  codigo sucursal, item e numero apolice
# retorna mensagem para fila mq

function cty18g00_valida_apolice_AUTO (lr_param)
#----------------------------------------------------------------------------#

  define lr_param         record
          succod          like abamapol.succod
         ,aplnumdig       like abamapol.aplnumdig
         ,itmnumdig       like abbmdoc.itmnumdig
         ,ramcod          like gtakram.ramcod
  end record

  define lr_cty18g00     record
         resultado       smallint
        ,mensagem        char(42)
        ,emsdat          like abamdoc.emsdat
        ,aplstt          like abamapol.aplstt
        ,vigfnl          like abamapol.vigfnl
        ,etpnumdig       like abamapol.etpnumdig
  end record

  define lr_itens           record
          qtd_itens_apolice  integer
         ,resultado          integer
         ,mensagem           char(200)
  end record


  define lr_retorno          record
          resultado          integer
         ,mensagem           char(200)
  end record

  define lr_retorno_segurado record
       erro                  smallint              ,
       mens                  char(70)              ,
       cgccpfnum             like gsakpes.cgccpfnum,
       cgcord                like gsakpes.cgcord   ,
       cgccpfdig             like gsakpes.cgccpfdig,
       pesnom                like gsakpes.pesnom   ,
       pestip                like gsakpes.pestip
  end record

  define lr_vigencia record
       inicial  like abamapol.viginc,
       final    like abamapol.vigfnl
  end record
  define lr_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
  end record

  define l_pet record
         retorno  char(200),
         qtd      integer  ,
         sql      char(200),
         qtd_vtg  integer  ,
         data_vig date
  end record
  initialize l_pet.*       to null
  initialize lr_cty18g00.* to null

  initialize lr_retorno.*  to null

  initialize lr_funapol.*  to null

  initialize lr_vigencia.* to null
  let lr_cty18g00.resultado = 1


  let  m_msg_erro2 = "Não foi localizada apólice Ativa! "
                    ,"Indicar contato com Corretor de Seguro"

  let m_msg_erro3 = "Sistema indisponivel no momento,por favor,tente mais tarde"



  #------------------------------------------------------
  #   Obter dados da apolice de auto
  #------------------------------------------------------

  call cty05g00_dados_apolice(lr_param.succod
                             ,lr_param.aplnumdig)

  returning lr_cty18g00.*


  if lr_cty18g00.resultado = 3 then
      call errorlog(lr_cty18g00.mensagem)
      let lr_retorno.resultado = lr_cty18g00.resultado
      let lr_retorno.mensagem =  m_msg_erro3
      return lr_retorno.*
#      display lr_cty18g00.mensagem
  else
    if lr_cty18g00.resultado = 2 then
       call errorlog(lr_cty18g00.mensagem)
       let lr_retorno.resultado = lr_cty18g00.resultado
       let lr_retorno.mensagem =  m_msg_erro2
       return lr_retorno.*
#       display lr_cty18g00.mensagem
    end if
  end if



  if lr_cty18g00.emsdat is null then
     call errorlog('Apolice do ramo AUTOMOVEL nao cadastrada! ')
     let lr_retorno.resultado = lr_cty18g00.resultado
     let lr_retorno.mensagem = m_msg_erro2
     return lr_retorno.*
#     display "Apolice do ramo AUTOMOVEL nao cadastrada!"
  end if

  ## -- recupera ultima situacao da apolice -- ##

  call f_funapol_ultima_situacao
      (lr_param.succod, lr_param.aplnumdig, lr_param.itmnumdig)
  returning lr_funapol.*


  #--------------------------------------------------
  # Validacao Data Final Vigencia e Status Apolice
  #--------------------------------------------------

  if lr_cty18g00.vigfnl < today or lr_cty18g00.aplstt = "C" then
     let lr_retorno.resultado = 2
     if lr_cty18g00.aplstt = "C" and
        lr_cty18g00.vigfnl < today then
        call errorlog('Esta apolice esta vencida e cancelada')
        #display  "Esta apolice esta vencida e cancelada"
     else
         if lr_cty18g00.aplstt = "C" then
            call errorlog('Esta apolice esta cancelada')
       #     display  "Esta apolice esta cancelada"
         else
            call errorlog('Esta apolice esta vencida')
          #  display  "Esta apolice esta vencida"
         end if
     end if
     let lr_retorno.mensagem = m_msg_erro2
     return lr_retorno.*
  end if

  #----------------------------------------------------
  #   Consiste item passado como parametro
  #----------------------------------------------------

  call cty05g00_consiste_item(lr_param.succod
                             ,lr_param.aplnumdig
                             ,lr_param.itmnumdig)
  returning  lr_retorno.resultado

  if lr_retorno.resultado  <> 1 then
     if lr_retorno.resultado == 2 then
        call errorlog('Item da apolice AUTOMOVEL nao encontrada!')
        let lr_retorno.mensagem  = m_msg_erro2
        return lr_retorno.*
        display  "Item da apolice AUTOMOVEL nao encontrada!"
     else
       let lr_retorno.mensagem  = m_msg_erro3
       return lr_retorno.*
     end if
  end if



  #---------------------------------------------------
  #  Validacao Apolice 33,35,33R e 35R
  #---------------------------------------------------


  whenever error continue

  select clscod
   from abbmclaus
   where aplnumdig = lr_param.aplnumdig   and
         succod    = lr_param.succod      and
         itmnumdig = lr_param.itmnumdig   and
         dctnumseq = lr_funapol.dctnumseq and
         clscod in ('033','035','33R','35R','044','44R','047','47R')

  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "Apolice nao possui a clausula de direito ao beneficio PET"

     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem  = m_msg_erro3
        let m_msg =  "ERRO ", sqlca.sqlcode, " em abbmclaus -  cty18g00_valida_apólice_Auto "
        call errorlog(m_msg)

     end if
     return lr_retorno.*
  end if


  #----------------------------------------------------------------------
  #   Obter tipo cliente apolice (Pessoa Fisica ou Juridica)
  #----------------------------------------------------------------------

  call  cty18g00_localiza_dados_segurado_apolice(lr_param.succod
                                                ,lr_param.ramcod
                                                ,lr_param.aplnumdig
                                                ,lr_param.itmnumdig)
  returning lr_retorno_segurado.*,
            lr_vigencia.inicial,
            lr_vigencia.final

  # -- apolice de Pessoa Fisica nao vai mais realizar contagem de item -- #
  # -- 02/12/2009                                                      -- #

  #if lr_retorno_segurado.pestip = 'F'  then


  #----------------------------------------------------------------------
  #   Obter quantidade itens possui apólice
  #----------------------------------------------------------------------
  #   call cty18g00_qtd_itens_apolice(lr_param.succod
  #                                  ,lr_param.aplnumdig)
  #   returning lr_itens.*


  #   if lr_itens.resultado = 3 then
  #       call errorlog(lr_itens.mensagem)
  #       let lr_retorno.mensagem =  lr_itens.mensagem
  #       let lr_retorno.resultado = lr_itens.resultado
  #       return lr_retorno.*

  #   else
  #     if lr_itens.resultado = 2 then
  #        call errorlog(lr_itens.mensagem)
  #        let lr_retorno.mensagem =  lr_itens.mensagem
  #        let lr_retorno.resultado = lr_itens.resultado
  #       return lr_retorno.*
  #     end if
  #   end if

  #   if lr_itens.qtd_itens_apolice > 4 then
  #     call errorlog("Apolice possui " + lr_itens.qtd_itens_apolice)
  #     let lr_retorno.mensagem =  "Apolice não possui direito ao Beneficio PET"
  #     let lr_retorno.resultado = 2
  #     return lr_retorno.*
  #   end if

  #else
     if lr_retorno_segurado.pestip = 'J' then
        let lr_retorno.mensagem =  "Apolice PESSOA JURIDICA nao possui direito ao Beneficio PET."
        let lr_retorno.resultado = 2
        return lr_retorno.*
     end if
  #end if

  call cta00m06_pet_vantagens()
  returning l_pet.retorno, l_pet.qtd, l_pet.data_vig

  #------------------------------------------------------------------
  #  Validacao Vantagem -->> retirado no PSI CARRO + CASA - COMPLETO
  #------------------------------------------------------------------

  # -- Clausula 033       - Codigo Vantagem 4022 Trocar codigo no PSI
  # -- Clausula 33R       - Codigo Vantagem 4189 Trocar codigo no PSI
  # -- Clausula 035 e 35R - Codigo Vantagem 3778 Trocar codigo no PSI
  # Codigo de Vantagens correto agora é o 7838 implementado na datkdominio com
  # Chave pet_vantagens
  let l_pet.qtd_vtg  = 0
  if l_pet.qtd > 0 and
     lr_vigencia.inicial >= l_pet.data_vig then  ## Consistir Data de emissão ou Data de calculo das Apólices para PET.
                                                ## Verificar a data de corte
     let l_pet.sql = ' select count(*)           '
                    ,'  from  abbmvtg            '
                    ,'  where aplnumdig = ? and  '
                    ,'        succod    = ? and  '
                    ,'        itmnumdig = ? and  '
                    ,'        dctnumseq = ?      '
                    ,'  and   vtgcod in ', l_pet.retorno
     prepare pcty18g00003  from l_pet.sql
     declare ccty18g00003  cursor for pcty18g00003
     open ccty18g00003 using lr_param.aplnumdig  ,
                             lr_param.succod     ,
                             lr_param.itmnumdig  ,
                             lr_funapol.dctnumseq
     whenever error continue
     fetch ccty18g00003 into l_pet.qtd_vtg
        whenever error stop
        if l_pet.qtd_vtg = 0 then
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Apolice nao possui beneficio PET"
        end if
        return lr_retorno.*

     close ccty18g00003
  end if
  return lr_retorno.*
end function


#----------------------------------------------------------------------------#
#-- verifica se ramo é válido --#
#-- recebe codigo do ramo    --#

function cty18g00_valida_ramo(lr_param)
#----------------------------------------------------------------------------#
  define lr_param         record
          ramcod          like gtakramo.ramcod
  end record

  define lr_retorno          record
          resultado          integer
         ,mensagem           char(200)
  end record

  initialize lr_retorno.* to null


  whenever error continue

  select ramcod
   from gtakramo
   where ramcod = lr_param.ramcod

  whenever error continue


  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem  = "PARAMETRO DE ENTRADA (RAMO) NAO CADASTRADO."

     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem  = m_msg_erro3
        let m_msg = "ERRO ", sqlca.sqlcode, " em gtakramo - cty18g00_valida_ramo"
        call errorlog(m_msg)

     end if
  end if


  return lr_retorno.*

end function



#----------------------------------------------------------------------------#
#-- verifica dados de segurado              --#
#-- recebe apólice, ramo, sucursal e item   --#

function cty18g00_localiza_dados_segurado_apolice(lr_param)
#----------------------------------------------------------------------------#

define lr_param record
  succod    like gabksuc.succod          ,
  ramcod    like gtakram.ramcod          ,
  aplnumdig like abamdoc.aplnumdig       ,
  itmnumdig like abbmveic.itmnumdig
end record

define lr_dados_apol record
  erro      smallint                      ,
  segnumdig like abbmdoc.segnumdig        ,
  pesnum    like gsakpes.pesnum           ,
  viginc    like abamapol.viginc          ,
  vigfnl    like abamapol.vigfnl
end record


define lr_retorno record
       erro      smallint              ,
       mens      char(70)              ,
       cgccpfnum like gsakpes.cgccpfnum,
       cgcord    like gsakpes.cgcord   ,
       cgccpfdig like gsakpes.cgccpfdig,
       pesnom    like gsakpes.pesnom   ,
       pestip    like gsakpes.pestip
end record

 define lr_funapol   record
    resultado       char(01),
    dctnumseq       decimal(04,00),
    vclsitatu       decimal(04,00),
    autsitatu       decimal(04,00),
    dmtsitatu       decimal(04,00),
    dpssitatu       decimal(04,00),
    appsitatu       decimal(04,00),
    vidsitatu       decimal(04,00)
 end record

initialize lr_dados_apol.* to null
initialize lr_retorno.* to null
initialize lr_funapol.* to null


      # Obter Dados da Apolice de Auto

      call f_funapol_ultima_situacao
      (lr_param.succod, lr_param.aplnumdig, lr_param.itmnumdig)
       returning lr_funapol.*

      whenever error continue

      select segnumdig,
             viginc,
             vigfnl
        into lr_dados_apol.segnumdig,
             lr_dados_apol.viginc,
             lr_dados_apol.vigfnl
        from abbmdoc
        where abbmdoc.succod    =  lr_param.succod      and
              abbmdoc.aplnumdig =  lr_param.aplnumdig   and
              abbmdoc.itmnumdig =  lr_param.itmnumdig   and
              abbmdoc.dctnumseq =  lr_funapol.dctnumseq

      whenever error stop

      if sqlca.sqlcode = 0 then

            call osgtf550_busca_pesnum_por_unfclisegcod(lr_dados_apol.segnumdig)
            returning lr_retorno.erro,
                      lr_dados_apol.pesnum

            if lr_retorno.erro = 100 then
              call osgtk1001_pesquisarSeguradoPorCodigo(lr_dados_apol.segnumdig)
              returning lr_retorno.erro

              if lr_retorno.erro = 0 then
                  let lr_retorno.cgccpfnum = g_r_gsakseg.cgccpfnum
                  let lr_retorno.cgcord    = g_r_gsakseg.cgcord
                  let lr_retorno.cgccpfdig = g_r_gsakseg.cgccpfdig
                  let lr_retorno.pesnom    = g_r_gsakseg.segnom
                  let lr_retorno.pestip    = g_r_gsakseg.pestip
              end if
            else
               if lr_retorno.erro = 0 then
                    call osgtf550_busca_cliente_por_pesnum(lr_dados_apol.pesnum)
                    returning lr_retorno.erro

                    if lr_retorno.erro = 0 then
                       let lr_retorno.cgccpfnum = gr_gsakpes.cgccpfnum
                       let lr_retorno.cgcord    = gr_gsakpes.cgcord
                       let lr_retorno.cgccpfdig = gr_gsakpes.cgccpfdig
                       let lr_retorno.pesnom    = gr_gsakpes.pesnom
                       let lr_retorno.pestip    = gr_gsakpes.pestip
                    end if
               end if
            end if
      end if

      if lr_retorno.cgccpfnum is null then
         let lr_retorno.mens = "Dados da Apolice nao Encontrada"
         let lr_retorno.erro = 1
      else
         let lr_retorno.erro = 0
      end if


      return lr_retorno.*,
             lr_dados_apol.viginc,
             lr_dados_apol.vigfnl
end function

#----------------------------------------------------------------------------#
#-- faz a contagem de qtd itens apolice possui --#
#-- recebe codigo sucursal e numero apolice    --#

function cty18g00_qtd_itens_apolice (lr_param)
#----------------------------------------------------------------------------#

  define lr_param         record
          succod          like abamapol.succod
         ,aplnumdig       like abamapol.aplnumdig
  end record

  define lr_retorno          record
          qtd_itens_apolice  integer
         ,resultado          integer
         ,mensagem           char(200)
  end record

  initialize lr_retorno.* to null


   if m_prep_sql is null or
      m_prep_sql <> true then
      call cty18g00_prepare()
   end if



   if lr_param.succod    is not null and
      lr_param.aplnumdig is not null then

      open ccty18g00001 using lr_param.succod
                             ,lr_param.aplnumdig

      whenever error continue
      fetch ccty18g00001 into lr_retorno.qtd_itens_apolice
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Apolice do segurado nao encontrada"

         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em abbmitem"
            let m_msg = " ERRO SQL SELECT - ccty18g00001 "
                        ,sqlca.sqlcode," / ",sqlca.sqlerrd[2]
            call errorlog(m_msg)
            let m_msg = " cty18g00_qtd_itens_apolice() / ",lr_param.succod, " / "
                                                          ,lr_param.aplnumdig

            call errorlog(m_msg)
         end if
      end if
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem = "Parametros nulos"
   end if

   return lr_retorno.*

end function



