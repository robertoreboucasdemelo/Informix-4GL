#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTY30G00.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........:                                                           #
# OBJETIVO.......: VALIDAR O USUARIO LOGADO COM O DONO DO SERVIÇO / OP       #
#                                                                            #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......:   /  /                                                    #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
#                                                                            #
#----------------------------------------------------------------------------#

#### ALGUMAS CONSIDERAÇÕES ####
#
# ESSE CÓDIGO FOI FEITO PARA SER USADO NA CHAMADA DOS PERLS, PORTANTO NAO DEVE
# TER DISPLAYS!!! NAO COLOCAR DISPLAY NO CODIGO PARA PUBLICAR EM PRODUCAO

database porto



#-------------------------------------------
function cty30g00_prestador_por_servico(param)
#-------------------------------------------

   define param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
   end record

   define retorno record
      coderro    smallint
     ,atdprscod  like datmservico.atdprscod
   end record

   whenever error continue
      select atdprscod
        into retorno.atdprscod
        from datmservico
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano

      let retorno.coderro = sqlca.sqlcode
   whenever error stop

   return retorno.*

end function


#-------------------------------------------
function cty30g00_prestador_por_op(param)
#-------------------------------------------
   define param record
      socopgnum like dbsmopg.socopgnum
   end record

   define retorno record
      coderro    smallint
     ,pstcoddig  like dbsmopg.pstcoddig
   end record

   whenever error continue

      select pstcoddig
        into retorno.pstcoddig
        from dbsmopg
       where socopgnum = param.socopgnum

      let retorno.coderro = sqlca.sqlcode

   whenever error stop


   return retorno.*

end function

#-------------------------------------------
function cty30g00_prestador_por_X(param)
#-------------------------------------------

   define param record
      webusrcod  like issrusrprs.webusrcod
   end record

   define retorno record
      coderro    smallint
     ,webprscod  like issrusrprs.webprscod
   end record

   whenever error continue
   select issrusrprs.webprscod
     into retorno.webprscod
     from issrusrprs
         ,dpaksocor
    where dpaksocor.pstcoddig = issrusrprs.webprscod
      and issrusrprs.usrtip    = 'X'
      and issrusrprs.webusrcod = param.webusrcod

   let retorno.coderro = sqlca.sqlcode

   whenever error stop

   return retorno.*


end function



#-------------------------------------------
function cty30g00_valida_dono_op(param)
#-------------------------------------------

   define param record
      socopgnum  like dbsmopg.socopgnum
     ,webusrcod  like issrusrprs.webusrcod
   end record

   define pst_logado like issrusrprs.webprscod
         ,pst_op     like dbsmopg.pstcoddig
         ,coderro    smallint

   initialize  pst_logado
              ,pst_op   to null


   call cty30g00_prestador_por_X(param.webusrcod)
      returning coderro, pst_logado

   if coderro <> 0 then
      return coderro
   else
      call cty30g00_prestador_por_op(param.socopgnum)
         returning coderro, pst_op
      if coderro <> 0 then
         return coderro
      else
         if pst_logado = pst_op then
            let coderro = 0
            return coderro
         else
            let coderro = 101
            return coderro
         end if
      end if
   end if
end function


#-------------------------------------------
function cty30g00_valida_dono_servico(param)
#-------------------------------------------

   define param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
     ,webusrcod like issrusrprs.webusrcod
   end record

   define pst_logado like issrusrprs.webprscod
         ,pst_srv    like dbsmopg.pstcoddig
         ,coderro    smallint


   call cty30g00_prestador_por_X(param.webusrcod)
      returning coderro, pst_logado

   if coderro <> 0 then
      return coderro
   else
      call cty30g00_prestador_por_servico(param.atdsrvnum, param.atdsrvano)
         returning coderro, pst_srv
      if coderro <> 0 then
         return coderro
      else
         if pst_logado = pst_srv then
            let coderro = 0
            return coderro
         else
            let coderro = 101
            return coderro
         end if
      end if
   end if

end function


#-------------------------------------------
function cty30g00_mensagem_erro()
#-------------------------------------------

   display "NOSESS@@Voce nao tem permissao para<BR> acessar essa pagina.@@"
   exit program(0)

end function
