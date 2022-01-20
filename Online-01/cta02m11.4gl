###############################################################################
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                      #
#.............................................................................#
# Sistema        : ATENDIMENTO SEGURADO                                       #
# Modulo         : cta02m11                                                   #
#                  Verifica se o atendente tem permissao de utilizar um       #
#                  assunto ou assunto nao requer permissao alguma             #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 188425                                                     #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
# Data       Autor Fabrica        PSI    Alteracao                            #
# ---------- -------------------  ------ -------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
# 23/11/2004 Katiucia         CT 263281  Ajuste liberacao atendente pelo Apoio#
#-----------------------------------------------------------------------------#
# 08/02/2006 Priscila         Zeladoria  Buscar data e hora do banco de dados #
#-----------------------------------------------------------------------------#
# 29/12/2009 Patricia W.                 Projeto SUCCOD - Smallint            #
#-----------------------------------------------------------------------------#

database porto

#------------------------------------------------------------------------------
function cta02m11_permissao(lr_cta01m1101)
#------------------------------------------------------------------------------

define lr_cta01m1101   record
   c24astcod           like datkassunto.c24astcod
  ,empcod              like isskfunc.empcod
  ,funmat              like isskfunc.funmat
  ,maqsgl              like ismkmaq.maqsgl
  ,succod              like abamapol.succod
  ,ramcod              like gtakram.ramcod
  ,aplnumdig           like abamapol.aplnumdig
  ,itmnumdig           like abbmdoc.itmnumdig
  ,prporg              like rsdmdocto.prporg
  ,prpnumdig           like rsdmdocto.prpnumdig
  ,fcapacorg           like datrligpac.fcapacorg
  ,fcapacnum           like datrligpac.fcapacnum
  ,cmnnumdig           like pptmcmn.cmnnumdig
end record

