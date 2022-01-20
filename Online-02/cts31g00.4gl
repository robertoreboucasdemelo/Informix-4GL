#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts31g00                                                   #
# Analista Resp : Priscila Staingel                                          #
# PSI           : 195.138                                                    #
#                 Exibir popup da dbskesp                                    #
#                 Apresentar uma popup com as especialidades cadastrados     #
#                                                                            #
# Desenvolvedor  : Priscila Staingel                                         #
# DATA           : 20/10/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------#
# 06/06/2008 Carla Rampazzo    Nao mostrar error/display qdo chamada for     #
#                              pelo Portal do Segurado                       #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


database porto

#-------------------------------------#
function cts31g00_lista_especialidade()
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
        espcod         like dbskesp.espcod,
        espdes         like dbskesp.espdes
 end record

 initialize lr_popup, lr_retorno to  null

 let lr_popup.lin    = 6
 let lr_popup.col    = 2
 let lr_popup.titulo = "ESPECIALIDADES"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Descricao"
 let lr_popup.tipcod = "A"
 let lr_popup.cmd_sql = "select espcod, espdes ",
                        "  from dbskesp ",
                        "  where espsit = 'A' ",
                        " order by 2 "
 let lr_popup.tipo   = "D"

 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*

 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
       let lr_retorno.espcod = null
       let lr_retorno.espdes = null
    else
       let lr_retorno.erro = 3
    end if
 end if

 let int_flag = false

 return lr_retorno.*

end function



#-------------------------------------#
function cts31g00_descricao_esp(param)
#-------------------------------------#
 define param        record
    espcod        like dbskesp.espcod,
    espsit        like dbskesp.espsit
 end record

 define l_espdes  like dbskesp.espdes

 define l_com_sql  char(200)
 let     l_espdes  =  null
 let     l_com_sql  =  null

 let l_com_sql = "select espdes ",
             " from dbskesp ",
             " where espcod = ?"
 if param.espsit is not null then
    let l_com_sql = l_com_sql clipped, " and espsit = ?"
 end if

 prepare pcts31g00001 from l_com_sql
 declare ccts31g00001 cursor for pcts31g00001

 if param.espsit is not null then
     open ccts31g00001 using param.espcod,
                             param.espsit
 else
     open ccts31g00001 using param.espcod
 end if
 whenever error continue
 fetch ccts31g00001 into l_espdes
 whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then  #notfound
         let l_espdes = null
     else
        ---> Mostra mensagem de error so se a chamada for pelo Informix
        if g_origem is null or
           g_origem = "IFX" then
           error "Erro ao localizar descricao especialidade"
        end if
     end if
  end if

 return l_espdes

end function

#------------------------------------#
function cts31g00_qtde_especialidade(l_flag)
#------------------------------------#
 #Busca a quantidade de especialidade de acordo
 # com a flag solicitada A, C ou null
 define l_flag char(1)

 define l_qtde  smallint
 define l_com_sql  char(100)

 let l_qtde    =  null
 let l_com_sql =  null

 let l_com_sql = "select count(*) from dbskesp "
 if l_flag is not null then
      let l_com_sql = l_com_sql clipped, "  where espsit = ? "
 end if

 prepare p_cts31g00_001 from l_com_sql
 declare c_cts31g00_001 cursor for p_cts31g00_001

 if l_flag is not null then
    open c_cts31g00_001  using l_flag
 else
    open c_cts31g00_001
 end if
 whenever error continue
 fetch c_cts31g00_001 into l_qtde
 whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then  #notfound
         let l_qtde = 0
     else
         error "Erro ao ler tabela de especialidade"
     end if
  end if

  return l_qtde

end function


#------------------------------------#
function cts31g00_situacao(l_espcod)
#------------------------------------#
  define l_espcod like dbskesp.espcod

  define l_espsit  like dbskesp.espsit
  define l_com_sql  char(100)

 let l_espsit    =  null
 let l_com_sql =  null

 let l_com_sql = "select espsit from dbskesp ",
                 "  where espcod = ?         "

 prepare p_cts31g00_002 from l_com_sql
 declare c_cts31g00_002 cursor for p_cts31g00_002

 open c_cts31g00_002  using l_espcod
 whenever error continue
 fetch c_cts31g00_002 into l_espsit
 whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then  #notfound
         let l_espsit = null
     else
         error "Erro ao ler tabela de especialidade"
     end if
  end if

  return l_espsit

end function
