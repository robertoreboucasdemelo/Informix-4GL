#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty37g00                                                    #
# Objetivo.......: Controlador de Alertas Itau                                 #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 03/11/2014                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint
define m_acesso  smallint

#----------------------------------------------#
 function cty37g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = ' select cpodes           '
          ,  '  from datkdominio        '
          ,  '  where cponom = ?        '
          ,  '  order by cpocod         '
  prepare pcty37g00001 from l_sql
  declare ccty37g00001 cursor for pcty37g00001

  let m_prepare = true

end function


#----------------------------------------------------#
 function cty37g00_valida_alerta_problema(lr_param)
#----------------------------------------------------#

define lr_param record
  itaclisgmcod   like datkitaclisgm.itaclisgmcod  ,
  c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod      
end record

define lr_retorno record
  chave        char(20)
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty37g00_prepare()
    end if


    #--------------------------------------------------------
    # Verifica Alerta do Segmento
    #--------------------------------------------------------

    let lr_retorno.chave = ctc91m35_monta_chave(lr_param.itaclisgmcod, lr_param.c24pbmgrpcod)

    call cty37g00_recupera_alerta(lr_retorno.chave)
    
    
end function

#----------------------------------------------------#
 function cty37g00_valida_alerta_assunto(lr_param)
#----------------------------------------------------#

define lr_param record
  itaclisgmcod   like datkitaclisgm.itaclisgmcod  ,
  c24astcod      like datkassunto.c24astcod         
end record

define lr_retorno record
  chave        char(20)
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty37g00_prepare()
    end if


    #--------------------------------------------------------
    # Verifica Alerta do Segmento
    #--------------------------------------------------------

    let lr_retorno.chave = ctc91m31_monta_chave(lr_param.itaclisgmcod, lr_param.c24astcod)

    call cty37g00_recupera_alerta(lr_retorno.chave)
    
    
end function


#------------------------------------------------------------#
 function cty37g00_valida_alerta_assistencia(lr_param)
#------------------------------------------------------------#

define lr_param record
  itaclisgmcod  like datkitaclisgm.itaclisgmcod  ,
  asimtvcod     like datkasimtv.asimtvcod         
end record

define lr_retorno record
  chave        char(20)
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty37g00_prepare()
    end if


    #--------------------------------------------------------
    # Verifica Alerta do Segmento
    #--------------------------------------------------------

    let lr_retorno.chave = ctc91m32_monta_chave(lr_param.itaclisgmcod, lr_param.asimtvcod)

    call cty37g00_recupera_alerta(lr_retorno.chave)
    
    
end function

#------------------------------------------------------------#
 function cty37g00_valida_alerta_motivo(lr_param)
#------------------------------------------------------------#

define lr_param record
  itaclisgmcod  like datkitaclisgm.itaclisgmcod  ,
  asimtvcod     like datkasimtv.asimtvcod         
end record

define lr_retorno record
  chave        char(20)
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty37g00_prepare()
    end if


    #--------------------------------------------------------
    # Verifica Alerta do Segmento
    #--------------------------------------------------------

    let lr_retorno.chave = ctc91m37_monta_chave(lr_param.itaclisgmcod, lr_param.asimtvcod)

    call cty37g00_recupera_alerta(lr_retorno.chave)
    
    
end function

#----------------------------------------------#
 function cty37g00_recupera_alerta(lr_param)
#----------------------------------------------#

define lr_param record
  chave        char(20)
end record

define lr_retorno record
  acesso       smallint,
  confirma     char(01),
  linha1       char(40),
  linha2       char(40),
  linha3       char(40),
  linha4       char(40)
end record

define la_cty37g00 array[04] of record
      linha char(40)
end record

define arr_aux     smallint

initialize lr_retorno.* to null

for  arr_aux  =  1  to  04
   initialize  la_cty37g00[arr_aux].* to  null
end  for

let arr_aux = 1

    #--------------------------------------------------------
    # Recupera os Dados do Alerta
    #--------------------------------------------------------


    open ccty37g00001  using  lr_param.chave
    foreach ccty37g00001 into la_cty37g00[arr_aux].linha

        let arr_aux = arr_aux + 1

    end foreach

    let lr_retorno.linha1 = la_cty37g00[1].linha
    let lr_retorno.linha2 = la_cty37g00[2].linha
    let lr_retorno.linha3 = la_cty37g00[3].linha
    let lr_retorno.linha4 = la_cty37g00[4].linha

    if lr_retorno.linha1 is not null or
       lr_retorno.linha2 is not null or
       lr_retorno.linha3 is not null or
       lr_retorno.linha4 is not null then


       call cts08g01("A","N",lr_retorno.linha1
                            ,lr_retorno.linha2
                            ,lr_retorno.linha3
                            ,lr_retorno.linha4)
       returning lr_retorno.confirma


    end if


end function

