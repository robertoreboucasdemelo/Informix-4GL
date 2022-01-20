#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts32g00                                                   #
# Analista Resp : Priscila Staingel                                          #
# PSI           : 195.138                                                    #
#                 Acesso a tabela datkatmacnprt e datracncid                 #
#                 Acesso aos parametros do acionamento automatico            #
#                                                                            #
# Desenvolvedor  : Priscila Staingel                                         #
# DATA           : 20/10/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 02/07/2008  Carla Rampazzo              g_origem identifica quem chama:    #
#                                         "IFX"/null=Informix / "WEB"=Portal #
#----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"
#---------------------------------------------------------------------------#
function cts32g00_busca_codigo_acionamento(param)
#---------------------------------------------------------------------------#
 define param record
    atdsrvorg like datkatmacnprt.atdsrvorg
 end record

 define lr_retorno record
    ret  smallint,
    atmacnprtcod  like datkatmacnprt.atmacnprtcod,
    netacnflg     like datkatmacnprt.netacnflg
 end record

 define l_com_sql  char(500)

 initialize lr_retorno to null
 let lr_retorno.ret = 0

 #seleciona o parametro do servico para a maior data de vigencia
 let  l_com_sql = "select atmacnprtcod, netacnflg                 ",
                  " from datkatmacnprt                            ",
                  " where atdsrvorg = ?                           ",
                  "  and vigincdat = (select max(vigincdat)       ",
                  "                    from datkatmacnprt         ",
                  "                    where atdsrvorg = ?)       "

 prepare p_cts32g00_001 from l_com_sql
 declare c_cts32g00_001 cursor for p_cts32g00_001

 open c_cts32g00_001 using param.atdsrvorg, param.atdsrvorg
 whenever error continue
 fetch c_cts32g00_001 into lr_retorno.atmacnprtcod
                     ,lr_retorno.netacnflg
 whenever error stop

  if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then  #notfound
       let lr_retorno.ret = 1
    else
       let lr_retorno.ret = 2
       if g_origem is null   or
          g_origem =  "IFX"  then
          error "Problemas ao ler parametros acionamento ", sqlca.sqlcode
       end if
    end if
  end if
  return lr_retorno.*

end function


#---------------------------------------------------------------------------#
function cts32g00_verifica_grupo_acionamento(param)
#---------------------------------------------------------------------------#
 define param record
    atmacnprtcod like datkatmacnprt.atmacnprtcod,
    cidcod       like datracncid.cidcod
 end record

 define l_com_sql  char(200)

 define l_acnsttflg like datracncid.acnsttflg
 define l_ret smallint
 let l_com_sql = null
 let l_acnsttflg = null

 let l_com_sql = "select acnsttflg        ",
                 " from datracncid        ",
                 " where atmacnprtcod = ? ",
                 "   and cidcod       = ? "

 prepare pcts32g00002 from l_com_sql
 declare ccts32g00002 cursor for pcts32g00002

 open ccts32g00002 using param.atmacnprtcod,
                        param.cidcod
 whenever error continue
 fetch ccts32g00002 into l_acnsttflg
 whenever error stop
 let l_ret = sqlca.sqlcode

 if l_ret <> 0 then
     if l_ret = 100 then #notfound
        let l_ret = 1
     else
        let l_ret = 2
        if g_origem is null   or
           g_origem =  "IFX"  then
           error "Erro ao acessar a tabela datracncid, erro: "
                 ,sqlca.sqlcode
        end if
     end if
 end if

 return l_ret, l_acnsttflg

end function

#---------------------------------------------------------------------------#
function cts32g00_dados_cid_ac(param)
#---------------------------------------------------------------------------#
 define param record
    nivel_ret     smallint,
    atmacnprtcod  like datracncid.atmacnprtcod,
    cidcod        like datracncid.cidcod
 end record

 define lr_retorno record
    res            smallint,
    msg            char(50),
    atdprvtmp     like datracncid.atdprvtmp
 end record

 define l_com_sql  char(500)

 initialize lr_retorno to null

 let  l_com_sql = "select atdprvtmp from datracncid ",
                  " where atmacnprtcod = ", param.atmacnprtcod,
                  "   and  cidcod = " , param.cidcod

 prepare p_cts32g00_002 from l_com_sql
 declare c_cts32g00_002 cursor for p_cts32g00_002

 open c_cts32g00_002
 whenever error continue
 fetch c_cts32g00_002 into lr_retorno.atdprvtmp
 whenever error stop

  if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then  #notfound
       let lr_retorno.res = 2
    else
       let lr_retorno.res = 3
       let lr_retorno.msg = "Problemas ao obter tmp medio atd ",sqlca.sqlcode
    end if
  else
     let lr_retorno.res = 1
  end if
  if param.nivel_ret = 1 then
     return lr_retorno.res, lr_retorno.msg, lr_retorno.atdprvtmp
  end if

end function
