#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Atendimento Segurado                          #
# Modulo         : cty04g01                                                    #
#                  Trata assunto de Servico Emergencial para o departamento de #
#                  Alarmes Monitorados                                         #
# Analista Resp. : Ligia Mattge                                                #
# PSI            : 188425                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 28/10/2004                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
#------------------------------------------------------------------------------#
database porto

# VERIFICA SERVICO EMERGENCIAL
#-------------------------------------------------------------------------------
function cty04g01_serv_emergencial(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          cmnnumdig      like pptmcmn.cmnnumdig,
          carencia       date,
          c24astcod      like datmligacao.c24astcod,
          clscod         like aackcls.clscod
   end record
   define lr_ret         record
          stt            smallint,
          msg            char(80)
   end record
   define lr_cts08       record
          cabtip         char(01),
          conflg         char(01),
          linha1         char(40),
          linha2         char(40),
          linha3         char(40),
          linha4         char(40)
   end record
#=> SE TIVER CARENCIA PARA O SERVICO A RESIDENCIA
   if lr_param.carencia > today    and
     (lr_param.c24astcod = "S60" or
      lr_param.c24astcod = "S63")  then

#=>   EXIBIR ALERTA
      let lr_cts08.cabtip = "A"
      let lr_cts08.conflg = "N"
      let lr_cts08.linha1 = "Atendimento de servicos a residencia"
      let lr_cts08.linha2 = "nao pode ser enviado"
      let lr_cts08.linha3 = null
      let lr_cts08.linha4 = "Clausula em carencia ate ", lr_param.carencia
      let lr_cts08.conflg = cts08g01(lr_cts08.*)

      let lr_ret.stt = 3
      let lr_ret.msg = null
   else

#=>   SE NAO TEM CLAUSULA E FOR SERVICO A RESIDENCIA
      if lr_param.clscod is null      and
        (lr_param.c24astcod = "S60" or
         lr_param.c24astcod = "S63")  then

         let lr_ret.stt = 2
         let lr_ret.msg = "Contrato sem clausula para atender este servico"
      else

         let lr_ret.stt = 1
         let lr_ret.msg = null
      end if
   end if
   return lr_ret.*

end function
