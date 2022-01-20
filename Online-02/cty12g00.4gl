#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty12g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 190489                                                     #
# OSF           :                                                            #
#                 Obter informacoes da tabela glakest.                       #
#                                                                            #
#............................................................................#
# Desenvolvimento: Meta, Daniel                                              #
# Liberacao      : 27/01/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#--------------------------------------------
function cty12g00_prepare()
#--------------------------------------------

 define l_sql   char(200)
 let l_sql = " select ufdnom "
            ," from glakest "
            ," where ufdcod = ? "

 prepare pcty12g00001 from l_sql
 declare ccty12g00001 cursor for pcty12g00001
 let m_prep_sql = true

end function


#--------------------------------------------
function cty12g00_ufdcod(l_ufdcod)
#--------------------------------------------

 define l_ufdcod  like glakest.ufdcod
 define lr_ret   record
    resultado    smallint
   ,mensagem     char(80)
   ,ufdnom       like glakest.ufdnom
 end record
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty12g00_prepare()
 end if
 initialize lr_ret.* to null
 open ccty12g00001 using l_ufdcod
 whenever error continue
 fetch ccty12g00001 into lr_ret.ufdnom
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_ret.resultado = 2
       let lr_ret.mensagem = " Unidade federativa invalida "
    else
       let lr_ret.resultado = 3
       let lr_ret.mensagem = " Erro ",sqlca.sqlcode," em glakest "
    end if
 else
    let lr_ret.resultado = 1
    let lr_ret.mensagem = ""
 end if
 return lr_ret.*
end function
