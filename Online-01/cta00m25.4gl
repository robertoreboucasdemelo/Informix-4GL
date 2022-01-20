#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m25.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Dados do Endereco PSS                                      #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 04/03/2010                                                #
#............................................................................#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"

#------------------------------------------------------------------------------
function cta00m25_endereco_pss(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   pesnum like gsakpes.pesnum
end record

define lr_aux record
   sqlcode   smallint,
   aux_qtd   smallint
end record

define lr_retorno record
   endlgdtip  like gsakpesend.endlgdtip   ,
   endlgd     like gsakpesend.endlgd      ,
   endnum     like gsakpesend.endnum      ,
   endcmp     like gsakpesend.endcmp      ,
   endcep     like gsakpesend.endcep      ,
   endcepcmp  like gsakpesend.endcepcmp   ,
   endbrr     like gsakpesend.endbrr      ,
   endcid     like gsakpesend.endcid      ,
   endufd     like gsakpesend.endufd
end record

initialize lr_retorno.* ,
           lr_aux.*   to null

 #call osgtf550_busca_enderecos_pesnum(lr_param.pesnum)
 #returning lr_aux.sqlcode,lr_aux.aux_qtd
 #
 #if lr_aux.aux_qtd > 0 then
 #
 #  let lr_retorno.endlgdtip  =  ga_enderecos[1].endlgdtip
 #  let lr_retorno.endlgd     =  ga_enderecos[1].endlgd
 #  let lr_retorno.endnum     =  ga_enderecos[1].endnum
 #  let lr_retorno.endcmp     =  ga_enderecos[1].endcmp
 #  let lr_retorno.endcep     =  ga_enderecos[1].endcep
 #  let lr_retorno.endcepcmp  =  ga_enderecos[1].endcepcmp
 #  let lr_retorno.endbrr     =  ga_enderecos[1].endbrr
 #  let lr_retorno.endcid     =  ga_enderecos[1].endcid
 #  let lr_retorno.endufd     =  ga_enderecos[1].endufd
 #
 #  let lr_retorno.endlgd = lr_retorno.endlgdtip clipped, " ", lr_retorno.endlgd
 #else
 #  let lr_retorno.endlgd = "***** SEM ENDERECO *****"
 #end if
  call osgtf550_pesquisa_pesnum_endereco(lr_param.pesnum)
  returning lr_aux.sqlcode
  if lr_aux.sqlcode = 0 then
     let lr_retorno.endlgdtip  = g_r_endereco.endlgdtip
     let lr_retorno.endlgd     = g_r_endereco.endlgd
     let lr_retorno.endnum     = g_r_endereco.endnum
     let lr_retorno.endcmp     = g_r_endereco.endcmp
     let lr_retorno.endcep     = g_r_endereco.endcep
     let lr_retorno.endcepcmp  = g_r_endereco.endcepcmp
     let lr_retorno.endbrr     = g_r_endereco.endbrr
     let lr_retorno.endcid     = g_r_endereco.endcid
     let lr_retorno.endufd     = g_r_endereco.endufd
    let lr_retorno.endlgd = lr_retorno.endlgd
  else
    let lr_retorno.endlgd = "***** SEM ENDERECO *****"
  end if
return lr_retorno.endlgdtip    ,
       lr_retorno.endlgd       ,
       lr_retorno.endnum       ,
       lr_retorno.endcmp       ,
       lr_retorno.endufd       ,
       lr_retorno.endbrr       ,
       lr_retorno.endcid       ,
       lr_retorno.endcep       ,
       lr_retorno.endcepcmp
end function

#------------------------------------------------------------------------------
function cta00m25_carrega_global(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   endlgdtip  like gsakpesend.endlgdtip   ,
   endlgd     like gsakpesend.endlgd      ,
   endnum     like gsakpesend.endnum      ,
   endcmp     like gsakpesend.endcmp      ,
   endufd     like gsakpesend.endufd      ,
   endbrr     like gsakpesend.endbrr      ,
   endcid     like gsakpesend.endcid      ,
   endcep     like gsakpesend.endcep      ,
   endcepcmp  like gsakpesend.endcepcmp
end record

initialize g_pss_endereco.*   to null

let g_pss_endereco.lgdtip     = lr_param.endlgdtip
let g_pss_endereco.lgdnom     = lr_param.endlgd
let g_pss_endereco.lgdnum     = lr_param.endnum
let g_pss_endereco.endcmp     = lr_param.endcmp
let g_pss_endereco.ufdcod     = lr_param.endufd
let g_pss_endereco.brrnom     = lr_param.endbrr
let g_pss_endereco.cidnom     = lr_param.endcid
let g_pss_endereco.lgdcep     = lr_param.endcep
let g_pss_endereco.lgdcepcmp  = lr_param.endcepcmp


end function
