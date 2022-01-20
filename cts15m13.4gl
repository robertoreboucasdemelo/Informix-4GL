#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hrs                                             #
# Modulo.........: cts15m13                                                  #
# Objetivo.......: Verificar se determinda apolice possui o beneficio do ar  #
#                  condicionado veicular numa locacao (h10)                  #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 15/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI        Alteracao                              #
# --------   ------------- ------     ---------------------------------------#
# 01/10/2008 Amilton, Meta Psi 223689  Incluir tratamento de erro com a      #
#                                         global                             #
#                                                                            #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/figrc072.4gl"   --> 223689

#-----------------------------------------#
 function cts15m13_ver_ar_cond(lr_param)
#-----------------------------------------#

  define lr_param record
                  succod       like datrligapol.succod
                 ,aplnumdig    like datrligapol.aplnumdig
                 ,dctnumseq    like abbmdoc.dctnumseq
                 ,itmnumdig    like datrligapol.itmnumdig
                 ,edsnumref    like datrligapol.edsnumref
                  end record

  define l_clcdat      like apbmcasco.clcdat
        ,l_viginc      like abbmclaus.viginc
        ,l_concede_ar  smallint
        ,l_cod_erro    integer  # (0) OK    <> (0) ERRO DE ACESSO

  let l_clcdat         = null
  let l_viginc         = null
  let l_concede_ar     = false
  let l_cod_erro       = 0

  #Busca a data de calculo da apolice
    
  call figrc072_setTratarIsolamento()        --> 223689 
  
  call faemc603_apolice(lr_param.succod
                       ,lr_param.aplnumdig
                       ,lr_param.dctnumseq
                       ,lr_param.itmnumdig)
  returning l_clcdat
  
                                 
       if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
           error "Função faemc603 indisponivel no momento! Avise a Informatica !" sleep 2            
           return l_cod_erro,
                  l_concede_ar                      
        end if        -- > 223689                                 
                                 

  #Busca a vigencia inicial da apolice
  call faemc053_pesquisa_viginc(lr_param.succod, lr_param.aplnumdig)
       returning l_cod_erro,
                 l_viginc

  if l_cod_erro <> 0 and
     l_cod_erro <> notfound then
     let l_cod_erro = 2
  else
     let l_concede_ar = false
     #Aplica a regra para verificar se a apolice
     #Podera usufruir o beneficio do veiculo c/ar condicionado
     if l_clcdat >= "01/01/2006" and
        l_viginc >= "01/01/2006" then
        #Veiculo com ar condicionado, permitido
        let l_concede_ar = true
     else
        #Verifica se a apolice possui endosso
        if lr_param.edsnumref <> 0 and
           lr_param.edsnumref is not null then
           #Verifica os endossos da apolice, procurando uma inclusao da clausula 26
           if faemc053_benef_endosso(lr_param.succod
                                    ,lr_param.aplnumdig
                                    ,lr_param.itmnumdig) then
              #Veiculo com ar condicionado, permitido
              let l_concede_ar = true
           end if
        end if
     end if
  end if

  return l_cod_erro
        ,l_concede_ar

 end function
