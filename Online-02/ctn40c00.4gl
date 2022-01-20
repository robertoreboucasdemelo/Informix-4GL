###############################################################################
# Nome do Modulo: ctn40c00                                           Marcelo  #
#                                                                    Gilberto #
# Conusulta situacao do veiculo(bloqueado/cancelado)                 Set/1998 #
###############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctn40c00(param)
#-----------------------------------------------------------

 define param         record
    atdvclsgl         like datkveiculo.atdvclsgl
 end record

 define d_ctn40c00    record
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (54),
    socoprsitcod      like datkveiculo.socoprsitcod,
    socoprsitcoddes   char (09),
    obs1              char (50),
    obs2              char (50),
    obs3              char (50),
    caddat            like datkvclsit.caddat,
    cadhor            like datkvclsit.cadhor,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkvclsit.atldat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    socvclsitdes      like datkvclsit.socvclsitdes,
    vclcoddig         like datkveiculo.vclcoddig,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat,
    pergunta          char (01)
 end record

 initialize  d_ctn40c00.*  to  null
 initialize ws.*         to null

 let int_flag = false

 if param.atdvclsgl  is null   then
    error " Sigla do veiculo nao informado, AVISE INFORMATICA!"
    return
 end if

#---------------------------------------------------------
# Ler dados sobre veiculo/situacao
#---------------------------------------------------------
 select datkveiculo.socvclcod,
        datkveiculo.vclcoddig,
        datkveiculo.socoprsitcod,
        datkvclsit.caddat,
        datkvclsit.cadhor,
        datkvclsit.cademp,
        datkvclsit.cadmat,
        datkvclsit.atldat,
        datkvclsit.atlemp,
        datkvclsit.atlmat,
        datkvclsit.socvclsitdes
   into d_ctn40c00.socvclcod,
        ws.vclcoddig,
        d_ctn40c00.socoprsitcod,
        d_ctn40c00.caddat,
        d_ctn40c00.cadhor,
        ws.cademp,
        ws.cadmat,
        d_ctn40c00.atldat,
        ws.atlemp,
        ws.atlmat,
        ws.socvclsitdes
   from datkveiculo, outer datkvclsit
  where datkveiculo.atdvclsgl =  param.atdvclsgl
    and datkvclsit.socvclcod  =  datkveiculo.socvclcod

 if sqlca.sqlcode  <>  0   then
    error " Veiculo nao encontrado, AVISE INFORMATICA!"
    return
 end if

 select cpodes
   into d_ctn40c00.socoprsitcoddes
   from iddkdominio
  where iddkdominio.cponom  =  "socoprsitcod"
    and iddkdominio.cpocod  =  d_ctn40c00.socoprsitcod

 let d_ctn40c00.obs1 = ws.socvclsitdes[001,050]
 let d_ctn40c00.obs2 = ws.socvclsitdes[051,100]
 let d_ctn40c00.obs3 = ws.socvclsitdes[101,150]

 call ctn40c00_func(ws.cademp, ws.cadmat)
  returning d_ctn40c00.cadfunnom

 call ctn40c00_func(ws.atlemp, ws.atlmat)
      returning d_ctn40c00.funnom

 #---------------------------------------------------------
 # Descricao do veiculo
 #---------------------------------------------------------
 select vclmrcnom,
        vcltipnom,
        vclmdlnom
   into ws.vclmrcnom,
        ws.vcltipnom,
        ws.vclmdlnom
   from agbkveic, outer agbkmarca, outer agbktip
  where agbkveic.vclcoddig  = ws.vclcoddig
    and agbkmarca.vclmrccod = agbkveic.vclmrccod
    and agbktip.vclmrccod   = agbkveic.vclmrccod
    and agbktip.vcltipcod   = agbkveic.vcltipcod

 let d_ctn40c00.vcldes = ws.vclmrcnom clipped, " ",
                         ws.vcltipnom clipped, " ",
                         ws.vclmdlnom

 #---------------------------------------------------------
 # Exibe tela com os dados do bloqueio/cancelamento
 #---------------------------------------------------------
 open window ctn40c00 at 6,7 with form "ctn40c00"
      attribute(form line first, border)

 display by name param.atdvclsgl
 display by name d_ctn40c00.*

 prompt " (F17)Abandona "  for char  ws.pergunta

 close window ctn40c00
 let int_flag = false

end function  ###  ctn40c00


#---------------------------------------------------------
 function ctn40c00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record

 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctn40c00_func

