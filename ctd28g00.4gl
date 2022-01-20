#-----------------------------------------------------------------------------#
# Porto Seguro Seguradora                                                     #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd28g00                                                    #
# Analista Resp.: Ligia Mattge                                                #
# PSI...........: 229784                                                      #
# Objetivo......: Buscar informacoes sobre a viatura do socorrista            #
#.............................................................................#
# Desenvolvimento: Ligia Mattge                                               #
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

   define m_prep_sql smallint

#---------------------------
function ctd28g00_prepare()
#---------------------------
   
   define l_sql char(400)
   
   let l_sql = 'select socvcltip, '
                    ,' atdvclsgl '
               ,' from datkveiculo '
              ,' where socvclcod = ? ' 
   
   prepare pctd28g00001 from l_sql
   declare cctd28g00001 cursor for pctd28g00001 
   
   let m_prep_sql = true

end function

#-------------------------------------------
function ctd28g00_inf_datkveiculo(l_tp_retorno, l_socvclcod)
#-------------------------------------------

   define l_tp_retorno smallint,
          l_socvclcod  like datkveiculo.socvclcod,
          l_msg        char(200)
         
   define lr_retorno record 
          erro         smallint
         ,mensagem     char(100)
         ,socvcltip    like datkveiculo.socvcltip         
         ,atdvclsgl    like datkveiculo.atdvclsgl   
   end record

   initialize lr_retorno to null

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd28g00_prepare()
   end if
   
   open cctd28g00001 using l_socvclcod
   whenever error continue
   fetch cctd28g00001 into lr_retorno.socvcltip   
                          ,lr_retorno.atdvclsgl      
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'Viatura nao encontrada'
      else
         let lr_retorno.erro = 3                                       
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datkveiculo'
      end if
   else
      let lr_retorno.erro = 1
   end if
   
   if l_tp_retorno = 1 then
      return lr_retorno.erro,
             lr_retorno.mensagem,
             lr_retorno.socvcltip,
             lr_retorno.atdvclsgl
   end if
   
end function
