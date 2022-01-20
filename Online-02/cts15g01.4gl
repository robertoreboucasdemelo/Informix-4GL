###########################################################################
# Nome do Modulo: CTS15G01                                       Marcelo  #
#                                                                Gilberto #
# Funcoes genericas - Validacao do ano modelo do veiculo         Nov/1999 #
###########################################################################


database porto

#------------------------------------------------------------
 function cts15g01(param)
#------------------------------------------------------------

 define param         record
    vclcoddig         like agbkveic.vclcoddig,
    vclanomdl         like agbrveicversao.vclanomdl
 end record

 define ws            record
    verqtd            smallint
 end record



	initialize  ws.*  to  null

 if param.vclcoddig is null  then
    return false
 end if

 let ws.verqtd = 0

#select count(*) into ws.verqtd
#  from agbrveicversao
# where vclcoddig = param.vclcoddig

 if ws.verqtd = 0  then
    if param.vclanomdl < '1910'  then
       return false
    end if

    if param.vclanomdl < '1950'  then
       if cts08g01("A","S","","VEICULO FABRICADO ANTES DE 1950!","","") = "N"  then
          return false
       end if
    end if

    if param.vclanomdl > current year to year + 1 units year  then
       return false
    end if
 end if

#declare c_agbrveicversao cursor for
#   select vclcoddig
#     from agbrveicversao
#    where vclcoddig = param.vclcoddig
#      and vclanomdl = param.vclanomdl
#
#open  c_agbrveicversao
#fetch c_agbrveicversao
#
#if sqlca.sqlcode <> 0  then
#   return false
#end if
#
#close c_agbrveicversao

 return true

end function  ###  cts15g01
