#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cty25g03                                                   #
# Objetivo.......: Popup Generica Itau                                        #
# Analista Resp. : Junior (FORNAX)                                            #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: Roberto Melo                                               #
# Liberacao      :   /  /                                                     #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

#----------------------------------------------#
function cty25g03_recupera_descricao(lr_param)
#----------------------------------------------#

define lr_param record
  tipo   smallint,
  codigo integer
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql = "select plndes from datkresitapln where plncod = ?"
         when 2
            let lr_retorno.sql = "select prddes from datkresitaprd where prdcod = ?"
         when 3
            let lr_retorno.sql = "select srvdes from datkresitasrv where srvcod = ?"
         when 4
            let lr_retorno.sql = "select sgmdes from datkresitaclisgm where sgmcod = ?"
         when 5
            let lr_retorno.sql = "select rscsegcbttipdes from datkrscsegcbttip where rscsegcbttipcod = ?"
         when 6 
            let lr_retorno.sql = "select rscsegrestipdes from datkrscsegrestip where rscsegrestipcod = ?"
         when 7 
            let lr_retorno.sql = "select rscsegimvtipdes from datkrscsegimvtip where rscsegimvtipcod = ? "
         when 8 
            let lr_retorno.sql = "select itaempasides from datkitaempasi where itaempasicod = ? "
     end case


     prepare pcty25g03001 from lr_retorno.sql
     declare ccty25g03001 cursor for pcty25g03001

     open ccty25g03001 using lr_param.codigo
     whenever error continue
     fetch ccty25g03001 into lr_retorno.descricao
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close ccty25g03001


    return lr_retorno.descricao

end function

#----------------------------------------------#
function cty25g03_recupera_descricao2(lr_param)
#----------------------------------------------#

define lr_param record
  tipo    smallint,
  plano   integer ,
  produto integer  
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql = "select plndes from datkresitapln where plncod = ? and prdcod = ? "
     end case


     prepare pcty25g03002 from lr_retorno.sql
     declare ccty25g03002 cursor for pcty25g03002

     open ccty25g03002 using lr_param.plano,lr_param.produto
     whenever error continue
     fetch ccty25g03002 into lr_retorno.descricao
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close ccty25g03002


    return lr_retorno.descricao

end function