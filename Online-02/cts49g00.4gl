###############################################################################
# Nome do Modulo: CTS49G00 - Limites p/ KM Atd. de Guincho - Azul Seguros     #
#                                                                             #
# Analista      : Carla Rampazzo                                  OUT/2009    #
#                                                                             #
# Funcao que define limite de KM / Quantidade de Atendimento de Guincho       #
# para quando as informacoes nao foram enviadas no arquivo de Carga da Azul   #
# Valido somente para quando houver a Clausula 37 contratada                  #
###############################################################################
# Alteracoes:                                                                 #
# DATA       SOLICITACAO RESPONSAVEL    DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 21/11/2009             Carla Rampazzo Tratar novas Clausulas:               #
#                                       37A: Assist.24h - Rede Referenciada   #
#                                       37B: Assist.24h - Livre Escolha       #
#-----------------------------------------------------------------------------#
# 05/02/2010             Carla Rampazzo Tratar nova Clausula:                 #
#                                       37C : Assist.24h - Assit.Gratuita     #
#-----------------------------------------------------------------------------#
# 19/07/2010             Carla Rampazzo Tratar Clausula 37A e 37B:            #
#                                       KM Guincho de: 250 p/ 400             #
#-----------------------------------------------------------------------------#
# 12/09/2012 Fornax-Hamilton PSI-2012-16125/EV - Inclusao da tratativa das    #
#                                                clausulas 37D e 37F          #
#-----------------------------------------------------------------------------#

database porto

#------------------------------------------------------------------
function cts49g00_clausulas(l_doc_handle)
#------------------------------------------------------------------

   define l_doc_handle integer

   define la_clausula array[20] of record
           clscod      like aackcls.clscod
   end record

   define lr_retorno       record
          kmlimite         smallint
         ,guincho_qtd      integer
   end record

   define l_qtd_end   smallint
   define l_ind       smallint
   define l_aux_char  char(100)
   define l_descricao char(50)
   define l_valor     dec(15,5)
   define l_emsdat    date

   initialize l_qtd_end  ,
              l_ind      ,
              l_valor    ,
              l_descricao,
              l_aux_char ,
              l_emsdat   to null

   initialize lr_retorno.* to null

   for l_ind  =  1  to  20
      initialize  la_clausula[l_ind].*    to  null
   end for

   let l_qtd_end = figrc011_xpath
                  (l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

   for l_ind = 1 to l_qtd_end
      let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
      let la_clausula[l_ind].clscod = figrc011_xpath(l_doc_handle,l_aux_char)


      if la_clausula[l_ind].clscod = "037" or
         la_clausula[l_ind].clscod = "37A" or
         la_clausula[l_ind].clscod = "37B" or
         la_clausula[l_ind].clscod = "37C" or
         la_clausula[l_ind].clscod = "37D" or     #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37F" or     #--> PSI-2012-16125/EV
         la_clausula[l_ind].clscod = "37H" then 
          
         call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_GUINCHO')
                                   returning lr_retorno.kmlimite
                                            ,lr_retorno.guincho_qtd
         
         ##Obter a Data de Emissao da Apolice                        
          call cts40g02_extraiDoXML(l_doc_handle, "APOLICE_EMISSAO") 
               returning l_emsdat                            
         
        

	 if lr_retorno.kmlimite    is null or
	    lr_retorno.kmlimite    =  0    or
	    lr_retorno.guincho_qtd is null or
	    lr_retorno.guincho_qtd =  0    then

            ---> Busca Tipo de Assistencia
            call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_DESCRICAO')
                 returning l_descricao
            if l_descricao = "ASSISTENCIA PLUS II"            or
               l_descricao = "ASSISTENCIAPLUS II"             or
               l_descricao = "ASSISTENCIA PLUSII"             or
               l_descricao = "ASSISTENCIA REDE REFERENCIADA"  or
               l_descricao = "ASSISTENCIAREDE REFERENCIADA"   or
               l_descricao = "ASSISTENCIA REDEREFERENCIADA"   or
               la_clausula[l_ind].clscod = "37D"              then #PSI-2012-16125/EV
               let lr_retorno.kmlimite    = 400
               let lr_retorno.guincho_qtd = 999
            end if

            if l_descricao = "ASSISTENCIA LIVRE ESCOLHA"           or
               l_descricao = "ASSISTENCIALIVRE ESCOLHA"            or
               l_descricao = "ASSISTENCIA LIVREESCOLHA"            or
               l_descricao = "ASSISTENCIA PLUS II - LIVRE ESCOLHA" or
               l_descricao = "ASSISTENCIAPLUS II - LIVRE ESCOLHA"  or
               l_descricao = "ASSISTENCIA PLUSII - LIVRE ESCOLHA"  or
               l_descricao = "ASSISTENCIA PLUS II- LIVRE ESCOLHA"  or
               l_descricao = "ASSISTENCIA PLUS II -LIVRE ESCOLHA"  or
               l_descricao = "ASSISTENCIA PLUS II - LIVREESCOLHA"  or
               la_clausula[l_ind].clscod = "37F"                   then #PSI-2012-16125/EV
               let lr_retorno.kmlimite    = 400
               let lr_retorno.guincho_qtd = 3
            end if

            if l_descricao = "ASSISTENCIA GRATUITA" or
               l_descricao = "ASSISTENCIAGRATUITA"  then
               let lr_retorno.kmlimite    = 100
               let lr_retorno.guincho_qtd = 2
            end if  
            
            if la_clausula[l_ind].clscod = "37H"    then 
               let lr_retorno.kmlimite    = 400  
               
               if l_emsdat >= "01/09/2013" then       
                   let lr_retorno.guincho_qtd  = 3                          
               else                                            
               	  let lr_retorno.guincho_qtd  = 999                         
               end if 	     	                                 
               
            end if
         end if

         exit for
      end if
   end for

   return lr_retorno.*

end function
