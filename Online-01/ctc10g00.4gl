# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Pronto Socorro                                            #
# Modulo.........: ctc10g00                                                  #
# Objetivo.......: Obter dados da Cia Aerea                                  #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Andrei, META                                              #
# Liberacao      : 21/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

 define m_prep_sql smallint

#--------------------------
function ctc10g00_prepare()
#--------------------------

 define l_sql char(300)

 let l_sql = 'select aercianom, aerpsgrsrflg, aerpsgemsflg'
            ,'  from datkciaaer '
            ,' where aerciacod = ? '

 prepare p_ctc10g00_001 from l_sql
 declare c_ctc10g00_001 cursor for p_ctc10g00_001

 let m_prep_sql = true

end function


#------------------------------------
function ctc10g00_dados_cia(lr_param)
#------------------------------------

 define lr_param record
                 nvlretorno smallint
                ,aerciacod  like datkciaaer.aerciacod
             end record

 define lr_retorno record
                   aercianom    like datkciaaer.aercianom
                  ,aerpsgrsrflg like datkciaaer.aerpsgrsrflg
                  ,aerpsgemsflg like datkciaaer.aerpsgemsflg
                  ,resultado    smallint
                  ,mensagem     char(80)
                end record

 initialize lr_retorno to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc10g00_prepare()
 end if

 let lr_retorno.resultado = 1

 if lr_param.nvlretorno = 1 or
    lr_param.nvlretorno = 2 then
    open c_ctc10g00_001 using lr_param.aerciacod
    whenever error continue
    fetch c_ctc10g00_001 into lr_retorno.aercianom
                           ,lr_retorno.aerpsgrsrflg
                           ,lr_retorno.aerpsgemsflg
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Empresa nao encontrada '
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ',  sqlca.sqlcode, '/', sqlca.sqlerrd[2],
                                     ' em datkciaaer - ctc10g00_dados_cia()'
       end if
    end if

 end if

 if lr_param.nvlretorno = 1 then
    return lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.aercianom
 end if

 if lr_param.nvlretorno = 2 then
    return lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.aercianom
          ,lr_retorno.aerpsgrsrflg
          ,lr_retorno.aerpsgemsflg
end if

end function
