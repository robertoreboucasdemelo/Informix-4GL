###############################################################################
# Nome do Modulo: cta01m28                                           Gilberto #
#                                                                     Marcelo #
# Exibe dados do veiculo - Garantia estendida (ramo 16)              OUT/1997 #
# ----------------------------------------------------------------------------#  
#                  * * *  A L T E R A C O E S  * * *                          #  
#                                                                             #  
# Data       Autor Fabrica         PSI    Alteracoes                          #  
# ---------- --------------------- ------ ------------------------------------#  
# 18/07/06   Junior, Meta       AS112372  Migracao de versao do 4gl.          #  
#-----------------------------------------------------------------------------#  
                                                                               
database porto                                                                

#------------------------------------------------------------------------------
 function cta01m28(param)
#------------------------------------------------------------------------------

 define param        record
    prporg           like rsdmdocto.prporg,
    prpnumdig        like rsdmdocto.prpnumdig
 end record

 define d_cta01m28   record
    vclmrcnom        like agbkmarca.vclmrcnom,
    vcltipnom        like agbktip.vcltipnom,
    vclmdlnom        like agbkveic.vclmdlnom,
    vclchsnum        like rgrmgrevcl.vclchsnum,
    vcllicnum        like rgrmgrevcl.vcllicnum,
    vclanofbc        like rgrmgrevcl.vclanofbc,
    vclanomdl        like rgrmgrevcl.vclanomdl,
    cnsgrpnom        like rgrkcnsgrp.cnsgrpnom,
    cnsnom           like agbkconces.cnsnom
 end record

 define ws           record
    pergunta         char(01),
    vclcoddig        like rgrmgrevcl.vclcoddig,
    cnscod           like rgrmgrevcl.cnscod,
    cnsgrpcod        like rgrkcnsgrp.cnsgrpcod,
    vigfnl           like rgrrgrpcns.vigfnl
 end record




	initialize  d_cta01m28.*  to  null

	initialize  ws.*  to  null

 let int_flag             =  false
 initialize d_cta01m28.*  to null
 initialize ws.*          to null

 select vclcoddig, vcllicnum,
        vclchsnum, vclanomdl,
        vclanofbc, cnscod
   into ws.vclcoddig        , d_cta01m28.vcllicnum,
        d_cta01m28.vclchsnum, d_cta01m28.vclanomdl,
        d_cta01m28.vclanofbc, ws.cnscod
   from rgrmgrevcl
  where prporg     =  param.prporg     and
        prpnumdig  =  param.prpnumdig  and
        itmseq     =  1

 if sqlca.sqlcode  <>  0  then
    error " Erro (",sqlca.sqlcode,") leitura dados do veiculo,AVISE INFORMATICA"
    sleep 3
    return
 end if

 select agbkveic.vclmdlnom,
        agbkmarca.vclmrcnom,
        agbktip.vcltipnom
   into d_cta01m28.vclmdlnom,
        d_cta01m28.vclmrcnom,
        d_cta01m28.vcltipnom
   from agbkveic, agbkmarca, agbktip
  where agbkveic.vclcoddig  = ws.vclcoddig         and
        agbkmarca.vclmrccod = agbkveic.vclmrccod   and
        agbktip.vclmrccod   = agbkveic.vclmrccod   and
        agbktip.vcltipcod   = agbkveic.vcltipcod

 if sqlca.sqlcode <> 0   then
    error " Erro (",sqlca.sqlcode,") na descricao do veiculo, AVISE INFORMATICA"
    sleep 3
    return
 end if


 open window w_cta01m28 at 08,34  with form  "cta01m28"
      attribute (border, form line first)

 select cnsnom
   into d_cta01m28.cnsnom
   from agbkconces
  where cnscod = ws.cnscod

 select max(vigfnl), cnsgrpcod
   into ws.vigfnl, ws.cnsgrpcod
   from rgrrgrpcns
  where cnscod = ws.cnscod
  group by cnsgrpcod

 if ws.cnsgrpcod  is not null   then
    select cnsgrpnom
      into d_cta01m28.cnsgrpnom
      from rgrkcnsgrp
     where cnsgrpcod = ws.cnsgrpcod
 else
    let d_cta01m28.cnsgrpnom = d_cta01m28.vclmrcnom
 end if

 display by name d_cta01m28.*

 prompt " (F17)Abandona   " for char  ws.pergunta

 close window  w_cta01m28
 let int_flag = false

 end function     #-- cta01m28
