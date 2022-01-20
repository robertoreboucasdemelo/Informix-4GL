#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: cts40g26                                                   #
# ANALISTA RESP..: Ligia Mattge - 21/12/2007                                  #
# PSI/OSF........:                                                            #
#                  Obtem a IS da apolice de Auto/Azul atraves do nr servico   #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

function cts40g26_obter_is_apol(l_atdsrvnum, l_atdsrvano, l_ciaempcod)

  define l_atdsrvnum  like datmservico.atdsrvnum,
         l_atdsrvano  like datmservico.atdsrvano,
         l_ciaempcod  like datmservico.ciaempcod,
         l_res        smallint,
         l_msg        char(60),
         l_lignum     like datmligacao.lignum,
         l_succod     like datrligapol.succod,
         l_ramcod     like datrligapol.ramcod,
         l_aplnumdig  like datrligapol.aplnumdig,
         l_itmnumdig  like datrligapol.itmnumdig,
         l_edsnumref  like datrligapol.edsnumref,
         l_imsvlr     like abbmcasco.imsvlr,
         l_doc_handle integer

  define lr_is        record
         imsmda       char(03),
         autimsvlr    like abbmcasco.imsvlr,
         imsvlr       like abbmbli.imsvlr,
         dmtimsvlr    like abbmdm.imsvlr,
         dpsimsvlr    like abbmdp.imsvlr,
         imsmorvlr    like abbmapp.imsmorvlr,
         imsinvvlr    like abbmapp.imsinvvlr,
         imsdmhvlr    like abbmapp.imsdmhvlr,
         franqvlr     decimal(9,2)
         end record

  let l_res    = null
  let l_msg    = null
  let l_lignum = null
  let l_succod     = null
  let l_ramcod     = null
  let l_aplnumdig  = null
  let l_itmnumdig  = null
  let l_edsnumref  = null
  let l_imsvlr     = 0
  let l_doc_handle = null

  initialize lr_is.* to null

  ## obter a 1a ligacao
  call ctd06g00_pri_ligacao(3,l_atdsrvnum, l_atdsrvano)
       returning l_res,l_msg, l_lignum

  if l_res <> 1 then
     return l_res, l_msg, l_imsvlr
  end if

  ## obter a apolice
  call ctd14g00_apol_lig(1, l_lignum)
       returning l_res, l_msg, l_succod, l_ramcod,
                 l_aplnumdig, l_itmnumdig, l_edsnumref

  if l_res <> 1 then  ##Somente para atendimento sem documento
     let l_res = 1
     return l_res, l_msg, l_imsvlr
  end if

  if l_ramcod <> 531 then ## Somente para ramo Auto
     let l_res = 1
     return l_res, l_msg, l_imsvlr
  end if

  if l_ciaempcod = 1 then ## Porto Seguro

     ## obter a IS da  apolice
     call cty05g04_dados_casco(1,l_succod, l_aplnumdig, l_itmnumdig)
          returning l_res,l_msg, l_imsvlr

     if l_res <> 1 then
        return l_res, l_msg, l_imsvlr
     end if

  else
     if l_ciaempcod = 35 then ## Azul Seguros

        call cts42g00_doc_handle(l_succod, l_ramcod,
                                 l_aplnumdig, l_itmnumdig,
                                 l_edsnumref)
             returning l_res, l_msg, l_doc_handle

        if l_res <> 1 then
           return l_res, l_msg, l_imsvlr
        end if

        call cts40g02_extraiDoXML(l_doc_handle,'IS')
             returning lr_is.autimsvlr,
                       lr_is.imsvlr,
                       lr_is.dmtimsvlr,
                       lr_is.dpsimsvlr,
                       lr_is.imsmorvlr,
                       lr_is.imsinvvlr,
                       lr_is.imsdmhvlr,
                       lr_is.franqvlr

        let l_imsvlr = lr_is.imsvlr

     end if

  end if
  return l_res, l_msg, l_imsvlr

end function
