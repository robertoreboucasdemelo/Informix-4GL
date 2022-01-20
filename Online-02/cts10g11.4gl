#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: cts10g11                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI............: 211982                                                     #
# OBJETIVO.......: Obter as informacoes sobre a liberacao do atendimento      #
# ........................................................................... #
# DESENVOLVIMENTO: Luciano Lopes, META                                        #
# LIBERACAO......: 19/09/2007                                                 #
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- ------------------ ---------- -----------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto                                                                 

#------------------------------------#
function cts10g11_atend_lib(lr_param)
#------------------------------------#
   define lr_param      record
          nivel_retorno smallint
         ,atdsrvnum     like datmservico.atdsrvnum
         ,atdsrvano     like datmservico.atdsrvano
   end record

   define lr_retorno       record
             resultado     smallint
            ,mensagem      char(60)
            ,atendimento   char(65)
   end record
   
   define lr_recebe  record
          atddat     like datmservico.atddat
         ,atdhor     like datmservico.atdhor   
         ,empcod     like datmservico.empcod 
         ,funmat     like datmservico.funmat 
         ,usrtip     like datmservico.usrtip      
         ,atdlibdat  like datmservico.atdlibdat       
         ,atdlibhor  like datmservico.atdlibhor
         ,funnom     like isskfunc.funnom
         ,dptsgl     like isskfunc.dptsgl
   end record  
 
   initialize lr_retorno to null
   let lr_retorno.resultado  = 1
  
   call cts10g06_dados_servicos(14,
                                lr_param.atdsrvnum,
                                lr_param.atdsrvano)
      
      returning lr_retorno.resultado,
                lr_retorno.mensagem,
                lr_recebe.atddat, 
                lr_recebe.atdhor,
                lr_recebe.empcod, 
                lr_recebe.funmat, 
                lr_recebe.usrtip, 
                lr_recebe.atdlibdat,
                lr_recebe.atdlibhor
   
   if lr_param.nivel_retorno = 1 and
      lr_retorno.resultado  <> 1 then
      
      return lr_retorno.resultado, 
             lr_retorno.mensagem, 
             lr_retorno.atendimento
   end if            
   
   
   call cty08g00_nome_func(lr_recebe.empcod, 
                           lr_recebe.funmat, 
                           lr_recebe.usrtip)
      returning lr_retorno.resultado
               ,lr_retorno.mensagem
               ,lr_recebe.funnom

   if lr_param.nivel_retorno = 1 and
      lr_retorno.resultado  <> 1 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.atendimento
   end if            

   call cty08g00_depto_func(lr_recebe.empcod, 
                            lr_recebe.funmat, 
                            lr_recebe.usrtip)
      returning lr_retorno.resultado
               ,lr_retorno.mensagem
               ,lr_recebe.dptsgl 

   if lr_param.nivel_retorno = 1 and
      lr_retorno.resultado  <> 1 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.atendimento
   end if            

   case lr_param.nivel_retorno 
        when 1
           let lr_retorno.atendimento = lr_recebe.atddat, " "
                                       ,lr_recebe.atdhor, " "
                                       ,lr_recebe.dptsgl clipped, " "
                                       ,lr_recebe.funmat using "&&&&&&", " "
                                       ,upshift(lr_recebe.funnom) clipped, " "
                                       ,lr_recebe.atdlibdat, " "
                                       ,lr_recebe.atdlibhor
            
           return lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,lr_retorno.atendimento
   end case 

end function


