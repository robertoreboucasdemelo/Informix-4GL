#############################################################################
# Nome do Modulo: wdatc001                                           Marcus #
#                                                                      Raji #
# Interface com Sistema Seguranca WEB                              Mar/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
database porto

#------------------------------------------------------------------------------
 function wdatc001(param)
#------------------------------------------------------------------------------

 define param record
   webpstcod        dec(16,0)
 end record 

 define wdatc001 record
    pstcoddig        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr
 end record

 initialize wdatc001.*  to null

 #------------------------------------------------------------------            
 # Realiza pesquisa usando codigo do Sistema de Seguranca                       
 #------------------------------------------------------------------
    select pstcoddig,
           nomgrr
      into wdatc001.pstcoddig,
           wdatc001.nomgrr
      from dpaksocor
     where pstcoddig   = param.webpstcod 


 if sqlca.sqlcode  =  notfound   then
     initialize wdatc001.*  to null
 end if 

 return wdatc001.pstcoddig,
        wdatc001.nomgrr

end function
