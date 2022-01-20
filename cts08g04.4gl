#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ............................................................................#
# Sistema.......: Porto Socorro - Central 24 Horas                            #
# Modulo........: cts08g04.4gl                                                #
# Analista Resp.: Norton Nery                                                 #
# PAS...........: 40290                                                       #
# Objetivo......: Inclusao do email do socorrista                             #
#.............................................................................#
# Desenvolvimento: Eliane Ortiz                                               #
# Liberacao......: 25/06/2008                                                 #
#.............................................................................#
#                   * * *  ALTERACOES  * * *                                  #
#                                                                             #
# Data       Autor Fabrica  PSI       Alteracao                               #
# --------   -------------  ------    ----------------------------------------#
# xx/xx/xxxx xxxxxx, Meta   xxxxxxxxx                                         #
#-----------------------------------------------------------------------------#


database porto


#------------------------------------------------
   function cts08g04(lr_param)
#------------------------------------------------

   define lr_param    record
             mensagem char(40)
           , email    char(50)
   end record
   
   define l_email     char(50)
        , l_status    smallint
        
   let l_email   = null
   let l_status  = 0
   
   open window w_cts08g04 at 09,07 with form 'cts08g04'
         attribute (border)
   
   call cts08g04_input(lr_param.mensagem
                      ,lr_param.email)
      returning l_email
              , l_status
      
   close window w_cts08g04
         
   return l_email
        , l_status
   
end function



#------------------------------------------------
   function cts08g04_input(lr_param)
#------------------------------------------------

   define lr_param    record
             msg      char(40)
           , email    char(50)
   end record
   
   define l_retorno   smallint
        , l_status    smallint
        , l_ok        smallint
        
   let l_retorno = 0
   let l_status  = 0
   let l_ok      = false

   input by name lr_param.msg
               , lr_param.email without defaults
         
      before field email
         display by name lr_param.email attribute(reverse)
         
      after field email
         next field email
      
      on key(f8)
         let lr_param.email = get_fldbuf(email)
         display by name lr_param.email
         if lr_param.email is not null and  
            lr_param.email <> " "      then
            let l_retorno = ctb00g02(lr_param.email)
            
            if l_retorno = 1 then
               error 'EMAIL INVALIDO.'
               next field email
            end if
            
            let l_ok = true
         end if

         if lr_param.email is null or   
            lr_param.email =  " "      then
            let l_ok = true
         end if

         if l_ok then
            let l_status = 0
            exit input
         end if   

      on key(f17, interrupt,control-c) 
         let int_flag = false
         let l_status = 1
         let lr_param.email = null
         exit input
        
   end input

   return lr_param.email
        , l_status

end function


