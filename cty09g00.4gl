#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty09g00                                                   #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Exibir popup da iddkdominio                                #
#                 Apresentar uma popup com os departamentos cadastrados      #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 21/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

#---------------------------------------------#
function cty09g00_popup_iddkdominio(l_cponom)
#---------------------------------------------#
 define l_cponom      like iddkdominio.cponom
 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record
 define lr_retorno     record
        erro           smallint,
        cpocod         like iddkdominio.cpocod,
        cpodes         like iddkdominio.cpodes
 end record
 initialize lr_retorno.*  to  null
 if (l_cponom is not null) and (l_cponom <> " ") then

    initialize lr_popup.*    to  null
    let lr_popup.lin    = 6
    let lr_popup.col    = 2
    let lr_popup.titulo = "Dominio (", l_cponom clipped, ")"
    let lr_popup.tit2   = "Codigo"
    let lr_popup.tit3   = "Descricao"
    let lr_popup.tipcod = "A"
    let lr_popup.cmd_sql = "select cpocod, cpodes ",
                           "  from iddkdominio ",
                           " where cponom = '", l_cponom, "'",
                           " order by cpodes "
    let lr_popup.tipo   = "D"
    call ofgrc001_popup(lr_popup.*)
         returning lr_retorno.*
    if lr_retorno.erro = 0 then
       let lr_retorno.erro = 1
    else
       if lr_retorno.erro = 1 then
          let lr_retorno.erro = 2
       else
          let lr_retorno.erro = 3
       end if
    end if
    let int_flag = false
 end if
 return lr_retorno.*
end function

#-----------------------------------#
function cty09g00_popup_isskdepto()
#-----------------------------------#
 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record
 define lr_retorno     record
        erro           smallint,
        dptsgl         like isskdepto.dptsgl,
        dptnom         like isskdepto.dptnom
 end record
 initialize lr_popup.*  to  null
 initialize lr_retorno.*  to  null
 let lr_popup.lin    = 6
 let lr_popup.col    = 2
 let lr_popup.titulo = "DEPARTAMENTOS"
 let lr_popup.tit2   = "Sigla"
 let lr_popup.tit3   = "Descricao"
 let lr_popup.tipcod = "A"
 let lr_popup.cmd_sql = "select dptsgl, dptnom ",
                        "  from isskdepto ",
                        " order by 2 "
 let lr_popup.tipo   = "D"
 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*
 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
    else
       let lr_retorno.erro = 3
    end if
 end if
 let int_flag = false
 return lr_retorno.*
end function



