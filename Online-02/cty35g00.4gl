#=============================================================================#
# Porto Seguro Cia Seguros Gerais                                             #
# ............................................................................#
# Modulo........: cty35g00                                                    #
# Analista Resp.: Kleiton Nascimento                                          #
# Desenv........: Sergio Vidotto                                              #
# Objetivo......: Funçoes para implementação de Right Fax                     #
#=============================================================================#
# Desenvolvimento: Intera Sergio Vidotto                                      #
#=============================================================================#
#                        * * * Alteracoes * * *                               #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_flag_montou_estrutura char(1)

#-----------------------------------------------------------------------------#
#Parametros Recebidos para geração do xml Enviado ao Transporter
#-----------------------------------------------------------------------------#
#report          : Tag do tipo generator que indica a criação de um relatório.
#service         : Nome do serviço que solicita a geração de um relatório.
#serviceType     : Tipo do serviço a ser executado.
#                  Valores válidos .
#                  * GENERATOR: para a geração de relatório.
#                  * CLEANNESS: para a limpeza ou remoção de arquivos .
#                  * APPENDER : para a concatenação de arquivos
#typeOfConnection: Tipo de conexão de execução.
#                  Valores de typeOfConnection.
#                  * jdbc: Gera relatório com conexão ao banco de dados
#                  * xml: Gera relatório a partir do XML informado
#fileSystem      : Caminho da rede no qual encontra-se o arquivo jasper.
#jasperFileName  : Nome do arquivo jasper utilizado na geração do relatório.
#outFileName     : Nome do arquivo a ser gerado.
#outFileType     : Tipo da extensão do arquivo a ser gerado.
#recordPath      : Caminho da estrutura de dados dentro do XML.
#                  Obrigatório se o “serviceType” tiver o valor “GENERATOR” e
#                  “typeOfConnection” tiver o valor “xml”.
#outbox          : Caminho da rede no qual será salvo o arquivo gerado.
#                  Caso inexistente, a estrutura informada será criada.
#generatorTIFF   : Opção para geração de arquivo TIFF se for solicitada a geração
#                  de um PDF.
#-----------------------------------------------------------------------------#
#Parametros Retornados xml Gerado                    by Saymon
#-----------------------------------------------------------------------------#

function cty35g00_monta_estrutura_jasper(lr_param,l_nomexml)

   define lr_param         record
        service            char(10)
       ,serviceType        char(10)
       ,typeOfConnection   char(3)
       ,fileSystem         char(100)
       ,jasperFileName     char(50)
       ,outFileName        char(100)
       ,outFileType        char(3)
       ,recordPath         char(100)
       ,aplicacao          char(30)
       ,outbox             char(100)
       ,generatorTIFF      smallint
   end record

   define l_docHandle    integer
   define l_caminho      char(200)
   define l_nomexml      char(200)

   call figrc011RF_novo_xml("report") returning l_docHandle

   let l_caminho = "/report"
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/service"          clipped,lr_param.service          clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/serviceType"      clipped,lr_param.serviceType      clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/typeOfConnection" clipped,lr_param.typeOfConnection clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/fileSystem"       clipped,lr_param.fileSystem       clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/jasperFileName"   clipped,lr_param.jasperFileName   clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/outFileName"      clipped,lr_param.outFileName      clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/outFileType"      clipped,lr_param.outFileType      clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/recordPath"       clipped,lr_param.recordPath       clipped)
   if lr_param.generatorTIFF = true then
      call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/generatorTIFF"    clipped,"true"    clipped)
   else
      call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/generatorTIFF"    clipped,"false"    clipped)
   end if
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/aplicacao"        clipped,lr_param.aplicacao clipped)
   call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped || "/outbox"           clipped,lr_param.outbox       clipped)

   let m_flag_montou_estrutura = "S"

   return l_docHandle

end function

function cty35g00_envia_fax(l_docHandle,lr_fax)

   define l_docHandle    integer
   define l_xmlfax       char(32766)

   define lr_param_out      record
          codigo            smallint
        , mensagem          char(200)
   end    record

   define lr_fax             record
          ddd                char(3)
         ,telefone           char(16)
         ,destinatario 	     char(30)
         ,notas              char(30)
         ,caminhoarq         char(100)
         ,sistema            char(100)
         ,geratif            smallint
   end record


   define lr_retornoFax   record
          idFax		   integer,
          codigoErro	   smallint,
          status		   smallint,
          mensagem	   char(150),
          sucesso		   char(5)
   end record

   initialize lr_param_out to null 

   if m_flag_montou_estrutura = "S" then
      let l_xmlFax = figrc011RF_retorna_xml_gerado(l_docHandle) clipped
      let l_xmlFax = cty35g00_limpa_cabecalho(l_xmlFax,'<?xml version="1.0"?>','')

		  call figrc011RF_generatorfax(l_xmlFax              clipped
		                              ,lr_fax.telefone       clipped
		                              ,lr_fax.destinatario   clipped
		                              ,lr_fax.notas          clipped
		                              ,lr_fax.caminhoarq     clipped
		                              ,lr_fax.sistema        clipped
		                              ,lr_fax.geratif)
        returning lr_retornoFax.idFax
                  ,lr_retornoFax.codigoErro
                  ,lr_retornoFax.status
                  ,lr_retornoFax.mensagem
                  ,lr_retornoFax.sucesso
                  
        let lr_param_out.codigo = lr_retornoFax.codigoErro
        let lr_param_out.mensagem = lr_retornoFax.mensagem

      call figrc011RF_fim_novo_xml(l_docHandle)

   else
      let m_flag_montou_estrutura = "N"
      let lr_param_out.codigo   = 999
      let lr_param_out.mensagem = "Estrutura não montada"
   end if

   return lr_param_out.codigo
         ,lr_param_out.mensagem


end function


function cty35g00_atualiza_xml_jasper(l_docHandle,l_chave,l_valor)

 define	l_docHandle    integer,
         l_chave        char(500),
         l_valor        char(32766)

 let l_chave = "/report/data"||l_chave clipped
 display "l_chave : ",l_chave clipped
 display "l_valor : ",l_valor clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_chave clipped ,l_valor clipped)

end function

function cty35g00_limpa_cabecalho(l_str, l_ori, l_dest)

     define

     l_dest                  char(100)
    ,l_f                     integer
    ,l_f2                    integer
    ,l_f3                    integer
    ,l_f4                    integer
    ,l_i                     integer
    ,l_str                   char(32000)
    ,l_ori                   char(200)

     let  l_f  = length(l_ori)               # <- Tamanho Substring pesquisada
     let  l_f2 = (length(l_str) - l_f) + 1   # <- Limite de Pesquisa na String
     let  l_f3 = l_f - 1                     # <- Qtde.Bytes Substring Origem
     let  l_f4 = length(l_dest)              # <- Qtde.Bytes Substring Destino
     let  l_i  = 0

     while (l_i <= l_f2)

          let  l_i = l_i + 1

          if   l_str[l_i, (l_i + l_f3)] = l_ori
          then
               if   l_i > 1
               then
                    let  l_str = l_str[1, (l_i-1)]
                               , l_dest clipped
                               , l_str[(l_i + l_f3 + 1), 32000]
               else
                    let  l_str = l_dest clipped
                               , l_str[(l_i + l_f3 + 1), 32000]
               end  if

               let  l_i  = l_i + (l_f4 - 1)          # <- Recalc. Posicao Atual
               let  l_f2 = (length(l_str) - l_f) + 1 # <- Recalc. Posicao Final
          end  if
     end  while

     return l_str

end  function
