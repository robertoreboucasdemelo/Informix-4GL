#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts34g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 195138                                                     #
#                 Verifica se o acionamento automatico esta ativo ou nao     #
#                                                                            #
# Desenvolvedor  : Priscila Staingel                                         #
# DATA           : 26/10/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 02/06/2006 Priscila Staingel PSI198714  servicos de origem 2 e 3 sao       #
#                                         sempre acionados via internet      #
#----------------------------------------------------------------------------#
# 10/11/2006 Priscila Staingel AS         chamar funcao em ctd01g00 para     #
#                                         verificar cidade sede              #
#----------------------------------------------------------------------------#

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

function cts34g00_acion_auto(l_param)

   define l_param record
          atdsrvorg    like datmservico.atdsrvorg,
          cidnom       like datmlcl.cidnom,
          ufdcod       like datmlcl.ufdcod
          end record

   define l_resultado      smallint,
          l_mensagem       char(80),
          l_atmacnprtcod like datkatmacnprt.atmacnprtcod,
          l_netacnflg    like datkatmacnprt.netacnflg,
          l_mpacidcod    like datkmpacid.mpacidcod,
          l_mpacrglgdflg like datkmpacid.mpacrglgdflg,
          l_gpsacngrpcod like datkmpacid.gpsacngrpcod,
          l_acnsttflg    like datracncid.acnsttflg,
          l_cidcod       like glakcid.cidcod,
          l_cidsedcod    like datrcidsed.cidsedcod ,
          l_acionamento  smallint,
          l_lclltt       like datmlcl.lclltt ,
          l_lcllgt       like datmlcl.lcllgt,
          l_tipacnsrv    like datkmpacid.gpsacngrpcod 
         

   let l_acionamento = true
   let l_resultado = null
   let l_mensagem  = null
   let l_atmacnprtcod = null
   let l_netacnflg    = null
   let l_mpacidcod    = null
   let l_mpacrglgdflg = null
   let l_gpsacngrpcod = null
   let l_acnsttflg    = null
   let l_cidcod       = null
   let l_cidsedcod    = null
   let l_lclltt       = null
   let l_lcllgt       = null
   let l_tipacnsrv    = null

   call cts32g00_busca_codigo_acionamento(l_param.atdsrvorg)
        returning l_resultado,
                  l_atmacnprtcod,
                  l_netacnflg

   if l_resultado <> 0 then ## Se deu notfound na parametrizacao
      let g_motivo      = "PROBLEMA NO ACESSO AOS PARAMETROS DO ACIONAMENTO."
      let l_acionamento = false
      return l_acionamento
   end if

   call cts23g00_inf_cidade(2, " ", l_param.cidnom, l_param.ufdcod)
        returning l_resultado,
                  l_mpacidcod,
                  l_lclltt,
                  l_lcllgt,
                  l_mpacrglgdflg,
                  l_gpsacngrpcod

   if l_resultado <> 0 then ## Se deu notfound ou erro
      let g_motivo      = "INFORMAÇÔES DA CIDADE NAO ENCONTRADA."
      let l_acionamento = false
      return l_acionamento
   end if
   
   #-------------------------------------------------
   #BUSCA TIPO DE ACIONAMENTO POR ORIGEM DO SERVICO
   #-------------------------------------------------
     whenever error continue 
  
       select gpsacngrpcod into l_tipacnsrv
         from datrorgcidacntip
           where mpacidcod = l_mpacidcod
             and atdsrvorg = l_param.atdsrvorg
     
       #Sistema considera Tipo de Acioanamento se tiver cadastro para origem informada
       if sqlca.sqlcode == 0   then 
          if  l_tipacnsrv is not null then                          
             let l_gpsacngrpcod = l_tipacnsrv
          end if
       end if
     whenever error stop    
   

   #servicos com origem 2 (assistencia passageiros) ou
   #             origem 3 (hospedagem)
   #sao sempre enviados pela internet
   if l_param.atdsrvorg = 2 or
      l_param.atdsrvorg = 3 then
      let l_gpsacngrpcod = 0
   end if

   if l_gpsacngrpcod = 0 then  #qdo funcao retorna 0 - internet
      if l_netacnflg = "I" then ## Se acionamento internet Inativo
         let g_motivo = "ACIONAMENTO INTERNET DESATIVADO."
         let l_acionamento = false
      end if
      return l_acionamento
   else
      #descobrir codigo da cidade
      call cty10g00_obter_cidcod(l_param.cidnom, l_param.ufdcod)
           returning l_resultado, l_mensagem, l_cidcod

      if l_resultado <> 0 or l_cidcod is null then
         let g_motivo      = "CODIGO DA CIDADE NAO ENCONTRADA."
         let l_acionamento = false
         return l_acionamento
      end if

      # decobrir codigo da cidade sede
      #Priscila - AS - 10/11/06
      #call cts34g01_cidsedcod (l_cidcod) returning l_cidsedcod
      call ctd01g00_obter_cidsedcod(1, l_cidcod)
           returning l_resultado, l_mensagem, l_cidsedcod

      if l_cidsedcod is null then
         let g_motivo      = "PRESTADOR RECEBE POR FAX."
         let l_acionamento = false
         return l_acionamento
      end if

      # buscar codigo sede no grupo
      #buscar grupo para codigo parametro de acionamento
      call cts32g00_verifica_grupo_acionamento(l_atmacnprtcod, l_cidsedcod)
           returning l_resultado, l_acnsttflg
      if l_resultado = 0 then
         if l_acnsttflg = "I" then
            let l_acionamento = false
         end if
         let g_motivo      = "RELACAO CIDADE ACIONAMENTO NAO ENCONTRADA."
      else
        #caso nao exista a cidade nos parametros do acionamento e
        # o grupo (gpsacngrpcod) está com 1 (GPS), iremos acionar
        # o servico via internet.
        # Pois há cidades, como curitiba que recebe servicos via GPS apenas
        # para auto, para re o servico é acionado via internet
        if l_netacnflg = "I" then ## Se acionamento internet Inativo
            let l_acionamento = false
            let g_motivo = "INTERNET INATIVA NO MOMENTO."
        else
            let l_acionamento = true
        end if
      end if
   end if

   return l_acionamento

end function
