#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : ctx24g01.4gl                                               #
# Analista Resp : Adriano Santos                                             #
# PSI           : 252853                                                     #
#                 Obter informacoes da naturezas (datksocntz).               #
#                                                                            #
#............................................................................#
# Desenvolvimento: Adriano Santos                                            #
# Liberacao      : 09/03/2010                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#----------------------------------------------
function ctx24g01_prepare()
#----------------------------------------------

 define l_sql char(200)
 let l_sql =  " select socntzdes "
             ," from datksocntz "
             ," where socntzcod = ? "

 prepare pctx24g01001 from l_sql
 declare cctx24g01001 cursor for pctx24g01001

 let m_prep_sql = true

end function

#----------------------------------------------
function ctx24g01_popup_natureza()
#----------------------------------------------

 define lr_ret   record
    resultado    smallint
   ,socntzcod like datksocntz.socntzcod
 end record

 define l_socntzdes like datksocntz.socntzdes

 define l_sql    char(500)
 initialize lr_ret.* to null

 let l_sql = " select socntzcod, socntzdes from datksocntz ",
             "  order by 1,2 "

 call ofgrc001_popup(12,20,"Natureza","Codigo","Descricao","N", l_sql, "", "D")
    returning lr_ret.*, l_socntzdes

 return lr_ret.*

end function

#----------------------------------------------
function ctx24g01_descricao(l_socntzcod)
#----------------------------------------------

 define l_socntzcod like datksocntz.socntzcod
 define lr_ret   record
    resultado    smallint   # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
   ,mensagem     char(80)
   ,socntzdes like datksocntz.socntzdes
 end record
 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctx24g01_prepare()
 end if
 initialize lr_ret.* to null

 open cctx24g01001 using l_socntzcod
 whenever error continue
 fetch cctx24g01001 into lr_ret.socntzdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_ret.resultado = 2
       let lr_ret.mensagem = " Grupo invalido "
    else
       let lr_ret.resultado = 3
       let lr_ret.mensagem = " Erro ",sqlca.sqlcode," em datksocntz "
    end if
 else
    let lr_ret.resultado = 1
    let lr_ret.mensagem = ""
 end if

 return lr_ret.*

end function

