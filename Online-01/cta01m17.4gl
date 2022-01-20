#############################################################################
# Nome do Modulo: CTA01M17                                         Ruiz     #
#                                                                  Sergio   #
# Valores de IS da apolice da Azul Seguros                         Dez/2006 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/12/2006  psi205206    Sergio       mostrar valores de IS apol Azul     #
#---------------------------------------------------------------------------#

database porto

#------------------------#
 function cta01m17(l_par)
#------------------------#

     define lr_is record
                      imsmda         char(03),
                      autimsvlr      like abbmcasco.imsvlr,
                      imsvlr         like abbmbli.imsvlr,      
                      dmtimsvlr      like abbmdm.imsvlr,    
                      dpsimsvlr      like abbmdp.imsvlr,    
                      imsmorvlr      like abbmapp.imsmorvlr,
                      imsinvvlr      like abbmapp.imsinvvlr,
                      imsdmhvlr      like abbmapp.imsdmhvlr,
                      franqvlr       decimal(9,2)
                  end record
 
     define l_par integer,
            prompt_key char (01)

     initialize lr_is.* to null
     let prompt_key  =  null
     
     call cts40g02_extraiDoXML(l_par,'IS')
          returning lr_is.autimsvlr,
                    lr_is.imsvlr,   
                    lr_is.dmtimsvlr,  
                    lr_is.dpsimsvlr,
                    lr_is.imsmorvlr,
                    lr_is.imsinvvlr,
                    lr_is.imsdmhvlr,
                    lr_is.franqvlr
     
     if  lr_is.autimsvlr is not null or  
         lr_is.imsvlr    is not null or
         lr_is.dmtimsvlr is not null or
         lr_is.dpsimsvlr is not null or
         lr_is.imsmorvlr is not null or
         lr_is.imsinvvlr is not null or
         lr_is.imsdmhvlr is not null or      
         lr_is.franqvlr  is not null then    
         
         open window cta01m17 at 08,11 with form "cta01m17"
              attribute(form line first, border)
              
              display lr_is.autimsvlr to autimsvlr
              display lr_is.imsvlr    to imsvlr   
              display lr_is.dmtimsvlr to dmtimsvlr
              display lr_is.dpsimsvlr to dpsimsvlr
              display lr_is.imsmorvlr to imsmorvlr
              display lr_is.imsinvvlr to imsinvvlr
              display lr_is.imsdmhvlr to imsdmhvlr
              display lr_is.franqvlr  to franqvlr  
              
              prompt " (F17)Abandona" for prompt_key              

         close window cta01m17
         
     else
         error 'Nenhuma Importancias encontrada.'
         sleep 2
     end if
     
 end function
