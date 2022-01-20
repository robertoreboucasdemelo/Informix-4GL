#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : ctx24g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 190489                                                     #
#                 Obter informacoes do grupo de naturezas (datksocntzgrp).   #
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

define m_prep_sql   smallint

#----------------------------------------------
function ctx24g00_prepare()
#----------------------------------------------

 define l_sql char(200)
 let l_sql =  " select socntzgrpdes "
             ," from datksocntzgrp "
             ," where socntzgrpcod = ? "

 prepare pctx24g00001 from l_sql
 declare cctx24g00001 cursor for pctx24g00001

 let m_prep_sql = true

end function

#----------------------------------------------
function ctx24g00_popup_grupo()
#----------------------------------------------

 define lr_ret   record
    resultado    smallint
   ,socntzgrpcod like datksocntzgrp.socntzgrpcod
 end record

 define l_socntzgrpdes like datksocntzgrp.socntzgrpdes

 define l_sql    char(500)
 initialize lr_ret.* to null

 let l_sql = " select socntzgrpcod, socntzgrpdes from datksocntzgrp ",
             "  order by 1,2 "

 call ofgrc001_popup(12,20,"Grupos","Codigo","Descricao","N", l_sql, "", "D")
    returning lr_ret.*, l_socntzgrpdes

 return lr_ret.*

end function

#----------------------------------------------
function ctx24g00_descricao(l_socntzgrpcod)
#----------------------------------------------

 define l_socntzgrpcod like datksocntzgrp.socntzgrpcod
 define lr_ret   record
    resultado    smallint   # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
   ,mensagem     char(80)
   ,socntzgrpdes like datksocntzgrp.socntzgrpdes
 end record
 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctx24g00_prepare()
 end if
 initialize lr_ret.* to null

 open cctx24g00001 using l_socntzgrpcod
 whenever error continue
 fetch cctx24g00001 into lr_ret.socntzgrpdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_ret.resultado = 2
       let lr_ret.mensagem = " Grupo invalido "
    else
       let lr_ret.resultado = 3
       let lr_ret.mensagem = " Erro ",sqlca.sqlcode," em datksocntzgrp "
    end if
 else
    let lr_ret.resultado = 1
    let lr_ret.mensagem = ""
 end if

 return lr_ret.*

end function

