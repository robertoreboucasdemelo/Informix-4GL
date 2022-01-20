#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hrs                                             #
# Modulo.........: cts36g01                                                  #
# Objetivo.......: Obter dados da prorrogacao do carro extra                 #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 15/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

   define m_prep_cts36g01 smallint

#-----------------------------------------#
 function cts36g01_prepare()
#-----------------------------------------#
   define l_sql char(400)
   let l_sql = ' select vclretdat '
              ,'       ,vclrethor '
              ,'       ,aviprodiaqtd '
              ,'       ,aviprosoldat '
              ,'       ,aviprosolhor '
              ,'       ,aviprostt    '
              ,'   from datmprorrog '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'order by vclretdat, vclrethor '
   prepare pcts36g01001 from l_sql
   declare ccts36g01001 scroll cursor for pcts36g01001

   let l_sql = " select sum(aviprodiaqtd) ",
               "       from datmprorrog ",
               "      where datmprorrog.atdsrvnum = ? ",
               "        and datmprorrog.atdsrvano = ? ",
               "        and datmprorrog.cctcod    is not null ",
               "        and datmprorrog.aviprostt = 'A' "

   prepare pcts36g01002 from l_sql
   declare ccts36g01002 scroll cursor for pcts36g01002
   let m_prep_cts36g01 = true

 end function

#-----------------------------------------#
function cts36g01_prorrog(lr_param, l_cont)
#-----------------------------------------#

   define lr_param record
                   nivel     smallint
                  ,atdsrvnum like datmprorrog.atdsrvnum
                  ,atdsrvano like datmprorrog.atdsrvano
                   end record
   define l_cont smallint
   define lr_retorno record
                     resultado    smallint
                    ,mensagem     char(080)
                    ,vclretdat    like datmprorrog.vclretdat
                    ,vclrethor    like datmprorrog.vclrethor
                    ,aviprodiaqtd like datmprorrog.aviprodiaqtd
                    ,aviprosoldat like datmprorrog.aviprosoldat
                    ,aviprosolhor like datmprorrog.aviprosolhor
                    ,aviprostt    like datmprorrog.aviprostt
                     end record
   initialize lr_retorno to null
   if m_prep_cts36g01 is null or
      m_prep_cts36g01 <> true then
      call cts36g01_prepare()
   end if
   if lr_param.nivel = 1 then
      open ccts36g01001 using lr_param.atdsrvnum
                             ,lr_param.atdsrvano
      whenever error continue
      fetch relative l_cont ccts36g01001 into lr_retorno.vclretdat
                                             ,lr_retorno.vclrethor
                                             ,lr_retorno.aviprodiaqtd
                                             ,lr_retorno.aviprosoldat
                                             ,lr_retorno.aviprosolhor
                                             ,lr_retorno.aviprostt
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = 'Dados da prorrogacao nao encontrada'
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                      ,' em datmprorrog - cts36g01_prorrog'
         end if
      end if
   end if
   return lr_retorno.resultado
         ,lr_retorno.mensagem
         ,lr_retorno.vclretdat
         ,lr_retorno.vclrethor
         ,lr_retorno.aviprodiaqtd
         ,lr_retorno.aviprosoldat
         ,lr_retorno.aviprosolhor
         ,lr_retorno.aviprostt

end function

#-----------------------------------------#
function cts36g01_diaqtd(lr_param)
#-----------------------------------------#

   define lr_param record
          atdsrvnum like datmprorrog.atdsrvnum
         ,atdsrvano like datmprorrog.atdsrvano
         end record
   define lr_retorno record
                     resultado    smallint
                    ,mensagem     char(080)
                    ,aviprodiaqtd like datmprorrog.aviprodiaqtd
                     end record
   initialize lr_retorno to null
   if m_prep_cts36g01 is null or
      m_prep_cts36g01 <> true then
      call cts36g01_prepare()
   end if
      open ccts36g01002 using lr_param.atdsrvnum
                             ,lr_param.atdsrvano
      whenever error continue
      fetch ccts36g01002 into lr_retorno.aviprodiaqtd
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = 'Dados da prorrogacao nao encontrada'
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                      ,' em datmprorrog - cts36g01_diaqtd'
         end if
      end if

      close ccts36g01002
   return lr_retorno.resultado
         ,lr_retorno.mensagem
         ,lr_retorno.aviprodiaqtd

end function
