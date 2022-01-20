#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cta01m63                                            #
# Analista Resp.: Roberto Reboucas                                    #
# PSI           : 218200                                              #
# Objetivo      : Dados do Veiculo                                    #
#.....................................................................#
# Desenvolvimento: Roberto Reboucas                                   #
# Liberacao      : 27/01/2008                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

#------------------------------------------------------------------------------
function cta01m63_prepare()
#------------------------------------------------------------------------------

define l_sql char(500)

  let l_sql = " select vclcoddig, " ,
              "        vclanofbc, " ,
              "        vclanomdl, " ,
              "        vcllicnum, " ,
              "        vclchsinc, " ,
              "        vclchsfnl  " ,
              " from abbmveic     " ,
              " where succod    = ? ",
              " and  aplnumdig  = ? ",
              " and  itmnumdig  = ? ",
              " and  dctnumseq  = ? "
  prepare p_cta01m63_001  from l_sql
  declare c_cta01m63_001  cursor for p_cta01m63_001
  let l_sql = " select vclcoddig, " ,
              "        vclanofbc, " ,
              "        vclanomdl, " ,
              "        vcllicnum, " ,
              "        vclchsinc, " ,
              "        vclchsfnl  " ,
              " from abbmveic     " ,
              " where succod    = ? ",
              " and  aplnumdig  = ? ",
              " and  itmnumdig  = ? ",
              " and  dctnumseq  = (select max(dctnumseq) ",
                                  " from abbmveic        ",
                                  " where succod  = ?    ",
                                  " and aplnumdig = ?    ",
                                  " and itmnumdig = ?)   "
  prepare pcta01m63002  from l_sql
  declare ccta01m63002  cursor for pcta01m63002
  let l_sql = " select vclmrccod,   ",
              "        vcltipcod,   ",
              "        vclmdlnom    ",
              " from  agbkveic      ",
              " where vclcoddig = ? "
  prepare pcta01m63003  from l_sql
  declare ccta01m63003  cursor for pcta01m63003
  let l_sql = " select vclmrcnom    ",
              " from agbkmarca      ",
              " where vclmrccod = ? "
  prepare pcta01m63004  from l_sql
  declare ccta01m63004  cursor for pcta01m63004
  let l_sql = " select vcltipnom    ",
              " from agbktip        ",
              " where vclmrccod = ? ",
              " and vcltipcod   = ? "
  prepare pcta01m63005  from l_sql
  declare ccta01m63005  cursor for pcta01m63005
  let m_prepare = true
end function
#------------------------------------------------------------------------------
function cta01m63(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   succod    like datrligapol.succod    ,
   aplnumdig like datrligapol.aplnumdig ,
   itmnumdig like datrligapol.itmnumdig
end record

define d_cta01m63 record
   vcllicnum like abbmveic.vcllicnum ,
   vclmrcnom like agbkmarca.vclmrcnom,
   vcltipnom like agbktip.vcltipnom  ,
   vclmdlnom like agbkveic.vclmdlnom ,
   vclanofbc like abbmveic.vclanofbc ,
   vclanomdl like abbmveic.vclanomdl ,
   vclchs    char (20)
end record

define prompt_key char (01)

initialize d_cta01m63.*  to null
let prompt_key = null

  open window cta01m63 at 09,18 with form 'cta01m63'attribute(border, form line 1)
  message " Aguarde, formatando os dados..."  attribute(reverse)
  call cta01m63_rec_dados_veic(lr_param.*)
  returning d_cta01m63.*
  display by name d_cta01m63.*
  prompt "                (F17)Abandona" for prompt_key
  close window cta01m63
  message ""
end function

#------------------------------------------------------------------------------
function cta01m63_rec_dados_veic(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   succod    like datrligapol.succod    ,
   aplnumdig like datrligapol.aplnumdig ,
   itmnumdig like datrligapol.itmnumdig
end record
define lr_retorno record
   vcllicnum like abbmveic.vcllicnum ,
   vclmrcnom like agbkmarca.vclmrcnom,
   vcltipnom like agbktip.vcltipnom  ,
   vclmdlnom like agbkveic.vclmdlnom ,
   vclanofbc like abbmveic.vclanofbc ,
   vclanomdl like abbmveic.vclanomdl ,
   vclchs    char (20)
end record
define lr_aux record
  vclcoddig  like agbkveic.vclcoddig ,
  vclmrccod  like agbkmarca.vclmrccod,
  vcltipcod  like agbktip.vcltipcod  ,
  vclchsinc  like abbmveic.vclchsinc ,
  vclchsfnl  like abbmveic.vclchsfnl
end record

initialize lr_aux.* ,
           lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
   call cta01m63_prepare()
end if
call f_funapol_ultima_situacao (lr_param.succod   ,
                                lr_param.aplnumdig,
                                lr_param.itmnumdig)
returning g_funapol.*
open c_cta01m63_001 using lr_param.succod     ,
                        lr_param.aplnumdig  ,
                        lr_param.itmnumdig  ,
                        g_funapol.vclsitatu
whenever error continue
fetch c_cta01m63_001 into lr_aux.vclcoddig,
                        lr_retorno.vclanofbc,
                        lr_retorno.vclanomdl,
                        lr_retorno.vcllicnum,
                        lr_aux.vclchsinc,
                        lr_aux.vclchsfnl
whenever error stop
if sqlca.sqlcode = notfound  then
     open ccta01m63002 using lr_param.succod     ,
                             lr_param.aplnumdig  ,
                             lr_param.itmnumdig  ,
                             lr_param.succod     ,
                             lr_param.aplnumdig  ,
                             lr_param.itmnumdig
     whenever error continue
     fetch ccta01m63002 into lr_aux.vclcoddig    ,
                             lr_retorno.vclanofbc,
                             lr_retorno.vclanomdl,
                             lr_retorno.vcllicnum,
                             lr_aux.vclchsinc    ,
                             lr_aux.vclchsfnl
     whenever error stop
end if
if sqlca.sqlcode <> notfound  then
    open ccta01m63003 using lr_aux.vclcoddig
    fetch ccta01m63003 into lr_aux.vclmrccod,
                            lr_aux.vcltipcod,
                            lr_retorno.vclmdlnom
    close ccta01m63003
    open ccta01m63004 using lr_aux.vclmrccod
    fetch ccta01m63004 into lr_retorno.vclmrcnom
    close ccta01m63004
    open ccta01m63005 using lr_aux.vclmrccod,
                            lr_aux.vcltipcod
    fetch ccta01m63005 into lr_retorno.vcltipnom
    close ccta01m63005
    let lr_retorno.vclchs  =  lr_aux.vclchsinc clipped,
                              lr_aux.vclchsfnl clipped
end if

    return lr_retorno.*
end function
