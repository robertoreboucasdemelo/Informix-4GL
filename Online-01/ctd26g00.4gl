#-----------------------------------------------------------------------------#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd26g00                                                    #
# Analista Resp.: Nilo Costa                                                  #
# PSI...........:                                                             #
# Objetivo......: Funcoes de consulta e atualizacoes da Tabela de             #
#                 Transferencia(datmatdtrn)                 (datratdlig)      #
#.............................................................................#
# Desenvolvimento:                                                            #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#-------------------------------------------
function ctd26g00_insere_tranferencia(param)
#-------------------------------------------

   define param        record
          atdnum       like datmatdtrn.atdnum,
          trnlignum    like datmatdtrn.trnlignum,
          necgerlignum like datmatdtrn.necgerlignum,
          atdpripanum  like datmatdtrn.atdpripanum,
          atdpridptsgl like datmatdtrn.atdpridptsgl,
          atdprifunmat like datmatdtrn.atdprifunmat,
          atdpriusrtip like datmatdtrn.atdpriusrtip,
          atdpriempcod like datmatdtrn.atdpriempcod
   end record

   define lr_data_hora record
          trndat like datmatdtrn.trndat
         ,trnhor like datmatdtrn.trnhor
   end record

   define l_msg_erro   char(50)
   define i            smallint
   define lr_atdtrnnum like datmatdtrn.atdtrnnum

   let l_msg_erro = null
   let i          = null
   let lr_atdtrnnum = null
   initialize lr_data_hora.* to null

   if param.atdnum is null or
      param.atdnum =  0    or
      param.atdnum = ''    then
      let l_msg_erro = null
      let l_msg_erro = 'Numero de atendimento invalido: '
                       ,param.atdnum using "<<<<<<<<<<"
      return 1,l_msg_erro
   end if

   if param.trnlignum is null or
      param.trnlignum =  0    or
      param.trnlignum = ''    then
      let l_msg_erro = null
      let l_msg_erro = 'Numero da ligacao invalido: '
                       ,param.trnlignum using "<<<<<<<<<<"
      return 1,l_msg_erro
   end if

   select max(atdtrnnum)
     into lr_atdtrnnum
     from datmatdtrn
    where atdnum = param.atdnum

   if lr_atdtrnnum is null or
      lr_atdtrnnum = 0     then
      let lr_atdtrnnum = 1
   else
     let lr_atdtrnnum = lr_atdtrnnum + 1
   end if

   call cts40g03_data_hora_banco(1)
        returning lr_data_hora.trndat
                 ,lr_data_hora.trnhor

   for i = 1 to 11
      whenever error continue
      insert into datmatdtrn (atdnum
                            ,atdtrnnum
                            ,trnlignum
                            ,necgerlignum
                            ,atdpripanum
                            ,atdpridptsgl
                            ,atdprifunmat
                            ,atdpriusrtip
                            ,atdpriempcod
                            ,trndat
                            ,trnhor)
                     values (param.atdnum
                            ,lr_atdtrnnum
                            ,param.trnlignum
                            ,param.necgerlignum
                            ,param.atdpripanum
                            ,param.atdpridptsgl
                            ,param.atdprifunmat
                            ,param.atdpriusrtip
                            ,param.atdpriempcod
                            ,lr_data_hora.trndat
                            ,lr_data_hora.trnhor)
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = -239 or
            sqlca.sqlcode = -268 then
            let l_msg_erro = null
            let l_msg_erro = 'Registro jah existe na tabela de relacionamento.'
            return 1,l_msg_erro
         end if
      else
         exit for
      end if
   end for

   return 0,'OK'

end function
