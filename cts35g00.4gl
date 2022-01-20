#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts35g00                                                   #
# Analista Resp : Priscila Staingel                                          #
# PSI           : 195.138                                                    #
#                 Exibir popup da datksrvtip                                 #
#                 Apresentar uma popup com os tipos de servico e descricao   #
#                                                                            #
# Desenvolvedor  : Priscila Staingel                                         #
# DATA           : 16/11/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#
database porto

#-------------------------------------#
function cts35g00_lista_origem_servico()
#-------------------------------------#

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
        atdsrvorg      like datksrvtip.atdsrvorg,
        srvtipdes      like datksrvtip.srvtipdes
 end record

 initialize lr_popup, lr_retorno to  null

 let lr_popup.lin    = 6
 let lr_popup.col    = 2
 let lr_popup.titulo = "CODIGO ORIGEM"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Descricao"
 let lr_popup.tipcod = "A"
 let lr_popup.cmd_sql = "select atdsrvorg, srvtipdes ",
                        "  from datksrvtip ",
                        "  order by 1 "
 let lr_popup.tipo   = "D"

 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*

 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
       let lr_retorno.atdsrvorg = null
       let lr_retorno.srvtipdes = null
    else
       let lr_retorno.erro = 3
    end if
 end if

 let int_flag = false

 return lr_retorno.*

end function


#-------------------------------------#
function cts35g00_descricao_orig_servico(param)
#-------------------------------------#
 define param        record
    atdsrvorg        like datksrvtip.atdsrvorg
 end record

 define l_retorno    record
    ret        smallint,
    mensagem   char(100),
    srvtipdes  like datksrvtip.srvtipdes
 end record

 define l_com_sql  char(200)
 
 initialize l_retorno.* to null

 let     l_retorno.srvtipdes  =  null
 let     l_com_sql  =  null

 let l_com_sql = "select srvtipdes ",
             " from datksrvtip ",
             " where atdsrvorg = ?"

 prepare pcts35g00001 from l_com_sql
 declare ccts35g00001 cursor for pcts35g00001

 open ccts35g00001 using param.atdsrvorg
 whenever error continue
 fetch ccts35g00001 into l_retorno.srvtipdes
 whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then  #notfound
         let l_retorno.ret = 1
         let l_retorno.mensagem = "Nao encontrado descricao para esse codigo de servico"
     else
         let l_retorno.ret = 2
         let l_retorno.mensagem = "Erro ",sqlca.sqlcode," ao localizar descricao codigo de origem"
     end if
  else
     let l_retorno.ret = 0
  end if

 return l_retorno.*

end function