define l_flag      smallint
define l_result    smallint
define l_msg       char(80)
define l_funsnh    char(14)
define l_chave     char(14)
define l_chavex    char(15)
define l_grlinf    char(25)
define l_erro      smallint
define l_confirma  char(01)
define l_linha1    char(40)
define l_linha2    char(40)
define l_linha3    char(40)
define l_linha4    char(40)
define l_data      date
define l_hora      datetime hour to second
define l_documento char(25)
define l_empcodchar char(02)
define l_funmatchar char(06)

   call cts40g03_data_hora_banco(1)
       returning l_data, l_hora

   let l_flag = 0
   let l_result = 0
   let l_msg = ""
   let l_funsnh = ""
   let l_chave = ""
   let l_chavex = ""
   let l_grlinf = ""
   let l_erro = 0
   let l_confirma = ""
   let l_linha1 = ""
   let l_linha2 = ""
   let l_linha3 = ""
   let l_linha4 = ""
   #let l_data = today
   #let l_hora = current
   let l_documento = ""

   #Obter a consistencia da permissaodo assunto
   call cts19g00_permissao_assunto(lr_cta01m1101.c24astcod
                                  ,lr_cta01m1101.empcod
                                  ,lr_cta01m1101.funmat)
        returning l_result, l_msg
   #Se assunto nao necessita de permissao ou atendente tem permissao para
   #utilizacao
   if l_result = 1 then
      let l_flag = 1
      return l_flag
   end if
   #Se ocorreu erro de banco
   if l_result = 3 then
      error l_msg
      sleep 1
      let l_flag = 3
      return l_flag
   end if
   let l_result = 0
   let l_msg = ""
   #Obter senha do funcionario
   call cts19g00_obter_senha(lr_cta01m1101.empcod
                            ,lr_cta01m1101.funmat)
        returning l_result, l_msg, l_funsnh

   #Se funcionario tem permissao
   if l_result = 1 then
      let l_flag = 1
      return l_flag
   end if
   #Se ocorreu erro
   if l_result = 3 then
      error l_msg
      sleep 1
      let l_flag = 3
      return l_flag
   end if
   #Se funcionario nao tem permissao, gravar as informacoes necessarias para
   #entrar em contato com o apoio
   #Montar a chave no formato 'ct24effffffmmm', onde e = empcod
   #ffffff = funmat, mmm = maqsgl
   # -- CT 263281 - Katiucia -- #
   let l_empcodchar = lr_cta01m1101.empcod
   let l_funmatchar = lr_cta01m1101.funmat
   let l_chave = "ct24"
                 ,l_empcodchar clipped
                 ,l_funmatchar clipped
                 ,lr_cta01m1101.maqsgl clipped

   let l_chavex = l_chave clipped, 'X' clipped
   let l_result = 0
   let l_msg = ""

   #Obter apoio de acordo com a chave montada
   call cta12m00_seleciona_datkgeral(l_chave)
        returning l_result, l_msg, l_grlinf
   #Se achou o apoio
   if l_result = 1 then
      #Obtem a senha do funcionario de apoio
      call cts19g00_obter_senha(l_grlinf[4,5]
                               ,l_grlinf[6,11])
           returning l_result, l_msg, l_funsnh

      #Se funcionario de apoio tem permissao
      if l_result = 1 then
         if l_funsnh = l_grlinf[12,25] then
            let l_msg = ""
            #Remove a chave do funcionario
            call cta12m00_remove_datkgeral(l_chave)
                 returning l_erro, l_msg
            let l_msg = ""
            #Remove achave do funcionario apoio
            call cta12m00_remove_datkgeral(l_chavex)
                 returning l_erro, l_msg
         else
            let l_linha1 = "Codigo de assunto necessita de permissao"
            let l_linha2 = "para atendimento, contate a fila de APOIO."
            let l_linha3 = "Voce esta na maquina ",lr_cta01m1101.maqsgl
            let l_linha4 = ""
            let l_confirma = cts08g01("A", "N", l_linha1, l_linha2, l_linha3,l_linha4)
            let l_flag = 2
            return l_flag
         end if
         let l_flag = 1
         return l_flag
      end if
      #Se funcionario de apoio nao tem permissao
      if l_result = 2 then
         let l_linha1 = "Matricula de Apoio nao tem"
         let l_linha2 = "permissao para liberar atendimento,"
         let l_linha3 = "entre em contato com afila de Apoio."
         let l_linha4 = ""
         let l_confirma = cts08g01("A", "N", l_linha1, l_linha2, l_linha3,l_linha4)
         let l_flag = 2
         return l_flag
      end if
   end if

   #Se a matricula nao eh de apoio
   if l_result = 2 then
      let l_result = 0
      let l_msg = ""
      call cta12m00_inclui_datkgeral(l_chave
                                    ,lr_cta01m1101.c24astcod
                                    ,l_data
                                    ,l_hora
                                    ,lr_cta01m1101.empcod
                                    ,lr_cta01m1101.funmat)
           returning l_result, l_msg
      if l_result <> 1 then
         error l_msg
         sleep 1
         let l_flag = 3
         return l_flag
      end if
      #Para documento informado: apolice
      if lr_cta01m1101.aplnumdig is not null then
         let l_documento = "A" clipped
                          ,lr_cta01m1101.succod using "#####"  #"##" #projeto succod
                          ,lr_cta01m1101.ramcod using "###"
                          ,lr_cta01m1101.aplnumdig using "#########"
                          ,lr_cta01m1101.itmnumdig using "#######"
      end if
      #Para documento informado: proposta
      if lr_cta01m1101.prpnumdig is not null then
         let l_documento = "P" clipped
                          ,lr_cta01m1101.prporg using "&&"
                          ,lr_cta01m1101.prpnumdig using "&&&&&&&&&"
      end if
      #Para documento informado: numero do PAC
      if lr_cta01m1101.fcapacnum is not null then
         let l_documento = "F" clipped
                          ,lr_cta01m1101.fcapacorg using "&&"
                          ,lr_cta01m1101.fcapacnum using "&&&&&&&&&"
      end if
      #Para documento informado: contrato do Alarmes Monitorados
      if lr_cta01m1101.cmnnumdig is not null then
         let l_documento = "C" clipped
                          ,lr_cta01m1101.cmnnumdig
      end if
      #Para atendimento com algum documento informado, gravar na datkgeral
      if l_documento is not null then
         let l_result = 0
         let l_msg = ""
         call cta12m00_inclui_datkgeral(l_chavex
                                       ,l_documento
                                       ,l_data
                                       ,l_hora
                                       ,lr_cta01m1101.empcod
                                       ,lr_cta01m1101.funmat)
              returning l_result, l_msg
         if l_result <> 1 then
            error l_msg
            sleep 1
            let l_flag = 3
            return l_flag
         end if
      end if
      let l_linha1 = "Entrar em contato com a fila de"
      let l_linha2 = "APOIO para liberacao do atendimento"
      let l_linha3 = "Voce esta na maquina ",lr_cta01m1101.maqsgl
      let l_linha4 = ""
      let l_confirma = cts08g01("A","N",l_linha1,l_linha2,l_linha3,l_linha4)
      let l_flag = 2
      return l_flag
   end if
   #Se ocorreu erro de banco
   if l_result = 3 then
      let l_flag = 3
      return l_flag
   end if

end function #cta02m11_permissao



