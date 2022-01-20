#==============================================================================#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : ctc61m03                                                     #
# Analista Resp : Ligia Mattge                                                 #
# PSI           : 198.714                                                      #
#                 Obter dados de locais/condicoes do veiculo 
# .............................................................................#
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#------------------------------------------------------------------------------#

database porto

define m_prep_sql  smallint

#--------------------------#
function ctc61m03_prepare()
#--------------------------#

  define l_sql char(200)

  let l_sql = ' select vclcndlcldes '
               ,' from datkvclcndlcl '
              ,' where vclcndlclcod = ? '

  prepare pctc61m03001  from l_sql
  declare cctc61m03001  cursor for pctc61m03001

  let m_prep_sql = true

end function


#-----------------------------------------#
function ctc61m03(lr_param)
#-----------------------------------------#

 define lr_param     record
    nivel_retorno    smallint
   ,vclcndlclcod     like datkvclcndlcl.vclcndlclcod
 end record

 define lr_retorno record
        vclcndlcldes  like datkvclcndlcl.vclcndlcldes
 end record

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc61m03_prepare()
 end if

 initialize lr_retorno to null

 open cctc61m03001 using lr_param.vclcndlclcod

 whenever error continue
 fetch cctc61m03001 into lr_retorno.*
 whenever error stop

 case lr_param.nivel_retorno
   when 1
      return lr_retorno.vclcndlcldes
 end case

end function
