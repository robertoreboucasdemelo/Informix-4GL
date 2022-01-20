#-------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                               #
# ..............................................................................#
# Sistema........: Central 24h                                                  #
# Modulo.........: cts01g01                                                     #
# Analista Resp..: Ligia Mattge                                                 #
# PSI/OSF........: AS87408                                                      #
#                  Programa para habilitar/desabilitar o set explain            #
# ..............................................................................#
# Desenvolvimento: Andrei Farias, Meta                                          #
# Liberacao......: 14/09/2005                                                   #
# ..............................................................................#
#                                                                               #
#                           * * * Alteracoes * * *                              #
#                                                                               #
# Data       Autor Fabrica   Origem     Alteracao                               #
# ---------- --------------  ---------- ----------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

#-------------------------#
function cts01g01_prepare()
#-------------------------#

 define l_sql char(200)

 let l_sql = 'select cpocod, cpodes '
            ,'  from iddkdominio '
            ,' where cponom = "setexplain" '

 prepare p_cts01g01_001 from l_sql
 declare c_cts01g01_001 cursor for p_cts01g01_001

 let m_prep_sql = true

end function

#-------------------------------------#
function cts01g01_setexplain (lr_param)
#-------------------------------------#

  define lr_param record
         empcod   like isskusuario.empcod,
         funmat   like isskfunc.funmat,
         flag     smallint
  end record

  define lr_iddkdominio record
         cpocod         like iddkdominio.cpocod,
         cpodes         like iddkdominio.cpodes
  end record

  if m_prep_sql is not null and
     m_prep_sql <> true then
     call cts01g01_prepare()
  end if

  let g_setexplain = 0

  if lr_param.flag = 1 then
     open c_cts01g01_001

     whenever error continue

     fetch c_cts01g01_001 into lr_iddkdominio.cpocod
                            ,lr_iddkdominio.cpodes
     whenever error stop

     #if sqlca.sqlcode <> 0 then
     #   if sqlca.sqlcode = notfound then
     #      error 'Parametros nao encontrados' sleep 2
     #   else
     #      error ' Erro SELECT c_cts01g01_001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
     #      error ' CTS01G01 / cts01g01_setexplain() ' sleep 2
     #   end if
     #else

     if sqlca.sqlcode = 0 then

        if lr_iddkdominio.cpocod = lr_param.empcod and
           lr_iddkdominio.cpodes = lr_param.funmat then
           set explain on
           let g_setexplain = 1
        end if

     end if

  else
     if lr_param.flag = 2 then
        set explain off
     end if
  end if

end function

#------------------------------------#
function cts01g01_setetapa(l_mensagem)
#------------------------------------#

  define l_mensagem char(140),
         l_sql      char(200)

  let l_sql = 'select "',l_mensagem clipped,'"'
               ,' from dual '

  prepare p_cts01g01_002 from l_sql
  declare c_cts01g01_002 cursor for p_cts01g01_002

  open c_cts01g01_002

  whenever error continue

  fetch c_cts01g01_002 into l_mensagem
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        error 'Mensagem nao encontrada' sleep 2
     else
        error ' Erro SELECT c_cts01g01_002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
        error ' CTS01G01 / cts01g01_setetapa() 'sleep 2
     end if
  end if

  display 'Mensagem : ', l_mensagem

end function
