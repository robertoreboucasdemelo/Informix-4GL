#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctx01g10.4gl                                              #
#                  Retornar o status do telefone consultado (atende ao       #
#                  Decreto 53921 - Lei Nao Perturbe)                         #
# Analista Resp. : Patricia Wissinievski                                     #
# PSI            : 239976                                                    #
#............................................................................#
# Liberacao      : 05/05/2009                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  Data   Alteracao                                #
# ----------  -------------  ------ -----------------------------------------#
# 24/04/2012 RobsonD, meta   Alteracao no tamanho das variaveis de tel/cel.  #
#----------------------------------------------------------------------------#

database porto

{
main
   define l_status smallint
   call ctx01g10_retorna_bloqueio('1234', '123456789')
      returning l_status
   display'telefone enviado: 1234 123456789'
   display ''
   display l_status
end main
}
#---------------------------------------------------------------------------
 function ctx01g10_retorna_bloqueio(p_ddd, p_telefone)
#---------------------------------------------------------------------------
   define p_ddd smallint,
          p_telefone decimal(10), #robsonD
          l_data date,
          l_status smallint,
          l_count smallint


   let l_count = 0

   # verifica se o telefone existe, bloqueado
   select count(*) into l_count
     from datmtelligblq
    where dddnum = p_ddd
      and telnum = p_telefone
      and clisolstt = 1

   if l_count = 0 then # nao esta cadastrado ou esta desbloqueado
      # retorna status 0
      return 0
   else
      if l_count > 0 then
         # verifica a última data cadastrada
         # considerando todos os status pois o ultimo
         # cadastrado pode ser DESBLOQUEIO

         select max(clisoldat) into l_data
           from datmtelligblq
          where dddnum = p_ddd
            and telnum = p_telefone

         # seleciona status da maior data cadastrada
         select clisolstt into l_status
           from datmtelligblq
          where dddnum = p_ddd
            and telnum = p_telefone
            and clisoldat = l_data

         #retorna status encontrado
         return l_status

      end if

   end if

end function


