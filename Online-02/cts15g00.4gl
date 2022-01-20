###########################################################################
# Nome do Modulo: cts15g00                                       Marcelo  #
#                                                                Gilberto #
# Funcoes genericas - Descricao do veiculo                       Out/1998 #
###########################################################################

database porto

#------------------------------------------------------------
 function cts15g00(param)
#------------------------------------------------------------

 define param         record
    vclcoddig         like agbkveic.vclcoddig
 end record

 define ws            record
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom
 end record

 define retorno       record
    vcldes            char (75)
 end record




	initialize  ws.*  to  null

	initialize  retorno.*  to  null

 initialize retorno.*    to null
 initialize ws.*         to null

 if param.vclcoddig  is null   then
    let retorno.vcldes = "CODIGO DE VEICULO NAO INFORMADO"
    return retorno.vcldes
 end if

 select vclmrcnom,
        vcltipnom,
        vclmdlnom
   into ws.vclmrcnom,
        ws.vcltipnom,
        ws.vclmdlnom
   from agbkveic, outer agbkmarca, outer agbktip
  where agbkveic.vclcoddig  = param.vclcoddig
    and agbkmarca.vclmrccod = agbkveic.vclmrccod
    and agbktip.vclmrccod   = agbkveic.vclmrccod
    and agbktip.vcltipcod   = agbkveic.vcltipcod

 if sqlca.sqlcode  <>  0   then
    let retorno.vcldes = "DESCRICAO DO VEICULO NAO CADASTRADA"
 else
    let retorno.vcldes = ws.vclmrcnom clipped, " ",
                         ws.vcltipnom clipped, " ",
                         ws.vclmdlnom
 end if

 return retorno.vcldes

end function  ###  cts15g00

#------------------------------------------------------------
 function cts15g00_vcldes(param)
#------------------------------------------------------------

 define param         record
    vclcoddig         like agbkveic.vclcoddig,
    privez            smallint
 end record

 define retorno       record
    vcldes            char (75)
 end record




	initialize  retorno.*  to  null

 initialize retorno.*    to null

 if param.vclcoddig  is null   then
    let retorno.vcldes = "CODIGO DE VEICULO NAO INFORMADO"
    return retorno.vcldes
 end if

 if param.privez = true  then
    call cts15g00_prepare()
    let param.privez = false
 end if

 call cts15g00_select(param.vclcoddig)
      returning retorno.vcldes

 return retorno.vcldes, param.privez

end function  ###  cts15g00_vcldes

#------------------------------------------------------------
 function cts15g00_prepare()
#------------------------------------------------------------

 define ws            record
    sql               char (300)
 end record



	initialize  ws.*  to  null

 let ws.sql = "select vclmrcnom, vcltipnom, vclmdlnom         ",
              "  from agbkveic, outer agbkmarca, outer agbktip",
              " where agbkveic.vclcoddig  = ?                 ",
              "   and agbkmarca.vclmrccod = agbkveic.vclmrccod",
              "   and agbktip.vclmrccod   = agbkveic.vclmrccod",
              "   and agbktip.vcltipcod   = agbkveic.vcltipcod"
 prepare p_cts15g00_001 from ws.sql
 declare c_cts15g00_001 cursor with hold for p_cts15g00_001

end function  ###  cts15g00_prepare

#------------------------------------------------------------
 function cts15g00_select(param)
#------------------------------------------------------------

 define param         record
    vclcoddig         like agbkveic.vclcoddig
 end record

 define ws            record
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom
 end record

 define retorno       record
    vcldes            char (75)
 end record




	initialize  ws.*  to  null

	initialize  retorno.*  to  null

 initialize retorno.*    to null
 initialize ws.*         to null

 open  c_cts15g00_001 using param.vclcoddig
 fetch c_cts15g00_001 into  retorno.vcldes

 if sqlca.sqlcode  <>  0   then
    let retorno.vcldes = "DESCRICAO DO VEICULO NAO CADASTRADA"
 else
    let retorno.vcldes = ws.vclmrcnom clipped, " ",
                         ws.vcltipnom clipped, " ",
                         ws.vclmdlnom
 end if

 close c_cts15g00_001

 return retorno.vcldes

end function  ###  cts15g00_select
