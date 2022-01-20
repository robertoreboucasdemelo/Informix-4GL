#############################################################################
# Nome do Modulo: wctn02m00                                          Marcus #
#                                                                      Raji #
# Interface com Sistema Seguranca WEB                              Mar/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
database porto

#------------------------------------------------------------------------------
 function wctn02m00(param)
#------------------------------------------------------------------------------

 define param record
   webpstcod        dec(16,0)
 end record 

 define wctn02m00 record
    pstcoddig        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr
 end record

 initialize wctn02m00.*  to null

 #------------------------------------------------------------------            
 # Realiza pesquisa usando codigo do Sistema de Seguranca                       
 #------------------------------------------------------------------
    select pstcoddig,
           nomgrr
      into wctn02m00.pstcoddig,
           wctn02m00.nomgrr
      from dpaksocor
     where pstcoddig   = param.webpstcod 


 if sqlca.sqlcode  =  notfound   then
     initialize wctn02m00.*  to null
#    let wctn02m00.pstcoddig = NULL
#    let wctn02m00.nomgrr    = NULL
 end if 

 return wctn02m00.pstcoddig,
        wctn02m00.nomgrr

end function
